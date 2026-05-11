// Auto-generated. Do not edit!

// (in-package articulated_control.msg)


"use strict";

const _serializer = _ros_msg_utils.Serialize;
const _arraySerializer = _serializer.Array;
const _deserializer = _ros_msg_utils.Deserialize;
const _arrayDeserializer = _deserializer.Array;
const _finder = _ros_msg_utils.Find;
const _getByteLength = _ros_msg_utils.getByteLength;
let VehicleState = require('./VehicleState.js');
let std_msgs = _finder('std_msgs');

//-----------------------------------------------------------

class ArticulatedState {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.header = null;
      this.vehicles = null;
      this.thetas = null;
    }
    else {
      if (initObj.hasOwnProperty('header')) {
        this.header = initObj.header
      }
      else {
        this.header = new std_msgs.msg.Header();
      }
      if (initObj.hasOwnProperty('vehicles')) {
        this.vehicles = initObj.vehicles
      }
      else {
        this.vehicles = [];
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
    // Serializes a message object of type ArticulatedState
    // Serialize message field [header]
    bufferOffset = std_msgs.msg.Header.serialize(obj.header, buffer, bufferOffset);
    // Serialize message field [vehicles]
    // Serialize the length for message field [vehicles]
    bufferOffset = _serializer.uint32(obj.vehicles.length, buffer, bufferOffset);
    obj.vehicles.forEach((val) => {
      bufferOffset = VehicleState.serialize(val, buffer, bufferOffset);
    });
    // Serialize message field [thetas]
    bufferOffset = _arraySerializer.float64(obj.thetas, buffer, bufferOffset, null);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type ArticulatedState
    let len;
    let data = new ArticulatedState(null);
    // Deserialize message field [header]
    data.header = std_msgs.msg.Header.deserialize(buffer, bufferOffset);
    // Deserialize message field [vehicles]
    // Deserialize array length for message field [vehicles]
    len = _deserializer.uint32(buffer, bufferOffset);
    data.vehicles = new Array(len);
    for (let i = 0; i < len; ++i) {
      data.vehicles[i] = VehicleState.deserialize(buffer, bufferOffset)
    }
    // Deserialize message field [thetas]
    data.thetas = _arrayDeserializer.float64(buffer, bufferOffset, null)
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += std_msgs.msg.Header.getMessageSize(object.header);
    length += 32 * object.vehicles.length;
    length += 8 * object.thetas.length;
    return length + 8;
  }

  static datatype() {
    // Returns string type for a message object
    return 'articulated_control/ArticulatedState';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return 'cfbc1c7809bcb64528484d5d27e5c607';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    Header header
    VehicleState[] vehicles
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
    
    ================================================================================
    MSG: articulated_control/VehicleState
    float64 x
    float64 y
    float64 phi
    float64 L
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new ArticulatedState(null);
    if (msg.header !== undefined) {
      resolved.header = std_msgs.msg.Header.Resolve(msg.header)
    }
    else {
      resolved.header = new std_msgs.msg.Header()
    }

    if (msg.vehicles !== undefined) {
      resolved.vehicles = new Array(msg.vehicles.length);
      for (let i = 0; i < resolved.vehicles.length; ++i) {
        resolved.vehicles[i] = VehicleState.Resolve(msg.vehicles[i]);
      }
    }
    else {
      resolved.vehicles = []
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

module.exports = ArticulatedState;
