#include "standard_robot_pp_ros1.hpp"

#include <cmath>
#include <chrono>
#include <cerrno>
#include <cstring>
#include <fcntl.h>
#include <stdexcept>
#include <sys/select.h>
#include <termios.h>
#include <unistd.h>
#include <vector>

#include <tf2_geometry_msgs/tf2_geometry_msgs.h>

#include "crc8_crc16.hpp"

#define USB_NOT_OK_SLEEP_TIME 1000
#define USB_PROTECT_SLEEP_TIME 1000

namespace standard_robot_pp_ros1
{
namespace
{
constexpr int kSerialReadTimeoutMs = 50;

void requireValidValue(bool condition, const std::string & error_message)
{
  if (!condition) {
    throw std::invalid_argument(error_message);
  }
}

speed_t toBaudConstant(int baud_rate)
{
  switch (baud_rate) {
    case 9600:
      return B9600;
    case 19200:
      return B19200;
    case 38400:
      return B38400;
    case 57600:
      return B57600;
    case 115200:
      return B115200;
    case 230400:
      return B230400;
    case 460800:
      return B460800;
    case 921600:
      return B921600;
    default:
      throw std::invalid_argument("Unsupported baud_rate parameter.");
  }
}
}  // namespace

StandardRobotPpRos1Node::StandardRobotPpRos1Node()
: pnh_("~")
{
  ROS_INFO("Start StandardRobotPpRos1Node!");

  getParams();
  configureSerialPort();
  createPublisher();
  if (enable_usb_command_tx_) {
    createSubscription();
  }

  serial_port_protect_thread_ = std::thread(&StandardRobotPpRos1Node::serialPortProtect, this);
  receive_thread_ = std::thread(&StandardRobotPpRos1Node::receiveData, this);
  if (enable_usb_command_tx_) {
    send_thread_ = std::thread(&StandardRobotPpRos1Node::sendData, this);
  }
}

StandardRobotPpRos1Node::~StandardRobotPpRos1Node()
{
  running_ = false;

  {
    std::lock_guard<std::mutex> lock(serial_mutex_);
    closeSerialPortLocked();
  }

  if (send_thread_.joinable()) {
    send_thread_.join();
  }
  if (receive_thread_.joinable()) {
    receive_thread_.join();
  }
  if (serial_port_protect_thread_.joinable()) {
    serial_port_protect_thread_.join();
  }
}

ros::Time StandardRobotPpRos1Node::toRosTime(uint32_t time_stamp_ms)
{
  return ros::Time(time_stamp_ms / 1000, (time_stamp_ms % 1000) * 1000000);
}

void StandardRobotPpRos1Node::getParams()
{
  pnh_.param<std::string>("device_name", device_name_, "");
  pnh_.param("baud_rate", baud_rate_, 0);
  pnh_.param<std::string>("flow_control", flow_control_, "none");
  pnh_.param<std::string>("parity", parity_, "none");
  pnh_.param<std::string>("stop_bits", stop_bits_, "1");
  pnh_.param("enable_usb_command_tx", enable_usb_command_tx_, false);
  pnh_.param<std::string>(
    "solved_rc_control_topic", solved_rc_control_topic_, "/articulated_vehicle/control_sequence");
  pnh_.param<std::string>(
    "solved_rc_leg_topic", solved_rc_leg_topic_, "/articulated_control/head_leg_length");
  pnh_.param("solved_rc_seq_len", solved_rc_seq_len_, 10);
  pnh_.param("solved_rc_default_leg_length", solved_rc_default_leg_length_, 0.18);
  solved_rc_seq_len_ = std::max(1, solved_rc_seq_len_);

  requireValidValue(!device_name_.empty(), "The device_name parameter must not be empty.");
  requireValidValue(baud_rate_ > 0, "The baud_rate parameter must be greater than zero.");
  requireValidValue(
    flow_control_ == "none" || flow_control_ == "hardware" || flow_control_ == "software",
    "The flow_control parameter must be one of: none, software, or hardware.");
  requireValidValue(
    parity_ == "none" || parity_ == "odd" || parity_ == "even",
    "The parity parameter must be one of: none, odd, or even.");
  requireValidValue(
    stop_bits_ == "1" || stop_bits_ == "1.0" || stop_bits_ == "1.5" || stop_bits_ == "2" ||
      stop_bits_ == "2.0",
    "The stop_bits parameter must be one of: 1, 1.5, or 2.");
}

void StandardRobotPpRos1Node::configureSerialPort()
{
  (void)toBaudConstant(baud_rate_);
}

void StandardRobotPpRos1Node::openSerialPortLocked()
{
  if (serial_fd_ >= 0) {
    return;
  }

  serial_fd_ = ::open(device_name_.c_str(), O_RDWR | O_NOCTTY);
  if (serial_fd_ < 0) {
    throw std::runtime_error(std::strerror(errno));
  }

  termios tty {};
  if (tcgetattr(serial_fd_, &tty) != 0) {
    const std::string error = std::strerror(errno);
    closeSerialPortLocked();
    throw std::runtime_error(error);
  }

  cfmakeraw(&tty);

  const speed_t baud = toBaudConstant(baud_rate_);
  cfsetispeed(&tty, baud);
  cfsetospeed(&tty, baud);

  tty.c_cflag &= ~CSIZE;
  tty.c_cflag |= CS8;
  tty.c_cflag |= CLOCAL | CREAD;

  if (parity_ == "none") {
    tty.c_cflag &= ~PARENB;
  } else {
    tty.c_cflag |= PARENB;
    if (parity_ == "odd") {
      tty.c_cflag |= PARODD;
    } else {
      tty.c_cflag &= ~PARODD;
    }
  }

  if (stop_bits_ == "2" || stop_bits_ == "2.0") {
    tty.c_cflag |= CSTOPB;
  } else {
    tty.c_cflag &= ~CSTOPB;
  }

  if (flow_control_ == "hardware") {
    tty.c_cflag |= CRTSCTS;
    tty.c_iflag &= ~(IXON | IXOFF | IXANY);
  } else if (flow_control_ == "software") {
    tty.c_cflag &= ~CRTSCTS;
    tty.c_iflag |= IXON | IXOFF | IXANY;
  } else {
    tty.c_cflag &= ~CRTSCTS;
    tty.c_iflag &= ~(IXON | IXOFF | IXANY);
  }

  tty.c_cc[VMIN] = 0;
  tty.c_cc[VTIME] = 1;

  if (tcsetattr(serial_fd_, TCSANOW, &tty) != 0) {
    const std::string error = std::strerror(errno);
    closeSerialPortLocked();
    throw std::runtime_error(error);
  }
}

void StandardRobotPpRos1Node::closeSerialPortLocked()
{
  if (serial_fd_ >= 0) {
    ::close(serial_fd_);
    serial_fd_ = -1;
  }
}

size_t StandardRobotPpRos1Node::readSerialLocked(uint8_t * buffer, size_t size)
{
  if (serial_fd_ < 0) {
    throw std::runtime_error("Serial port is not open.");
  }

  fd_set read_fds;
  FD_ZERO(&read_fds);
  FD_SET(serial_fd_, &read_fds);

  timeval timeout {};
  timeout.tv_sec = 0;
  timeout.tv_usec = kSerialReadTimeoutMs * 1000;

  const int select_result = select(serial_fd_ + 1, &read_fds, nullptr, nullptr, &timeout);
  if (select_result < 0) {
    throw std::runtime_error(std::strerror(errno));
  }
  if (select_result == 0) {
    return 0;
  }

  const ssize_t bytes_read = ::read(serial_fd_, buffer, size);
  if (bytes_read < 0) {
    throw std::runtime_error(std::strerror(errno));
  }
  return static_cast<size_t>(bytes_read);
}

void StandardRobotPpRos1Node::writeSerialLocked(const std::vector<uint8_t> & data)
{
  if (serial_fd_ < 0) {
    throw std::runtime_error("Serial port is not open.");
  }

  size_t total_written = 0;
  while (total_written < data.size()) {
    const ssize_t bytes_written =
      ::write(serial_fd_, data.data() + total_written, data.size() - total_written);
    if (bytes_written < 0) {
      throw std::runtime_error(std::strerror(errno));
    }
    total_written += static_cast<size_t>(bytes_written);
  }
}

void StandardRobotPpRos1Node::createPublisher()
{
  imu_pub_ = nh_.advertise<sensor_msgs::Imu>("serial/imu", 10);
  joint_state_pub_ = nh_.advertise<sensor_msgs::JointState>("serial/gimbal_joint_state", 10);
  robot_motion_pub_ = nh_.advertise<geometry_msgs::Twist>("serial/robot_motion", 10);
  solved_rc_control_pub_ =
    nh_.advertise<articulated_control::ControlSequenceVW>(solved_rc_control_topic_, 10);
  solved_rc_leg_pub_ = nh_.advertise<std_msgs::Float64>(solved_rc_leg_topic_, 10);
}

void StandardRobotPpRos1Node::createNewDebugPublisher(const std::string & name)
{
  ROS_INFO("Create new debug publisher: %s", name.c_str());
  const std::string topic_name = "serial/debug/" + name;
  debug_pub_map_.insert(std::make_pair(name, nh_.advertise<std_msgs::Float64>(topic_name, 10)));
}

void StandardRobotPpRos1Node::createSubscription()
{
  cmd_vel_sub_ = nh_.subscribe("cmd_vel", 10, &StandardRobotPpRos1Node::cmdVelCallback, this);
  cmd_leg_length_sub_ =
    nh_.subscribe("cmd_leg_length", 10, &StandardRobotPpRos1Node::cmdLegLengthCallback, this);
  cmd_gimbal_joint_sub_ = nh_.subscribe(
    "cmd_gimbal_joint", 10, &StandardRobotPpRos1Node::cmdGimbalJointCallback, this);
  cmd_shoot_sub_ =
    nh_.subscribe("cmd_shoot", 10, &StandardRobotPpRos1Node::cmdShootCallback, this);
}

void StandardRobotPpRos1Node::serialPortProtect()
{
  ROS_INFO("Start serialPortProtect!");

  while (ros::ok() && running_) {
    if (!is_usb_ok_) {
      try {
        std::lock_guard<std::mutex> lock(serial_mutex_);
        closeSerialPortLocked();
        openSerialPortLocked();
        ROS_INFO("Serial port opened!");
        is_usb_ok_ = true;
      } catch (const std::exception & ex) {
        is_usb_ok_ = false;
        ROS_ERROR("Open serial port failed: %s", ex.what());
      }
    }

    std::this_thread::sleep_for(std::chrono::milliseconds(USB_PROTECT_SLEEP_TIME));
  }
}

void StandardRobotPpRos1Node::receiveData()
{
  ROS_INFO("Start receiveData!");

  std::vector<uint8_t> sof(1);
  int sof_count = 0;
  int retry_count = 0;

  while (ros::ok() && running_) {
    if (!is_usb_ok_) {
      ROS_WARN_THROTTLE(1.0, "receive: usb is not ok! Retry count: %d", retry_count++);
      std::this_thread::sleep_for(std::chrono::milliseconds(USB_NOT_OK_SLEEP_TIME));
      continue;
    }

    try {
      {
        std::lock_guard<std::mutex> lock(serial_mutex_);
        if (readSerialLocked(sof.data(), sof.size()) != sof.size()) {
          continue;
        }
      }

      if (sof[0] != SOF_RECEIVE) {
        ++sof_count;
        ROS_DEBUG("Find sof, cnt=%d", sof_count);
        continue;
      }

      sof_count = 0;

      std::vector<uint8_t> header_frame_buf(3);
      {
        std::lock_guard<std::mutex> lock(serial_mutex_);
        if (readSerialLocked(header_frame_buf.data(), header_frame_buf.size()) !=
            header_frame_buf.size()) {
          continue;
        }
      }

      header_frame_buf.insert(header_frame_buf.begin(), sof[0]);
      HeaderFrame header_frame = fromVector<HeaderFrame>(header_frame_buf);

      if (!crc8::verify_CRC8_check_sum(
            reinterpret_cast<uint8_t *>(&header_frame), sizeof(header_frame))) {
        ROS_ERROR("Header frame CRC8 error!");
        continue;
      }

      std::vector<uint8_t> data_buf(header_frame.len + 2);
      size_t received_len = 0;
      {
        std::lock_guard<std::mutex> lock(serial_mutex_);
        received_len = readSerialLocked(data_buf.data(), data_buf.size());
      }

      while (received_len < data_buf.size()) {
        std::lock_guard<std::mutex> lock(serial_mutex_);
        const size_t chunk = readSerialLocked(
          data_buf.data() + received_len, data_buf.size() - received_len);
        if (chunk == 0) {
          break;
        }
        received_len += chunk;
      }

      if (received_len != data_buf.size()) {
        continue;
      }

      data_buf.insert(data_buf.begin(), header_frame_buf.begin(), header_frame_buf.end());

      if (!crc16::verify_CRC16_check_sum(data_buf)) {
        ROS_ERROR("Data segment CRC16 error!");
        continue;
      }

      switch (header_frame.id) {
        case ID_DEBUG: {
          ReceiveDebugData debug_data = fromVector<ReceiveDebugData>(data_buf);
          publishDebugData(debug_data);
        } break;
        case ID_IMU: {
          ReceiveImuData imu_data = fromVector<ReceiveImuData>(data_buf);
          publishImuData(imu_data);
        } break;
        case ID_PID_DEBUG: {
          ROS_WARN("Not implemented yet!");
        } break;
        case ID_ROBOT_MOTION: {
          ReceiveRobotMotionData robot_motion_data = fromVector<ReceiveRobotMotionData>(data_buf);
          publishRobotMotion(robot_motion_data);
        } break;
        case ID_SOLVED_RC_CMD: {
          if (header_frame.len == sizeof(ReceiveSolvedRcCmdData) - 6) {
            ReceiveSolvedRcCmdData solved_rc_data = fromVector<ReceiveSolvedRcCmdData>(data_buf);
            publishSolvedRcCmd(solved_rc_data);
          } else if (header_frame.len == sizeof(ReceiveJointState) - 6) {
            ReceiveJointState joint_state_data = fromVector<ReceiveJointState>(data_buf);
            publishJointState(joint_state_data);
          } else {
            ROS_WARN("Unsupported 0x0C frame length: %u", header_frame.len);
          }
        } break;
        default: {
          ROS_WARN("Invalid id: %d", header_frame.id);
        } break;
      }
    } catch (const std::exception & ex) {
      ROS_ERROR("Error receiving data: %s", ex.what());
      is_usb_ok_ = false;
    }
  }
}

void StandardRobotPpRos1Node::publishDebugData(ReceiveDebugData & received_debug_data)
{
  for (int i = 0; i < DEBUG_PACKAGE_NUM; ++i) {
    std::vector<uint8_t> non_zero_data;
    for (size_t j = 0; j < DEBUG_PACKAGE_NAME_LEN; ++j) {
      if (received_debug_data.packages[i].name[j] == 0) {
        break;
      }
      non_zero_data.push_back(received_debug_data.packages[i].name[j]);
    }

    const std::string name(non_zero_data.begin(), non_zero_data.end());
    if (name.empty()) {
      continue;
    }

    if (debug_pub_map_.find(name) == debug_pub_map_.end()) {
      createNewDebugPublisher(name);
    }

    std_msgs::Float64 msg;
    msg.data = received_debug_data.packages[i].data;
    debug_pub_map_.at(name).publish(msg);
  }
}

void StandardRobotPpRos1Node::publishImuData(ReceiveImuData & imu_data)
{
  sensor_msgs::Imu msg;
  tf2::Quaternion q;
  q.setRPY(imu_data.data.roll, imu_data.data.pitch, imu_data.data.yaw);

  msg.header.stamp = toRosTime(imu_data.time_stamp);
  msg.header.frame_id = "odom";
  msg.orientation.x = q.x();
  msg.orientation.y = q.y();
  msg.orientation.z = q.z();
  msg.orientation.w = q.w();
  msg.angular_velocity.x = imu_data.data.roll_vel;
  msg.angular_velocity.y = imu_data.data.pitch_vel;
  msg.angular_velocity.z = imu_data.data.yaw_vel;
  imu_pub_.publish(msg);

  geometry_msgs::TransformStamped t;
  t.header.stamp = msg.header.stamp;
  t.header.frame_id = "odom";
  t.child_frame_id = "imu";
  t.transform.rotation = tf2::toMsg(q);
  imu_tf_broadcaster_.sendTransform(t);
}

void StandardRobotPpRos1Node::publishRobotMotion(ReceiveRobotMotionData & robot_motion)
{
  geometry_msgs::Twist msg;
  msg.linear.x = robot_motion.data.speed_vector.vx;
  msg.linear.y = robot_motion.data.speed_vector.vy;
  msg.angular.z = robot_motion.data.speed_vector.wz;
  robot_motion_pub_.publish(msg);
}

void StandardRobotPpRos1Node::publishJointState(ReceiveJointState & joint_state)
{
  sensor_msgs::JointState msg;
  msg.header.stamp = ros::Time::now();
  msg.name.resize(2);
  msg.position.resize(2);
  msg.name[0] = "gimbal_pitch_joint";
  msg.position[0] = joint_state.data.pitch;
  msg.name[1] = "gimbal_yaw_joint";
  msg.position[1] = joint_state.data.yaw;
  joint_state_pub_.publish(msg);
}

void StandardRobotPpRos1Node::publishSolvedRcCmd(ReceiveSolvedRcCmdData & solved_rc)
{
  double vx = solved_rc.data.vx;
  double wz = solved_rc.data.wz;
  double leg_length = 0.5 * (solved_rc.data.leg_length_l + solved_rc.data.leg_length_r);

  if (!std::isfinite(vx)) {
    vx = 0.0;
  }
  if (!std::isfinite(wz)) {
    wz = 0.0;
  }
  if (!std::isfinite(leg_length)) {
    leg_length = solved_rc_default_leg_length_;
  }

  if (solved_rc.data.rc_offline != 0U) {
    vx = 0.0;
    wz = 0.0;
    leg_length = solved_rc_default_leg_length_;
  }

  articulated_control::ControlSequenceVW control_msg;
  control_msg.v_sequence.assign(static_cast<size_t>(solved_rc_seq_len_), vx);
  control_msg.w_sequence.assign(static_cast<size_t>(solved_rc_seq_len_), wz);
  solved_rc_control_pub_.publish(control_msg);

  std_msgs::Float64 leg_msg;
  leg_msg.data = leg_length;
  solved_rc_leg_pub_.publish(leg_msg);

  ROS_INFO_THROTTLE(
    1.0,
    "solved rc | mode=%u step=%u offline=%u vx=%.3f wz=%.3f leg=%.3f",
    solved_rc.data.mode,
    solved_rc.data.step,
    solved_rc.data.rc_offline,
    vx,
    wz,
    leg_length);
}

void StandardRobotPpRos1Node::sendData()
{
  ROS_INFO("Start sendData!");

  {
    std::lock_guard<std::mutex> lock(send_data_mutex_);
    send_robot_cmd_data_.frame_header.sof = SOF_SEND;
    send_robot_cmd_data_.frame_header.id = ID_ROBOT_CMD;
    send_robot_cmd_data_.frame_header.len = sizeof(SendRobotCmdData) - 6;
    crc8::append_CRC8_check_sum(
      reinterpret_cast<uint8_t *>(&send_robot_cmd_data_), sizeof(HeaderFrame));
  }

  int retry_count = 0;

  while (ros::ok() && running_) {
    if (!is_usb_ok_) {
      ROS_WARN_THROTTLE(1.0, "send: usb is not ok! Retry count: %d", retry_count++);
      std::this_thread::sleep_for(std::chrono::milliseconds(USB_NOT_OK_SLEEP_TIME));
      continue;
    }

    try {
      SendRobotCmdData packet;
      {
        std::lock_guard<std::mutex> lock(send_data_mutex_);
        send_robot_cmd_data_.time_stamp = static_cast<uint32_t>(ros::Time::now().toNSec() / 1000000ULL);
        packet = send_robot_cmd_data_;
      }

      crc16::append_CRC16_check_sum(
        reinterpret_cast<uint8_t *>(&packet), sizeof(SendRobotCmdData));

      const std::vector<uint8_t> send_data = toVector(packet);
      {
        std::lock_guard<std::mutex> lock(serial_mutex_);
        writeSerialLocked(send_data);
      }
    } catch (const std::exception & ex) {
      ROS_ERROR("Error sending data: %s", ex.what());
      is_usb_ok_ = false;
    }

    std::this_thread::sleep_for(std::chrono::milliseconds(5));
  }
}

void StandardRobotPpRos1Node::cmdVelCallback(const geometry_msgs::Twist::ConstPtr & msg)
{
  std::lock_guard<std::mutex> lock(send_data_mutex_);
  send_robot_cmd_data_.data.speed_vector.vx = msg->linear.x;
  send_robot_cmd_data_.data.speed_vector.vy = msg->linear.y;
  send_robot_cmd_data_.data.speed_vector.wz = msg->angular.z;
}

void StandardRobotPpRos1Node::cmdLegLengthCallback(const std_msgs::Float64::ConstPtr & msg)
{
  std::lock_guard<std::mutex> lock(send_data_mutex_);
  send_robot_cmd_data_.data.chassis.leg_lenth = static_cast<float>(msg->data);
}

void StandardRobotPpRos1Node::cmdGimbalJointCallback(const sensor_msgs::JointState::ConstPtr & msg)
{
  if (msg->name.size() != msg->position.size()) {
    ROS_ERROR("JointState message name and position arrays are of different sizes");
    return;
  }

  std::lock_guard<std::mutex> lock(send_data_mutex_);
  for (size_t i = 0; i < msg->name.size(); ++i) {
    if (msg->name[i] == "gimbal_pitch_joint") {
      send_robot_cmd_data_.data.gimbal.pitch = msg->position[i];
    } else if (msg->name[i] == "gimbal_yaw_joint") {
      send_robot_cmd_data_.data.gimbal.yaw = msg->position[i];
    }
  }
}

void StandardRobotPpRos1Node::cmdShootCallback(const std_msgs::UInt8::ConstPtr & msg)
{
  std::lock_guard<std::mutex> lock(send_data_mutex_);
  send_robot_cmd_data_.data.shoot.fric_on = true;
  send_robot_cmd_data_.data.shoot.fire = msg->data;
}

}  // namespace standard_robot_pp_ros1
