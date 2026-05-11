#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
real_vehicle_central_controller.py - Centralized core solver for real vehicles.

This node no longer handles UDP or serial directly. It only:
- receives fleet phi state and head control sequence from ROS
- solves articulated angular state
- predicts full-fleet expected sequences
- publishes expected sequence back to ROS
"""

import math
import os
import threading
from typing import List, Tuple

import rosparam
import rospy
from std_msgs.msg import Float64

from articulated_control.msg import ControlSequenceVW, FleetExpectedSequence, FleetPhi


MAX_SUPPORTED_VEHICLES = 6


def normalize_angle(angle: float) -> float:
    while angle > math.pi:
        angle -= 2.0 * math.pi
    while angle < -math.pi:
        angle += 2.0 * math.pi
    return angle


def normalize_angle_0_2pi(angle: float) -> float:
    while angle < 0.0:
        angle += 2.0 * math.pi
    while angle >= 2.0 * math.pi:
        angle -= 2.0 * math.pi
    return angle


def compute_thetas_from_phis(phis: List[float]) -> List[float]:
    thetas = []
    for i in range(len(phis) - 1):
        theta = math.pi + phis[i + 1] - phis[i]
        thetas.append(normalize_angle_0_2pi(theta))
    return thetas


def compute_alpha_v_from_vw(v: float, w: float, l1: float) -> Tuple[float, float]:
    v_abs = abs(v)
    w_abs = abs(w)
    eps = 1e-6

    if v_abs < eps and w_abs < eps:
        return 0.0, 0.0

    if w_abs < eps:
        alpha = math.pi / 2.0
    else:
        alpha = math.atan2(v_abs, w_abs * l1)
    alpha = math.copysign(alpha, w) if w_abs >= eps else alpha

    sin_alpha = abs(math.sin(alpha))
    if sin_alpha < eps:
        v_internal = 0.0
    else:
        v_internal = v_abs / sin_alpha
    return alpha, v_internal


def propagate_alphas_vs(
    thetas: List[float], alpha_head: float, v_head_internal: float, l1: float, l2: float
) -> Tuple[List[float], List[float]]:
    alphas = [alpha_head]
    velocities_internal = [v_head_internal]
    for i in range(len(thetas)):
        theta_i = thetas[i]
        alpha_i = alphas[i]
        v_i = velocities_internal[i]
        alpha_next = math.atan(l2 * math.tan(theta_i - math.pi - alpha_i) / l1)
        v_next = abs(
            v_i * l1 / l2 * math.cos(theta_i - math.pi - alpha_i) / (math.cos(alpha_next) + 1e-10)
        )
        alphas.append(alpha_next)
        velocities_internal.append(v_next)
    return alphas, velocities_internal


def compute_vehicle_velocities(
    alphas: List[float], velocities_internal: List[float], l1: float
) -> List[Tuple[float, float]]:
    velocities = []
    for alpha, v_internal in zip(alphas, velocities_internal):
        if abs(alpha) > 1e-6:
            v_linear = abs(v_internal * math.sin(alpha))
            w = (v_internal / l1) * math.cos(alpha) * math.copysign(1.0, alpha)
        else:
            v_linear = v_internal
            w = 0.0
        velocities.append((v_linear, w))
    return velocities


class RealVehicleCentralController:
    def __init__(self):
        rospy.init_node("real_vehicle_central_controller")
        self._load_yaml_to_param_server()

        self.n_vehicles = int(rospy.get_param("/vehicle/n_vehicles", 3))
        self.max_supported_vehicles = int(rospy.get_param("~max_supported_vehicles", MAX_SUPPORTED_VEHICLES))
        self.max_supported_vehicles = max(1, min(self.max_supported_vehicles, MAX_SUPPORTED_VEHICLES))
        self.n_vehicles = max(1, min(self.n_vehicles, self.max_supported_vehicles))
        self.l1 = float(rospy.get_param("/vehicle/L1", 0.9))
        self.l2 = float(rospy.get_param("/vehicle/L2", 0.4))
        rospy.set_param("/vehicle/L1", self.l1)
        rospy.set_param("/vehicle/L2", self.l2)
        self.dt = float(rospy.get_param("/articulated_control/dt", rospy.get_param("~dt", 0.05)))
        self.default_leg_length = float(rospy.get_param("~leg_length", 0.18))

        self.fleet_phi_topic = rospy.get_param("~fleet_phi_topic", "/articulated_control/fleet_phi")
        self.head_control_topic = rospy.get_param(
            "~head_control_topic", "/articulated_vehicle/control_sequence"
        )
        self.head_leg_length_topic = rospy.get_param(
            "~head_leg_length_topic", "/articulated_control/head_leg_length"
        )
        self.expected_sequence_topic = rospy.get_param(
            "~expected_sequence_topic", "/articulated_control/fleet_expected_sequence"
        )

        self._phis: List[float] = []
        self._timestamps_ms: List[int] = []
        self._phi_lock = threading.Lock()

        self._v_seq: List[float] = []
        self._w_seq: List[float] = []
        self._seq_lock = threading.Lock()

        self._leg_length = self.default_leg_length
        self._leg_lock = threading.Lock()

        rospy.Subscriber(self.fleet_phi_topic, FleetPhi, self.fleet_phi_cb, queue_size=1)
        rospy.Subscriber(self.head_control_topic, ControlSequenceVW, self.seq_cb, queue_size=1)
        rospy.Subscriber(self.head_leg_length_topic, Float64, self.leg_length_cb, queue_size=1)

        self.expected_pub = rospy.Publisher(
            self.expected_sequence_topic, FleetExpectedSequence, queue_size=1
        )

        self.timer = rospy.Timer(rospy.Duration(self.dt), self.loop)
        rospy.loginfo(
            "real_vehicle_central_controller started | n=%d | fleet_phi=%s | expected=%s",
            self.n_vehicles,
            self.fleet_phi_topic,
            self.expected_sequence_topic,
        )

    def _load_yaml_to_param_server(self):
        default_yaml = os.path.join(
            os.path.dirname(os.path.dirname(__file__)),
            "config",
            "real_vehicle_host.yaml",
        )
        yaml_path = rospy.get_param("~param_yaml", default_yaml)
        yaml_path = os.path.expanduser(yaml_path)
        if not os.path.isfile(yaml_path):
            rospy.logwarn(f"param yaml not found, skip loading: {yaml_path}")
            return
        try:
            paramlist = rosparam.load_file(yaml_path)
            for params, ns in paramlist:
                rosparam.upload_params(ns, params)
            rospy.loginfo(f"loaded params from yaml: {yaml_path}")
        except Exception as exc:
            rospy.logwarn(f"failed to load yaml params: {exc}")

    def fleet_phi_cb(self, msg: FleetPhi):
        phis = list(msg.phis[: self.n_vehicles])
        timestamps_ms = list(msg.timestamps_ms[: self.n_vehicles])
        if len(phis) < self.n_vehicles:
            return
        while len(timestamps_ms) < self.n_vehicles:
            timestamps_ms.append(0)
        with self._phi_lock:
            self._phis = phis
            self._timestamps_ms = timestamps_ms

    def seq_cb(self, msg: ControlSequenceVW):
        with self._seq_lock:
            self._v_seq = list(msg.v_sequence)
            self._w_seq = list(msg.w_sequence)

    def leg_length_cb(self, msg: Float64):
        with self._leg_lock:
            self._leg_length = float(msg.data)

    def _build_expected_sequence(
        self, phis_now: List[float], head_v_seq: List[float], head_w_seq: List[float], leg_length: float
    ) -> FleetExpectedSequence:
        horizon = min(len(head_v_seq), len(head_w_seq))
        phis = list(phis_now)

        v_flat: List[float] = []
        w_flat: List[float] = []
        phi_flat: List[float] = []
        theta_flat: List[float] = []

        for t in range(horizon):
            thetas = compute_thetas_from_phis(phis)
            head_v = head_v_seq[t]
            head_w = head_w_seq[t]
            alpha_head, v_head_internal = compute_alpha_v_from_vw(head_v, head_w, self.l1)
            alphas, velocities_internal = propagate_alphas_vs(
                thetas, alpha_head, v_head_internal, self.l1, self.l2
            )
            commands = compute_vehicle_velocities(alphas, velocities_internal, self.l1)

            for veh_idx in range(self.n_vehicles):
                v_cmd, w_cmd = commands[veh_idx]
                v_flat.append(v_cmd)
                w_flat.append(w_cmd)
                phi_flat.append(phis[veh_idx])

            theta_flat.extend(thetas)

            next_phis = []
            for veh_idx in range(self.n_vehicles):
                next_phi = normalize_angle(phis[veh_idx] + commands[veh_idx][1] * self.dt)
                next_phis.append(next_phi)
            phis = next_phis

        msg = FleetExpectedSequence()
        msg.header.stamp = rospy.Time.now()
        msg.n_vehicles = self.n_vehicles
        msg.horizon = horizon
        msg.leg_length = leg_length
        msg.v_sequence = v_flat
        msg.w_sequence = w_flat
        msg.phi_sequence = phi_flat
        msg.theta_sequence = theta_flat
        return msg

    def loop(self, _event):
        with self._phi_lock:
            phis = list(self._phis)
        if len(phis) < self.n_vehicles:
            return

        with self._seq_lock:
            head_v_seq = list(self._v_seq)
            head_w_seq = list(self._w_seq)
        if not head_v_seq or not head_w_seq:
            return

        with self._leg_lock:
            leg_length = self._leg_length

        expected_msg = self._build_expected_sequence(phis, head_v_seq, head_w_seq, leg_length)
        self.expected_pub.publish(expected_msg)


if __name__ == "__main__":
    try:
        RealVehicleCentralController()
        rospy.spin()
    except rospy.ROSInterruptException:
        pass
