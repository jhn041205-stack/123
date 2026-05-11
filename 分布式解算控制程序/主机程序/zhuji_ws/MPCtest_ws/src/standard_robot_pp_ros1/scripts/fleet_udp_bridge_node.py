#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Head-side UDP/ROS bridge for the real articulated fleet.

- Aggregates local IMU yaw and rear UDP PHI frames into FleetPhi
- Consumes FleetExpectedSequence from articulated_control
- Sends CMD frames to rear vehicles over UDP

Design notes:
- Head state comes from the local serial node via ROS topic.
- Rear states come from UDP and are received by a blocking socket thread.
- Both state publication and control dispatch run at fixed 50 Hz by default.
- Expected control sequences are time-indexed by the planner/control dt, while the
  50 Hz bridge repeats the latest valid rear-vehicle command between sequence steps.
- The head robot executes local RC control directly, so this bridge only dispatches
  follower commands over UDP.
"""

import math
import socket
import threading
from typing import Dict, List, Optional, Tuple

import rospy
from sensor_msgs.msg import Imu

from articulated_control.msg import FleetExpectedSequence, FleetPhi


def quaternion_to_yaw(qx: float, qy: float, qz: float, qw: float) -> float:
    siny_cosp = 2.0 * (qw * qz + qx * qy)
    cosy_cosp = 1.0 - 2.0 * (qy * qy + qz * qz)
    return math.atan2(siny_cosp, cosy_cosp)


class FleetUdpBridgeNode:
    def __init__(self):
        rospy.init_node("fleet_udp_bridge_node")

        self.n_vehicles = int(rospy.get_param("/vehicle/n_vehicles", 3))
        self.n_vehicles = max(1, min(self.n_vehicles, 6))
        self.sequence_dt = float(rospy.get_param("/articulated_control/dt", rospy.get_param("~dt", 0.05)))
        self.state_publish_hz = float(rospy.get_param("~state_publish_hz", 50.0))
        self.command_send_hz = float(rospy.get_param("~command_send_hz", 50.0))

        self.imu_topic = rospy.get_param("~imu_topic", "serial/imu")
        self.fleet_phi_topic = rospy.get_param("~fleet_phi_topic", "/articulated_control/fleet_phi")
        self.expected_sequence_topic = rospy.get_param(
            "~expected_sequence_topic", "/articulated_control/fleet_expected_sequence"
        )

        self.listen_ip = rospy.get_param("~listen_ip", "0.0.0.0")
        self.listen_port = int(rospy.get_param("~listen_port", 5000))
        self.cmd_target_port = int(rospy.get_param("~cmd_target_port", 6000))
        self.rear_vehicle_ips = list(rospy.get_param("~rear_vehicle_ips", []))[:5]

        self._sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self._sock.bind((self.listen_ip, self.listen_port))

        self._local_phi = None
        self._local_stamp_ms = 0
        self._rear_phi: Dict[int, float] = {}
        self._rear_stamp_ms: Dict[int, int] = {}
        self._phi_lock = threading.Lock()

        self._expected_msg: Optional[FleetExpectedSequence] = None
        self._expected_recv_time = rospy.Time(0)
        self._expected_lock = threading.Lock()

        self._running = True
        self._recv_thread = threading.Thread(target=self._recv_rear_phi_loop, daemon=True)

        self._ip_to_index = {}
        for i, ip in enumerate(self.rear_vehicle_ips[: max(0, self.n_vehicles - 1)], start=1):
            if ip:
                self._ip_to_index[ip] = i

        rospy.Subscriber(self.imu_topic, Imu, self.imu_cb, queue_size=1)
        rospy.Subscriber(
            self.expected_sequence_topic, FleetExpectedSequence, self.expected_cb, queue_size=1
        )

        self.fleet_phi_pub = rospy.Publisher(self.fleet_phi_topic, FleetPhi, queue_size=1)

        self._recv_thread.start()
        self.pub_timer = rospy.Timer(
            rospy.Duration(1.0 / max(self.state_publish_hz, 1e-6)), self.publish_fleet_phi
        )
        self.cmd_timer = rospy.Timer(
            rospy.Duration(1.0 / max(self.command_send_hz, 1e-6)), self.dispatch_expected
        )
        rospy.on_shutdown(self.shutdown)

        rospy.loginfo(
            "fleet_udp_bridge_node started | n=%d | listen=%s:%d | state_hz=%.1f | cmd_hz=%.1f | seq_dt=%.3f",
            self.n_vehicles,
            self.listen_ip,
            self.listen_port,
            self.state_publish_hz,
            self.command_send_hz,
            self.sequence_dt,
        )

    def shutdown(self):
        self._running = False
        try:
            self._sock.close()
        except OSError:
            pass

    def imu_cb(self, msg: Imu):
        yaw = quaternion_to_yaw(
            msg.orientation.x,
            msg.orientation.y,
            msg.orientation.z,
            msg.orientation.w,
        )
        stamp_ms = int(msg.header.stamp.to_nsec() / 1000000) if msg.header.stamp != rospy.Time() else 0
        with self._phi_lock:
            self._local_phi = yaw
            self._local_stamp_ms = stamp_ms

    def expected_cb(self, msg: FleetExpectedSequence):
        with self._expected_lock:
            self._expected_msg = msg
            self._expected_recv_time = rospy.Time.now()

    def _parse_phi_frame(self, payload: str) -> Optional[Tuple[int, float]]:
        parts = [p.strip() for p in payload.split(",")]
        if len(parts) != 3 or parts[0] != "PHI":
            return None
        try:
            return int(parts[1]), float(parts[2])
        except ValueError:
            return None

    def _recv_rear_phi_loop(self):
        while self._running and not rospy.is_shutdown():
            try:
                data, addr = self._sock.recvfrom(4096)
            except OSError:
                break
            except Exception as exc:
                rospy.logwarn_throttle(1.0, f"rear phi recv error: {exc}")
                continue

            src_ip = addr[0]
            if src_ip not in self._ip_to_index:
                continue

            parsed = self._parse_phi_frame(data.decode("utf-8", errors="ignore").strip())
            if parsed is None:
                continue

            stamp_ms, phi = parsed
            idx = self._ip_to_index[src_ip]
            with self._phi_lock:
                self._rear_phi[idx] = phi
                self._rear_stamp_ms[idx] = stamp_ms

    def publish_fleet_phi(self, _event):
        with self._phi_lock:
            if self._local_phi is None:
                return
            phis = [self._local_phi]
            stamps = [self._local_stamp_ms]
            for idx in range(1, self.n_vehicles):
                if idx not in self._rear_phi:
                    return
                phis.append(self._rear_phi[idx])
                stamps.append(self._rear_stamp_ms.get(idx, 0))

        msg = FleetPhi()
        msg.header.stamp = rospy.Time.now()
        msg.n_vehicles = self.n_vehicles
        msg.phis = phis
        msg.timestamps_ms = stamps
        self.fleet_phi_pub.publish(msg)

    def _send_cmd_frame(self, ip: str, vx: float, leg_length: float, wz: float):
        payload = f"CMD,{vx:.6f},{leg_length:.6f},{wz:.6f}".encode("utf-8")
        try:
            self._sock.sendto(payload, (ip, self.cmd_target_port))
        except OSError as exc:
            rospy.logwarn_throttle(1.0, f"rear cmd send error to {ip}: {exc}")

    def _current_sequence_step(self, msg: FleetExpectedSequence, recv_time: rospy.Time) -> int:
        if msg.horizon <= 0:
            return -1
        if self.sequence_dt <= 1e-6:
            return 0
        elapsed = max(0.0, (rospy.Time.now() - recv_time).to_sec())
        step = int(elapsed / self.sequence_dt)
        return min(step, msg.horizon - 1)

    def dispatch_expected(self, _event):
        with self._expected_lock:
            msg = self._expected_msg
            recv_time = self._expected_recv_time
            if msg is None or msg.horizon <= 0 or msg.n_vehicles <= 0:
                return
            step = self._current_sequence_step(msg, recv_time)
            if step < 0:
                return

        n = min(self.n_vehicles, int(msg.n_vehicles))
        offset = step * n
        if offset + n > len(msg.v_sequence) or offset + n > len(msg.w_sequence):
            return

        for rear_idx in range(1, n):
            ip_idx = rear_idx - 1
            if ip_idx >= len(self.rear_vehicle_ips):
                continue
            target_ip = self.rear_vehicle_ips[ip_idx]
            if not target_ip:
                continue
            v_cmd = msg.v_sequence[offset + rear_idx]
            w_cmd = msg.w_sequence[offset + rear_idx]
            self._send_cmd_frame(target_ip, v_cmd, msg.leg_length, w_cmd)


if __name__ == "__main__":
    try:
        FleetUdpBridgeNode()
        rospy.spin()
    except rospy.ROSInterruptException:
        pass
