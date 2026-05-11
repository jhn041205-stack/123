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

class FleetExpectedSequence {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.header = null;
      this.n_vehicles = null;
      this.horizon = null;
      this.leg_length = null;
      this.v_sequence = null;
      this.w_sequence = null;
      this.phi_sequence = null;
      this.theta_sequence = null;
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
      if (initObj.hasOwnProperty('horizon')) {
        this.horizon = initObj.horizon
      }
      else {
        this.horizon = 0;
      }
      if (initObj.hasOwnProperty('leg_length')) {
        this.leg_length = initObj.leg_length
      }
      else {
        this.leg_length = 0.0;
      }
      if (initObj.hasOwnProperty('v_sequence')) {
        this.v_sequence = initObj.v_sequence
      }
      else {
        this.v_sequence = [];
      }
      if (initObj.hasOwnProperty('w_sequence')) {
        this.w_sequence = initObj.w_sequence
      }
      else {
        this.w_sequence = [];
      }
      if (initObj.hasOwnProperty('phi_sequence')) {
        this.phi_sequence = initObj.phi_sequence
      }
      else {
        this.phi_sequence = [];
      }
      if (initObj.hasOwnProperty('theta_sequence')) {
        this.theta_sequence = initObj.theta_sequence
      }
      else {
        this.theta_sequence = [];
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type FleetExpectedSequence
    // Serialize message field [header]
    bufferOffset = std_msgs.msg.Header.serialize(obj.header, buffer, bufferOffset);
    // Serialize message field [n_vehicles]
    bufferOffset = _serializer.int32(obj.n_vehicles, buffer, bufferOffset);
    // Serialize message field [horizon]
    bufferOffset = _serializer.int32(obj.horizon, buffer, bufferOffset);
    // Serialize message field [leg_length]
    bufferOffset = _serializer.float64(obj.leg_length, buffer, bufferOffset);
    // Serialize message field [v_sequence]
    bufferOffset = _arraySerializer.float64(obj.v_sequence, buffer, bufferOffset, null);
    // Serialize message field [w_sequence]
    bufferOffset = _arraySerializer.float64(obj.w_sequence, buffer, bufferOffset, null);
    // Serialize message field [phi_sequence]
    bufferOffset = _arraySerializer.float64(obj.phi_sequence, buffer, bufferOffset, null);
    // Serialize message field [theta_sequence]
    bufferOffset = _arraySerializer.float64(obj.theta_sequence, buffer, bufferOffset, null);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type FleetExpectedSequence
    let len;
    let data = new FleetExpectedSequence(null);
    // Deserialize message field [header]
    data.header = std_msgs.msg.Header.deserialize(buffer, bufferOffset);
    // Deserialize message field [n_vehicles]
    data.n_vehicles = _deserializer.int32(buffer, bufferOffset);
    // Deserialize message field [horizon]
    data.horizon = _deserializer.int32(buffer, bufferOffset);
    // Deserialize message field [leg_length]
    data.leg_length = _deserializer.float64(buffer, bufferOffset);
    // Deserialize message field [v_sequence]
    data.v_sequence = _arrayDeserializer.float64(buffer, bufferOffset, null)
    // Deserialize message field [w_sequence]
    data.w_sequence = _arrayDeserializer.float64(buffer, bufferOffset, null)
    // Deserialize message field [phi_sequence]
    data.phi_sequence = _arrayDeserializer.float64(buffer, bufferOffset, null)
    // Deserialize message field [theta_sequence]
    data.theta_sequence = _arrayDeserializer.float64(buffer, bufferOffset, null)
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += std_msgs.msg.Header.getMessageSize(object.header);
    length += 8 * object.v_sequence.length;
    length += 8 * object.w_sequence.length;
    length += 8 * object.phi_sequence.length;
    length += 8 * object.theta_sequence.length;
    return length + 32;
  }

  static datatype() {
    // Returns string type for a message object
    return 'articulated_control/FleetExpectedSequence';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return '0beb448df9f9c2436a4d59ffca7378f5';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    Header header
    int32 n_vehicles
    int32 horizon
    float64 leg_length
    float64[] v_sequence
    float64[] w_sequence
    float64[] phi_sequence
    float64[] theta_sequence
    
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
    const resolved = new FleetExpectedSequence(null);
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

    if (msg.horizon !== undefined) {
      resolved.horizon = msg.horizon;
    }
    else {
      resolved.horizon = 0
    }

    if (msg.leg_length !== undefined) {
      resolved.leg_length = msg.leg_length;
    }
    else {
      resolved.leg_length = 0.0
    }

    if (msg.v_sequence !== undefined) {
      resolved.v_sequence = msg.v_sequence;
    }
    else {
      resolved.v_sequence = []
    }

    if (msg.w_sequence !== undefined) {
      resolved.w_sequence = msg.w_sequence;
    }
    else {
      resolved.w_sequence = []
    }

    if (msg.phi_sequence !== undefined) {
      resolved.phi_sequence = msg.phi_sequence;
    }
    else {
      resolved.phi_sequence = []
    }

    if (msg.theta_sequence !== undefined) {
      resolved.theta_sequence = msg.theta_sequence;
    }
    else {
      resolved.theta_sequence = []
    }

    return resolved;
    }
};

module.exports = FleetExpectedSequence;
