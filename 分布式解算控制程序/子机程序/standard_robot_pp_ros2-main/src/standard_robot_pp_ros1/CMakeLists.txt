cmake_minimum_required(VERSION 3.0.2)
project(standard_robot_pp_ros1)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_definitions(-Wall -Werror)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(catkin REQUIRED COMPONENTS
  roscpp
  std_msgs
  geometry_msgs
  sensor_msgs
  tf2_ros
  tf2_geometry_msgs
)

catkin_package(
  CATKIN_DEPENDS
    roscpp
    std_msgs
    geometry_msgs
    sensor_msgs
    tf2_ros
    tf2_geometry_msgs
  INCLUDE_DIRS include
)

include_directories(
  include
  ${catkin_INCLUDE_DIRS}
)

add_executable(${PROJECT_NAME}_node
  src/standard_robot_pp_ros1.cpp
  src/crc8_crc16.cpp
  src/main.cpp
)

add_executable(imu_udp_sender_node
  src/imu_udp_sender_node.cpp
)

add_executable(udp_command_receiver_node
  src/udp_command_receiver_node.cpp
)

target_link_libraries(${PROJECT_NAME}_node
  ${catkin_LIBRARIES}
)

target_link_libraries(imu_udp_sender_node
  ${catkin_LIBRARIES}
)

target_link_libraries(udp_command_receiver_node
  ${catkin_LIBRARIES}
)

install(TARGETS
  ${PROJECT_NAME}_node
  imu_udp_sender_node
  udp_command_receiver_node
  RUNTIME DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

install(DIRECTORY include/
  DESTINATION ${CATKIN_PACKAGE_INCLUDE_DESTINATION}
)


install(DIRECTORY config launch docs
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
)
