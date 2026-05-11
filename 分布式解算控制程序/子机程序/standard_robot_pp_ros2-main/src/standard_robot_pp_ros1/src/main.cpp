#include "standard_robot_pp_ros1.hpp"

int main(int argc, char ** argv)
{
  ros::init(argc, argv, "standard_robot_pp_ros1");
  standard_robot_pp_ros1::StandardRobotPpRos1Node node;
  ros::AsyncSpinner spinner(2);
  spinner.start();
  ros::waitForShutdown();
  return 0;
}
