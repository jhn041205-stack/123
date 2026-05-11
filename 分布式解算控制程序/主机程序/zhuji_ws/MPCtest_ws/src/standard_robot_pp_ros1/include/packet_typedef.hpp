#ifndef STANDARD_ROBOT_PP_ROS1__PACKET_TYPEDEF_HPP_
#define STANDARD_ROBOT_PP_ROS1__PACKET_TYPEDEF_HPP_

#include <algorithm>
#include <cstdint>
#include <vector>

namespace standard_robot_pp_ros1
{
const uint8_t SOF_RECEIVE = 0x5A;
const uint8_t SOF_SEND = 0x5A;

const uint8_t ID_DEBUG = 0x01;
const uint8_t ID_IMU = 0x02;
const uint8_t ID_PID_DEBUG = 0x05;
const uint8_t ID_ROBOT_MOTION = 0x08;
const uint8_t ID_SOLVED_RC_CMD = 0x0C;
const uint8_t ID_JOINT_STATE = 0x0C;
const uint8_t ID_ROBOT_CMD = 0x01;

const uint8_t DEBUG_PACKAGE_NUM = 10;
const uint8_t DEBUG_PACKAGE_NAME_LEN = 10;

struct HeaderFrame
{
  uint8_t sof;
  uint8_t len;
  uint8_t id;
  uint8_t crc;
} __attribute__((packed));

struct ReceiveDebugData
{
  HeaderFrame frame_header;
  uint32_t time_stamp;
  struct
  {
    uint8_t name[DEBUG_PACKAGE_NAME_LEN];
    uint8_t type;
    float data;
  } __attribute__((packed)) packages[DEBUG_PACKAGE_NUM];
  uint16_t checksum;
} __attribute__((packed));

struct ReceiveImuData
{
  HeaderFrame frame_header;
  uint32_t time_stamp;
  struct
  {
    float yaw;
    float pitch;
    float roll;
    float yaw_vel;
    float pitch_vel;
    float roll_vel;
  } __attribute__((packed)) data;
  uint16_t crc;
} __attribute__((packed));

struct ReceivePidDebugData
{
  HeaderFrame frame_header;
  uint32_t time_stamp;
  struct
  {
    float fdb;
    float ref;
    float pid_out;
  } __attribute__((packed)) data;
  uint16_t crc;
} __attribute__((packed));

struct ReceiveRobotMotionData
{
  HeaderFrame frame_header;
  uint32_t time_stamp;
  struct
  {
    struct
    {
      float vx;
      float vy;
      float wz;
    } __attribute__((packed)) speed_vector;
  } __attribute__((packed)) data;
  uint16_t crc;
} __attribute__((packed));

struct ReceiveJointState
{
  HeaderFrame frame_header;
  uint32_t time_stamp;
  struct
  {
    float pitch;
    float yaw;
  } __attribute__((packed)) data;
  uint16_t crc;
} __attribute__((packed));

struct ReceiveSolvedRcCmdData
{
  HeaderFrame frame_header;
  uint32_t time_stamp;
  struct
  {
    uint8_t mode;
    uint8_t step;
    uint8_t rc_offline;
    uint8_t reserved;
    float vx;
    float vy;
    float wz;
    float roll;
    float pitch;
    float yaw;
    float leg_length_l;
    float leg_length_r;
    float leg_angle_l;
    float leg_angle_r;
    float tail_beta;
  } __attribute__((packed)) data;
  uint16_t crc;
} __attribute__((packed));

struct SendRobotCmdData
{
  HeaderFrame frame_header;
  uint32_t time_stamp;
  struct
  {
    struct
    {
      float vx;
      float vy;
      float wz;
    } __attribute__((packed)) speed_vector;

    struct
    {
      float roll;
      float pitch;
      float yaw;
      float leg_lenth;
    } __attribute__((packed)) chassis;

    struct
    {
      float pitch;
      float yaw;
    } __attribute__((packed)) gimbal;

    struct
    {
      uint8_t fire;
      uint8_t fric_on;
    } __attribute__((packed)) shoot;
  } __attribute__((packed)) data;
  uint16_t checksum;
} __attribute__((packed));

template <typename T>
inline T fromVector(const std::vector<uint8_t> & data)
{
  T packet;
  std::copy(data.begin(), data.end(), reinterpret_cast<uint8_t *>(&packet));
  return packet;
}

template <typename T>
inline std::vector<uint8_t> toVector(const T & data)
{
  std::vector<uint8_t> packet(sizeof(T));
  std::copy(
    reinterpret_cast<const uint8_t *>(&data),
    reinterpret_cast<const uint8_t *>(&data) + sizeof(T),
    packet.begin());
  return packet;
}

}  // namespace standard_robot_pp_ros1

#endif  // STANDARD_ROBOT_PP_ROS1__PACKET_TYPEDEF_HPP_
