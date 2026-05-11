#ifndef STANDARD_ROBOT_PP_ROS1__STANDARD_ROBOT_PP_ROS1_HPP_
#define STANDARD_ROBOT_PP_ROS1__STANDARD_ROBOT_PP_ROS1_HPP_

#include <atomic>
#include <cstddef>
#include <mutex>
#include <string>
#include <thread>
#include <unordered_map>

#include <geometry_msgs/TransformStamped.h>
#include <geometry_msgs/Twist.h>
#include <ros/ros.h>
#include <sensor_msgs/Imu.h>
#include <sensor_msgs/JointState.h>
#include <std_msgs/Float64.h>
#include <std_msgs/UInt8.h>
#include <tf2/LinearMath/Quaternion.h>
#include <tf2_ros/transform_broadcaster.h>

#include "packet_typedef.hpp"

namespace standard_robot_pp_ros1
{
class StandardRobotPpRos1Node
{
public:
  StandardRobotPpRos1Node();
  ~StandardRobotPpRos1Node();

private:
  std::atomic<bool> is_usb_ok_{false};
  std::atomic<bool> running_{true};

  ros::NodeHandle nh_;
  ros::NodeHandle pnh_;

  std::string device_name_;
  int baud_rate_{0};
  std::string flow_control_;
  std::string parity_;
  std::string stop_bits_;

  int serial_fd_{-1};
  std::mutex serial_mutex_;
  std::mutex send_data_mutex_;

  std::thread receive_thread_;
  std::thread send_thread_;
  std::thread serial_port_protect_thread_;

  ros::Publisher imu_pub_;
  ros::Publisher robot_motion_pub_;
  ros::Publisher joint_state_pub_;

  ros::Subscriber cmd_vel_sub_;
  ros::Subscriber cmd_leg_length_sub_;
  ros::Subscriber cmd_gimbal_joint_sub_;
  ros::Subscriber cmd_shoot_sub_;

  std::unordered_map<std::string, ros::Publisher> debug_pub_map_;

  SendRobotCmdData send_robot_cmd_data_{};
  tf2_ros::TransformBroadcaster imu_tf_broadcaster_;

  void getParams();
  void configureSerialPort();
  void openSerialPortLocked();
  void closeSerialPortLocked();
  size_t readSerialLocked(uint8_t * buffer, size_t size);
  void writeSerialLocked(const std::vector<uint8_t> & data);
  void createPublisher();
  void createSubscription();
  void createNewDebugPublisher(const std::string & name);
  void receiveData();
  void sendData();
  void serialPortProtect();

  void publishDebugData(ReceiveDebugData & data);
  void publishImuData(ReceiveImuData & data);
  void publishRobotMotion(ReceiveRobotMotionData & data);
  void publishJointState(ReceiveJointState & data);

  void cmdVelCallback(const geometry_msgs::Twist::ConstPtr & msg);
  void cmdLegLengthCallback(const std_msgs::Float64::ConstPtr & msg);
  void cmdGimbalJointCallback(const sensor_msgs::JointState::ConstPtr & msg);
  void cmdShootCallback(const std_msgs::UInt8::ConstPtr & msg);

  static ros::Time toRosTime(uint32_t time_stamp_ms);
};
}  // namespace standard_robot_pp_ros1

#endif  // STANDARD_ROBOT_PP_ROS1__STANDARD_ROBOT_PP_ROS1_HPP_
