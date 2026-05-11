# ROS1_StandardRobot++

## 1. 介绍

`standard_robot_pp_ros1` 是配合 [StandardRobot++](https://gitee.com/SMBU-POLARBEAR/StandardRobotpp.git) 下位机控制使用的机器人驱动，提供机器人的控制接口和数据接口。

当前仓库本身已经整理成 ROS1 catkin 工作空间格式：

```text
standard_robot_pp_ros2-master/
├── src/
│   ├── CMakeLists.txt
│   └── standard_robot_pp_ros1/
├── create_udev_rules.sh
└── README.md
```

当前仓库已经按 ROS1 `catkin` 包结构重构，核心通信协议保持不变，迁移重点是：

- `ament_cmake` -> `catkin`
- `rclcpp` -> `roscpp`
- `serial_driver` -> `serial`
- ROS2 launch / 参数体系 -> ROS1 launch / 私有参数

## 2. 协议结构

### 2.1 数据帧构成

|字段|长度 (Byte)|备注|
|:-:|:-:|:-:|
|frame_header|4|帧头|
|time_stamp|4|时间戳（基于下位机运行时间）|
|data|n|数据段|
|checksum|2|校验码|

### 2.2 帧头构成

|字段|长度 (Byte)|备注|
|:-:|:-:|:-:|
|sof|1|数据帧起始字节，固定值为 0x5A|
|len|1|数据段长度|
|id|1|数据段id|
|crc|1|数据帧头的 CRC8 校验|

## 3. 依赖

- Ubuntu: 建议 20.04
- ROS1: Noetic
- 自定义消息类型: `pb_rm_interfaces`
- 串口库: ROS1 `serial`

安装依赖后，将 ROS1 版 `pb_rm_interfaces` 放入当前工作空间的 `src/` 目录。

## 4. 使用方式

1. 配置 udev，用来定向下位机 RoboMaster C 型开发板串口硬件并给予串口权限

```bash
./create_udev_rules.sh
```

2. 构建程序

```bash
catkin_make
```

3. 运行程序

```bash
roslaunch standard_robot_pp_ros1 standard_robot_pp_ros1.launch
```
roslaunch standard_robot_pp_ros1 system_integration.launch use_serial_bridge:=false use_fake_vehicle:=true

roslaunch standard_robot_pp_ros1 system_integration.launch use_serial_bridge:=true use_fake_vehicle:=false

