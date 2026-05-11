// Auto-generated. Do not edit!

// (in-package articulated_control.msg)


"use strict";

const _serializer = _ros_msg_utils.Serialize;
const _arraySerializer = _serializer.Array;
const _deserializer = _ros_msg_utils.Deserialize;
const _arrayDeserializer = _deserializer.Array;
const _finder = _ros_msg_utils.Find;
const _getByteLength = _ros_msg_utils.getByteLength;

//-----------------------------------------------------------

class ControlSequenceVW {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.v_sequence = null;
      this.w_sequence = null;
    }
    else {
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
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type ControlSequenceVW
    // Serialize message field [v_sequence]
    bufferOffset = _arraySerializer.float64(obj.v_sequence, buffer, bufferOffset, null);
    // Serialize message field [w_sequence]
    bufferOffset = _arraySerializer.float64(obj.w_sequence, buffer, bufferOffset, null);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type ControlSequenceVW
    let len;
    let data = new ControlSequenceVW(null);
    // Deserialize message field [v_sequence]
    data.v_sequence = _arrayDeserializer.float64(buffer, bufferOffset, null)
    // Deserialize message field [w_sequence]
    data.w_sequence = _arrayDeserializer.float64(buffer, bufferOffset, null)
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += 8 * object.v_sequence.length;
    length += 8 * object.w_sequence.length;
    return length + 8;
  }

  static datatype() {
    // Returns string type for a message object
    return 'articulated_control/ControlSequenceVW';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return '27d78ee3dbd06ca542a270fa283a2711';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    # Flattened per-vehicle control sequences (time-major):
    # index = t * n_vehicles + i
    float64[] v_sequence
    float64[] w_sequence
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new ControlSequenceVW(null);
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

    return resolved;
    }
};

module.exports = ControlSequenceVW;
