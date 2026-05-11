#include <arpa/inet.h>
#include <sys/socket.h>
#include <unistd.h>

#include <cerrno>
#include <cstring>
#include <iomanip>
#include <mutex>
#include <sstream>
#include <stdexcept>
#include <string>

#include <ros/ros.h>
#include <sensor_msgs/Imu.h>
#include <tf2/LinearMath/Matrix3x3.h>
#include <tf2_geometry_msgs/tf2_geometry_msgs.h>

class ImuUdpSenderNode
{
public:
  ImuUdpSenderNode()
  : pnh_("~")
  {
    pnh_.param<std::string>("imu_topic", imu_topic_, "serial/imu");
    pnh_.param<std::string>("target_ip", target_ip_, "127.0.0.1");
    pnh_.param("target_port", target_port_, 5000);
    pnh_.param("send_hz", send_hz_, 50.0);
    pnh_.param("print_phi", print_phi_, true);
    pnh_.param("print_hz", print_hz_, 2.0);

    sock_fd_ = ::socket(AF_INET, SOCK_DGRAM, 0);
    if (sock_fd_ < 0) {
      throw std::runtime_error(std::strerror(errno));
    }

    std::memset(&target_addr_, 0, sizeof(target_addr_));
    target_addr_.sin_family = AF_INET;
    target_addr_.sin_port = htons(static_cast<uint16_t>(target_port_));
    if (::inet_pton(AF_INET, target_ip_.c_str(), &target_addr_.sin_addr) != 1) {
      ::close(sock_fd_);
      throw std::runtime_error("Invalid target_ip parameter.");
    }

    imu_sub_ = nh_.subscribe(imu_topic_, 10, &ImuUdpSenderNode::imuCallback, this);
    send_timer_ = nh_.createTimer(
      ros::Duration(1.0 / send_hz_), &ImuUdpSenderNode::sendTimerCallback, this);

    ROS_INFO(
      "imu_udp_sender_node started, imu_topic=%s, target=%s:%d, send_hz=%.2f",
      imu_topic_.c_str(), target_ip_.c_str(), target_port_, send_hz_);
  }

  ~ImuUdpSenderNode()
  {
    if (sock_fd_ >= 0) {
      ::close(sock_fd_);
    }
  }

private:
  void imuCallback(const sensor_msgs::Imu::ConstPtr & msg)
  {
    tf2::Quaternion quaternion;
    tf2::fromMsg(msg->orientation, quaternion);

    double roll = 0.0;
    double pitch = 0.0;
    double yaw = 0.0;
    tf2::Matrix3x3(quaternion).getRPY(roll, pitch, yaw);

    std::lock_guard<std::mutex> lock(data_mutex_);
    latest_phi_ = yaw;
    latest_stamp_ = msg->header.stamp;
    has_imu_ = true;
  }

  void sendTimerCallback(const ros::TimerEvent &)
  {
    double phi = 0.0;
    ros::Time stamp;

    {
      std::lock_guard<std::mutex> lock(data_mutex_);
      if (!has_imu_) {
        return;
      }
      phi = latest_phi_;
      stamp = latest_stamp_;
    }

    const uint64_t stamp_ms = static_cast<uint64_t>(stamp.toNSec() / 1000000ULL);
    std::ostringstream stream;
    stream << "PHI," << stamp_ms << "," << std::fixed << std::setprecision(6) << phi;
    const std::string payload = stream.str();

    if (print_phi_) {
      ROS_INFO_THROTTLE(1.0 / print_hz_, "IMU phi(yaw)=%.6f rad", phi);
    }

    const ssize_t sent = ::sendto(
      sock_fd_, payload.data(), payload.size(), 0,
      reinterpret_cast<const sockaddr *>(&target_addr_), sizeof(target_addr_));
    if (sent < 0) {
      ROS_ERROR_THROTTLE(1.0, "Failed to send phi UDP packet: %s", std::strerror(errno));
    }
  }

  ros::NodeHandle nh_;
  ros::NodeHandle pnh_;
  ros::Subscriber imu_sub_;
  ros::Timer send_timer_;

  std::string imu_topic_;
  std::string target_ip_;
  int target_port_{5000};
  double send_hz_{50.0};
  bool print_phi_{true};
  double print_hz_{2.0};

  int sock_fd_{-1};
  sockaddr_in target_addr_ {};

  std::mutex data_mutex_;
  bool has_imu_{false};
  double latest_phi_{0.0};
  ros::Time latest_stamp_;
};

int main(int argc, char ** argv)
{
  ros::init(argc, argv, "imu_udp_sender_node");
  ImuUdpSenderNode node;
  ros::spin();
  return 0;
}
