; Auto-generated. Do not edit!


(cl:in-package articulated_control-msg)


;//! \htmlinclude FleetPhi.msg.html

(cl:defclass <FleetPhi> (roslisp-msg-protocol:ros-message)
  ((header
    :reader header
    :initarg :header
    :type std_msgs-msg:Header
    :initform (cl:make-instance 'std_msgs-msg:Header))
   (n_vehicles
    :reader n_vehicles
    :initarg :n_vehicles
    :type cl:integer
    :initform 0)
   (phis
    :reader phis
    :initarg :phis
    :type (cl:vector cl:float)
   :initform (cl:make-array 0 :element-type 'cl:float :initial-element 0.0))
   (timestamps_ms
    :reader timestamps_ms
    :initarg :timestamps_ms
    :type (cl:vector cl:integer)
   :initform (cl:make-array 0 :element-type 'cl:integer :initial-element 0)))
)

(cl:defclass FleetPhi (<FleetPhi>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <FleetPhi>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'FleetPhi)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name articulated_control-msg:<FleetPhi> is deprecated: use articulated_control-msg:FleetPhi instead.")))

(cl:ensure-generic-function 'header-val :lambda-list '(m))
(cl:defmethod header-val ((m <FleetPhi>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader articulated_control-msg:header-val is deprecated.  Use articulated_control-msg:header instead.")
  (header m))

(cl:ensure-generic-function 'n_vehicles-val :lambda-list '(m))
(cl:defmethod n_vehicles-val ((m <FleetPhi>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader articulated_control-msg:n_vehicles-val is deprecated.  Use articulated_control-msg:n_vehicles instead.")
  (n_vehicles m))

(cl:ensure-generic-function 'phis-val :lambda-list '(m))
(cl:defmethod phis-val ((m <FleetPhi>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader articulated_control-msg:phis-val is deprecated.  Use articulated_control-msg:phis instead.")
  (phis m))

(cl:ensure-generic-function 'timestamps_ms-val :lambda-list '(m))
(cl:defmethod timestamps_ms-val ((m <FleetPhi>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader articulated_control-msg:timestamps_ms-val is deprecated.  Use articulated_control-msg:timestamps_ms instead.")
  (timestamps_ms m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <FleetPhi>) ostream)
  "Serializes a message object of type '<FleetPhi>"
  (roslisp-msg-protocol:serialize (cl:slot-value msg 'header) ostream)
  (cl:let* ((signed (cl:slot-value msg 'n_vehicles)) (unsigned (cl:if (cl:< signed 0) (cl:+ signed 4294967296) signed)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) unsigned) ostream)
    )
  (cl:let ((__ros_arr_len (cl:length (cl:slot-value msg 'phis))))
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
   (cl:slot-value msg 'phis))
  (cl:let ((__ros_arr_len (cl:length (cl:slot-value msg 'timestamps_ms))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_arr_len) ostream))
  (cl:map cl:nil #'(cl:lambda (ele) (cl:write-byte (cl:ldb (cl:byte 8 0) ele) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 8) ele) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 16) ele) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 24) ele) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 32) ele) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 40) ele) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 48) ele) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 56) ele) ostream))
   (cl:slot-value msg 'timestamps_ms))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <FleetPhi>) istream)
  "Deserializes a message object of type '<FleetPhi>"
  (roslisp-msg-protocol:deserialize (cl:slot-value msg 'header) istream)
    (cl:let ((unsigned 0))
      (cl:setf (cl:ldb (cl:byte 8 0) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) unsigned) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'n_vehicles) (cl:if (cl:< unsigned 2147483648) unsigned (cl:- unsigned 4294967296))))
  (cl:let ((__ros_arr_len 0))
    (cl:setf (cl:ldb (cl:byte 8 0) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) __ros_arr_len) (cl:read-byte istream))
  (cl:setf (cl:slot-value msg 'phis) (cl:make-array __ros_arr_len))
  (cl:let ((vals (cl:slot-value msg 'phis)))
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
  (cl:let ((__ros_arr_len 0))
    (cl:setf (cl:ldb (cl:byte 8 0) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) __ros_arr_len) (cl:read-byte istream))
  (cl:setf (cl:slot-value msg 'timestamps_ms) (cl:make-array __ros_arr_len))
  (cl:let ((vals (cl:slot-value msg 'timestamps_ms)))
    (cl:dotimes (i __ros_arr_len)
    (cl:setf (cl:ldb (cl:byte 8 0) (cl:aref vals i)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) (cl:aref vals i)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) (cl:aref vals i)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) (cl:aref vals i)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 32) (cl:aref vals i)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 40) (cl:aref vals i)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 48) (cl:aref vals i)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 56) (cl:aref vals i)) (cl:read-byte istream)))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<FleetPhi>)))
  "Returns string type for a message object of type '<FleetPhi>"
  "articulated_control/FleetPhi")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'FleetPhi)))
  "Returns string type for a message object of type 'FleetPhi"
  "articulated_control/FleetPhi")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<FleetPhi>)))
  "Returns md5sum for a message object of type '<FleetPhi>"
  "912f038e1cf337e5ff7786fe07ace650")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'FleetPhi)))
  "Returns md5sum for a message object of type 'FleetPhi"
  "912f038e1cf337e5ff7786fe07ace650")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<FleetPhi>)))
  "Returns full string definition for message of type '<FleetPhi>"
  (cl:format cl:nil "Header header~%int32 n_vehicles~%float64[] phis~%uint64[] timestamps_ms~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'FleetPhi)))
  "Returns full string definition for message of type 'FleetPhi"
  (cl:format cl:nil "Header header~%int32 n_vehicles~%float64[] phis~%uint64[] timestamps_ms~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <FleetPhi>))
  (cl:+ 0
     (roslisp-msg-protocol:serialization-length (cl:slot-value msg 'header))
     4
     4 (cl:reduce #'cl:+ (cl:slot-value msg 'phis) :key #'(cl:lambda (ele) (cl:declare (cl:ignorable ele)) (cl:+ 8)))
     4 (cl:reduce #'cl:+ (cl:slot-value msg 'timestamps_ms) :key #'(cl:lambda (ele) (cl:declare (cl:ignorable ele)) (cl:+ 8)))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <FleetPhi>))
  "Converts a ROS message object to a list"
  (cl:list 'FleetPhi
    (cl:cons ':header (header msg))
    (cl:cons ':n_vehicles (n_vehicles msg))
    (cl:cons ':phis (phis msg))
    (cl:cons ':timestamps_ms (timestamps_ms msg))
))
