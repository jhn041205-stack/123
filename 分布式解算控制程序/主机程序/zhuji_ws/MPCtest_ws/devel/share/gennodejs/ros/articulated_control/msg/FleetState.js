// Auto-generated. Do not edit!

// (in-package articulated_control.msg)


"use strict";

const _serializer = _ros_msg_utils.Serialize;
const _arraySerializer = _serializer.Array;
const _deserializer = _ros_msg_utils.Deserialize;
const _arrayDeserializer = _deserializer.Array;
const _finder = _ros_msg_utils.Find;
const _getByteLength = _ros_msg_utils.getByteLength;
let std_msgs = _finder('std_msgs');

//-----------------------------------------------------------

class FleetState {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.header = null;
      this.n_vehicles = null;
      this.phis = null;
      this.thetas = null;
    }
    else {
      if (initObj.hasOwnProperty('header')) {
        this.header = initObj.header
      }
      else {
        this.header = new std_msgs.msg.Header();
      }
      if (initObj.hasOwnProperty('n_vehicles')) {
        this.n_vehicles = initObj.n_vehicles
      }
      else {
        this.n_vehicles = 0;
      }
      if (initObj.hasOwnProperty('phis')) {
        this.phis = initObj.phis
      }
      else {
        this.phis = [];
      }
      if (initObj.hasOwnProperty('thetas')) {
        this.thetas = initObj.thetas
      }
      else {
        this.thetas = [];
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type FleetState
    // Serialize message field [header]
    bufferOffset = std_msgs.msg.Header.serialize(obj.header, buffer, bufferOffset);
    // Serialize message field [n_vehicles]
    bufferOffset = _serializer.int32(obj.n_vehicles, buffer, bufferOffset);
    // Serialize message field [phis]
    bufferOffset = _arraySerializer.float64(obj.phis, buffer, bufferOffset, null);
    // Serialize message field [thetas]
    bufferOffset = _arraySerializer.float64(obj.thetas, buffer, bufferOffset, null);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type FleetState
    let len;
    let data = new FleetState(null);
    // Deserialize message field [header]
    data.header = std_msgs.msg.Header.deserialize(buffer, bufferOffset);
    // Deserialize message field [n_vehicles]
    data.n_vehicles = _deserializer.int32(buffer, bufferOffset);
    // Deserialize message field [phis]
    data.phis = _arrayDeserializer.float64(buffer, bufferOffset, null)
    // Deserialize message field [thetas]
    data.thetas = _arrayDeserializer.float64(buffer, bufferOffset, null)
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += std_msgs.msg.Header.getMessageSize(object.header);
    length += 8 * object.phis.length;
    length += 8 * object.thetas.length;
    return length + 12;
  }

  static datatype() {
    // Returns string type for a message object
    return 'articulated_control/FleetState';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return '45f54608f7b08a0f1eb43e850318378f';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    Header header
    int32 n_vehicles
    float64[] phis
    float64[] thetas
    
    ================================================================================
    MSG: std_msgs/Header
    # Standard metadata for higher-level stamped data types.
    # This is generally used to communicate timestamped data 
    # in a particular coordinate frame.
    # 
    # sequence ID: consecutively increasing ID 
    uint32 seq
    #Two-integer timestamp that is expressed as:
    # * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')
    # * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')
    # time-handling sugar is provided by the client library
    time stamp
    #Frame this data is associated with
    string frame_id
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new FleetState(null);
    if (msg.header !== undefined) {
      resolved.header = std_msgs.msg.Header.Resolve(msg.header)
    }
    else {
      resolved.header = new std_msgs.msg.Header()
    }

    if (msg.n_vehicles !== undefined) {
      resolved.n_vehicles = msg.n_vehicles;
    }
    else {
      resolved.n_vehicles = 0
    }

    if (msg.phis !== undefined) {
      resolved.phis = msg.phis;
    }
    else {
      resolved.phis = []
    }

    if (msg.thetas !== undefined) {
      resolved.thetas = msg.thetas;
    }
    else {
      resolved.thetas = []
    }

    return resolved;
    }
};

module.exports = FleetState;
