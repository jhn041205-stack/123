# Install script for directory: /home/computer/robot1_ws/MPCtest_ws/src/standard_robot_pp_ros1

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/home/computer/robot1_ws/MPCtest_ws/install")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/pkgconfig" TYPE FILE FILES "/home/computer/robot1_ws/MPCtest_ws/build/standard_robot_pp_ros1/catkin_generated/installspace/standard_robot_pp_ros1.pc")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/standard_robot_pp_ros1/cmake" TYPE FILE FILES
    "/home/computer/robot1_ws/MPCtest_ws/build/standard_robot_pp_ros1/catkin_generated/installspace/standard_robot_pp_ros1Config.cmake"
    "/home/computer/robot1_ws/MPCtest_ws/build/standard_robot_pp_ros1/catkin_generated/installspace/standard_robot_pp_ros1Config-version.cmake"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/standard_robot_pp_ros1" TYPE FILE FILES "/home/computer/robot1_ws/MPCtest_ws/src/standard_robot_pp_ros1/package.xml")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/standard_robot_pp_ros1/standard_robot_pp_ros1_node" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/standard_robot_pp_ros1/standard_robot_pp_ros1_node")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/standard_robot_pp_ros1/standard_robot_pp_ros1_node"
         RPATH "")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/standard_robot_pp_ros1" TYPE EXECUTABLE FILES "/home/computer/robot1_ws/MPCtest_ws/devel/lib/standard_robot_pp_ros1/standard_robot_pp_ros1_node")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/standard_robot_pp_ros1/standard_robot_pp_ros1_node" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/standard_robot_pp_ros1/standard_robot_pp_ros1_node")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/standard_robot_pp_ros1/standard_robot_pp_ros1_node"
         OLD_RPATH "/opt/ros/noetic/lib:"
         NEW_RPATH "")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/standard_robot_pp_ros1/standard_robot_pp_ros1_node")
    endif()
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/standard_robot_pp_ros1/imu_udp_sender_node" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/standard_robot_pp_ros1/imu_udp_sender_node")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/standard_robot_pp_ros1/imu_udp_sender_node"
         RPATH "")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/standard_robot_pp_ros1" TYPE EXECUTABLE FILES "/home/computer/robot1_ws/MPCtest_ws/devel/lib/standard_robot_pp_ros1/imu_udp_sender_node")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/standard_robot_pp_ros1/imu_udp_sender_node" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/standard_robot_pp_ros1/imu_udp_sender_node")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/standard_robot_pp_ros1/imu_udp_sender_node"
         OLD_RPATH "/opt/ros/noetic/lib:"
         NEW_RPATH "")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/standard_robot_pp_ros1/imu_udp_sender_node")
    endif()
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/standard_robot_pp_ros1/udp_command_receiver_node" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/standard_robot_pp_ros1/udp_command_receiver_node")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/standard_robot_pp_ros1/udp_command_receiver_node"
         RPATH "")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/standard_robot_pp_ros1" TYPE EXECUTABLE FILES "/home/computer/robot1_ws/MPCtest_ws/devel/lib/standard_robot_pp_ros1/udp_command_receiver_node")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/standard_robot_pp_ros1/udp_command_receiver_node" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/standard_robot_pp_ros1/udp_command_receiver_node")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/standard_robot_pp_ros1/udp_command_receiver_node"
         OLD_RPATH "/opt/ros/noetic/lib:"
         NEW_RPATH "")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/standard_robot_pp_ros1/udp_command_receiver_node")
    endif()
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/standard_robot_pp_ros1" TYPE PROGRAM FILES "/home/computer/robot1_ws/MPCtest_ws/build/standard_robot_pp_ros1/catkin_generated/installspace/fleet_udp_bridge_node.py")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/standard_robot_pp_ros1" TYPE DIRECTORY FILES "/home/computer/robot1_ws/MPCtest_ws/src/standard_robot_pp_ros1/include/")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/standard_robot_pp_ros1" TYPE DIRECTORY FILES
    "/home/computer/robot1_ws/MPCtest_ws/src/standard_robot_pp_ros1/config"
    "/home/computer/robot1_ws/MPCtest_ws/src/standard_robot_pp_ros1/launch"
    "/home/computer/robot1_ws/MPCtest_ws/src/standard_robot_pp_ros1/docs"
    )
endif()

