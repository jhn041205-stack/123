; Auto-generated. Do not edit!


(cl:in-package articulated_control-msg)


;//! \htmlinclude ArticulatedState.msg.html

(cl:defclass <ArticulatedState> (roslisp-msg-protocol:ros-message)
  ((header
    :reader header
    :initarg :header
    :type std_msgs-msg:Header
    :initform (cl:make-instance 'std_msgs-msg:Header))
   (vehicles
    :reader vehicles
    :initarg :vehicles
    :type (cl:vector articulated_control-msg:VehicleState)
   :initform (cl:make-array 0 :element-type 'articulated_control-msg:VehicleState :initial-element (cl:make-instance 'articulated_control-msg:VehicleState)))
   (thetas
    :reader thetas
    :initarg :thetas
    :type (cl:vector cl:float)
   :initform (cl:make-array 0 :element-type 'cl:float :initial-element 0.0)))
)

(cl:defclass ArticulatedState (<ArticulatedState>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <ArticulatedState>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'ArticulatedState)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name articulated_control-msg:<ArticulatedState> is deprecated: use articulated_control-msg:ArticulatedState instead.")))

(cl:ensure-generic-function 'header-val :lambda-list '(m))
(cl:defmethod header-val ((m <ArticulatedState>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader articulated_control-msg:header-val is deprecated.  Use articulated_control-msg:header instead.")
  (header m))

(cl:ensure-generic-function 'vehicles-val :lambda-list '(m))
(cl:defmethod vehicles-val ((m <ArticulatedState>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader articulated_control-msg:vehicles-val is deprecated.  Use articulated_control-msg:vehicles instead.")
  (vehicles m))

(cl:ensure-generic-function 'thetas-val :lambda-list '(m))
(cl:defmethod thetas-val ((m <ArticulatedState>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader articulated_control-msg:thetas-val is deprecated.  Use articulated_control-msg:thetas instead.")
  (thetas m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <ArticulatedState>) ostream)
  "Serializes a message object of type '<ArticulatedState>"
  (roslisp-msg-protocol:serialize (cl:slot-value msg 'header) ostream)
  (cl:let ((__ros_arr_len (cl:length (cl:slot-value msg 'vehicles))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_arr_len) ostream))
  (cl:map cl:nil #'(cl:lambda (ele) (roslisp-msg-protocol:serialize ele ostream))
   (cl:slot-value msg 'vehicles))
  (cl:let ((__ros_arr_len (cl:length (cl:slot-value msg 'thetas))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_arr_len) ostream))
  (cl:map cl:nil #'(cl:lambda (ele) (cl:let ((bits (roslisp-utils:encode-double-float-bits ele)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 32) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 40) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 48) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 56) bits) ostream)))
   (cl:slot-value msg 'thetas))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <ArticulatedState>) istream)
  "Deserializes a message object of type '<ArticulatedState>"
  (roslisp-msg-protocol:deserialize (cl:slot-value msg 'header) istream)
  (cl:let ((__ros_arr_len 0))
    (cl:setf (cl:ldb (cl:byte 8 0) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) __ros_arr_len) (cl:read-byte istream))
  (cl:setf (cl:slot-value msg 'vehicles) (cl:make-array __ros_arr_len))
  (cl:let ((vals (cl:slot-value msg 'vehicles)))
    (cl:dotimes (i __ros_arr_len)
    (cl:setf (cl:aref vals i) (cl:make-instance 'articulated_control-msg:VehicleState))
  (roslisp-msg-protocol:deserialize (cl:aref vals i) istream))))
  (cl:let ((__ros_arr_len 0))
    (cl:setf (cl:ldb (cl:byte 8 0) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) __ros_arr_len) (cl:read-byte istream))
  (cl:setf (cl:slot-value msg 'thetas) (cl:make-array __ros_arr_len))
  (cl:let ((vals (cl:slot-value msg 'thetas)))
    (cl:dotimes (i __ros_arr_len)
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 32) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 40) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 48) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 56) bits) (cl:read-byte istream))
    (cl:setf (cl:aref vals i) (roslisp-utils:decode-double-float-bits bits))))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<ArticulatedState>)))
  "Returns string type for a message object of type '<ArticulatedState>"
  "articulated_control/ArticulatedState")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'ArticulatedState)))
  "Returns string type for a message object of type 'ArticulatedState"
  "articulated_control/ArticulatedState")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<ArticulatedState>)))
  "Returns md5sum for a message object of type '<ArticulatedState>"
  "cfbc1c7809bcb64528484d5d27e5c607")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'ArticulatedState)))
  "Returns md5sum for a message object of type 'ArticulatedState"
  "cfbc1c7809bcb64528484d5d27e5c607")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<ArticulatedState>)))
  "Returns full string definition for message of type '<ArticulatedState>"
  (cl:format cl:nil "Header header~%VehicleState[] vehicles~%float64[] thetas~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%================================================================================~%MSG: articulated_control/VehicleState~%float64 x~%float64 y~%float64 phi~%float64 L~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'ArticulatedState)))
  "Returns full string definition for message of type 'ArticulatedState"
  (cl:format cl:nil "Header header~%VehicleState[] vehicles~%float64[] thetas~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%================================================================================~%MSG: articulated_control/VehicleState~%float64 x~%float64 y~%float64 phi~%float64 L~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <ArticulatedState>))
  (cl:+ 0
     (roslisp-msg-protocol:serialization-length (cl:slot-value msg 'header))
     4 (cl:reduce #'cl:+ (cl:slot-value msg 'vehicles) :key #'(cl:lambda (ele) (cl:declare (cl:ignorable ele)) (cl:+ (roslisp-msg-protocol:serialization-length ele))))
     4 (cl:reduce #'cl:+ (cl:slot-value msg 'thetas) :key #'(cl:lambda (ele) (cl:declare (cl:ignorable ele)) (cl:+ 8)))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <ArticulatedState>))
  "Converts a ROS message object to a list"
  (cl:list 'ArticulatedState
    (cl:cons ':header (header msg))
    (cl:cons ':vehicles (vehicles msg))
    (cl:cons ':thetas (thetas msg))
))
