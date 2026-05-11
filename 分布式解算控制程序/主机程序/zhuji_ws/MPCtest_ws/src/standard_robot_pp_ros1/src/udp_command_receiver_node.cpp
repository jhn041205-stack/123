#include <arpa/inet.h>
#include <fcntl.h>
#include <sys/socket.h>
#include <unistd.h>

#include <cerrno>
#include <cstring>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>

#include <geometry_msgs/Twist.h>
#include <ros/ros.h>
#include <sensor_msgs/JointState.h>
#include <std_msgs/Float64.h>

class UdpCommandReceiverNode
{
public:
  UdpCommandReceiverNode()
  : pnh_("~")
  {
    pnh_.param<std::string>("listen_ip", listen_ip_, "0.0.0.0");
    pnh_.param("listen_port", listen_port_, 6000);
    pnh_.param<std::string>("cmd_vel_topic", cmd_vel_topic_, "cmd_vel");
    pnh_.param<std::string>("cmd_leg_length_topic", cmd_leg_length_topic_, "cmd_leg_length");
    pnh_.param<std::string>("cmd_gimbal_topic", cmd_gimbal_topic_, "cmd_gimbal_joint");

    cmd_vel_pub_ = nh_.advertise<geometry_msgs::Twist>(cmd_vel_topic_, 10);
    cmd_leg_length_pub_ = nh_.advertise<std_msgs::Float64>(cmd_leg_length_topic_, 10);
    cmd_gimbal_pub_ = nh_.advertise<sensor_msgs::JointState>(cmd_gimbal_topic_, 10);

    sock_fd_ = ::socket(AF_INET, SOCK_DGRAM, 0);
    if (sock_fd_ < 0) {
      throw std::runtime_error(std::strerror(errno));
    }

    int enable = 1;
    setsockopt(sock_fd_, SOL_SOCKET, SO_REUSEADDR, &enable, sizeof(enable));

    // Explicitly keep the UDP socket in blocking mode so recvfrom() wakes up only when a packet arrives.
    const int flags = fcntl(sock_fd_, F_GETFL, 0);
    if (flags < 0 || fcntl(sock_fd_, F_SETFL, flags & ~O_NONBLOCK) < 0) {
      const std::string error = std::strerror(errno);
      ::close(sock_fd_);
      throw std::runtime_error(error);
    }

    std::memset(&listen_addr_, 0, sizeof(listen_addr_));
    listen_addr_.sin_family = AF_INET;
    listen_addr_.sin_port = htons(static_cast<uint16_t>(listen_port_));
    if (::inet_pton(AF_INET, listen_ip_.c_str(), &listen_addr_.sin_addr) != 1) {
      ::close(sock_fd_);
      throw std::runtime_error("Invalid listen_ip parameter.");
    }

    if (::bind(sock_fd_, reinterpret_cast<const sockaddr *>(&listen_addr_), sizeof(listen_addr_)) <
        0) {
      const std::string error = std::strerror(errno);
      ::close(sock_fd_);
      throw std::runtime_error(error);
    }

    ROS_INFO(
      "udp_command_receiver_node started, listen=%s:%d, cmd_vel_topic=%s, cmd_leg_length_topic=%s",
      listen_ip_.c_str(), listen_port_, cmd_vel_topic_.c_str(), cmd_leg_length_topic_.c_str());
  }

  ~UdpCommandReceiverNode()
  {
    if (sock_fd_ >= 0) {
      ::close(sock_fd_);
    }
  }

  void spin()
  {
    while (ros::ok()) {
      char buffer[512] = {};
      sockaddr_in remote_addr {};
      socklen_t remote_len = sizeof(remote_addr);

      // Blocking receive: this thread sleeps here until the host sends one UDP datagram.
      const ssize_t received = ::recvfrom(
        sock_fd_, buffer, sizeof(buffer) - 1, 0,
        reinterpret_cast<sockaddr *>(&remote_addr), &remote_len);
      if (received < 0) {
        if (errno == EINTR) {
          continue;
        }
        ROS_ERROR_THROTTLE(1.0, "Failed to receive UDP command: %s", std::strerror(errno));
        continue;
      }

      const std::string packet(buffer, static_cast<size_t>(received));
      double vx = 0.0;
      double leg_length = 0.0;
      double wz = 0.0;
      if (!parsePacket(packet, vx, leg_length, wz)) {
        ROS_WARN_THROTTLE(1.0, "Invalid UDP command packet: %s", packet.c_str());
        continue;
      }

      // Publish immediately after a valid packet is received and parsed.
      publishCommand(vx, leg_length, wz);
      ros::spinOnce();
    }
  }

private:
  static bool parsePacket(
    const std::string & packet, double & vx, double & leg_length, double & wz)
  {
    std::vector<std::string> tokens;
    std::stringstream stream(packet);
    std::string token;
    while (std::getline(stream, token, ',')) {
      if (!token.empty() && token.back() == '\n') {
        token.pop_back();
      }
      if (!token.empty() && token.back() == '\r') {
        token.pop_back();
      }
      tokens.push_back(token);
    }

    size_t offset = 0;
    if (tokens.size() == 4 && (tokens[0] == "CMD" || tokens[0] == "cmd")) {
      offset = 1;
    }

    if (tokens.size() - offset != 3) {
      return false;
    }

    try {
      vx = std::stod(tokens[offset + 0]);
      leg_length = std::stod(tokens[offset + 1]);
      wz = std::stod(tokens[offset + 2]);
    } catch (const std::exception &) {
      return false;
    }
    return true;
  }

  void publishCommand(double vx, double leg_length, double wz)
  {
    geometry_msgs::Twist cmd_vel;
    cmd_vel.linear.x = vx;
    cmd_vel.linear.y = 0.0;
    cmd_vel.linear.z = 0.0;
    cmd_vel.angular.x = 0.0;
    cmd_vel.angular.y = 0.0;
    cmd_vel.angular.z = wz;
    cmd_vel_pub_.publish(cmd_vel);

    std_msgs::Float64 leg_msg;
    leg_msg.data = leg_length;
    cmd_leg_length_pub_.publish(leg_msg);

    sensor_msgs::JointState joint_msg;
    joint_msg.header.stamp = ros::Time::now();
    joint_msg.name.resize(2);
    joint_msg.position.resize(2);
    joint_msg.name[0] = "gimbal_pitch_joint";
    joint_msg.position[0] = 0.0;
    joint_msg.name[1] = "gimbal_yaw_joint";
    joint_msg.position[1] = 0.0;
    cmd_gimbal_pub_.publish(joint_msg);
  }

  ros::NodeHandle nh_;
  ros::NodeHandle pnh_;
  ros::Publisher cmd_vel_pub_;
  ros::Publisher cmd_leg_length_pub_;
  ros::Publisher cmd_gimbal_pub_;

  std::string listen_ip_;
  int listen_port_{6000};
  std::string cmd_vel_topic_;
  std::string cmd_leg_length_topic_;
  std::string cmd_gimbal_topic_;

  int sock_fd_{-1};
  sockaddr_in listen_addr_ {};
};

int main(int argc, char ** argv)
{
  ros::init(argc, argv, "udp_command_receiver_node");
  UdpCommandReceiverNode node;
  node.spin();
  return 0;
}
