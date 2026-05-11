; Auto-generated. Do not edit!


(cl:in-package articulated_control-msg)


;//! \htmlinclude ControlSequenceVW.msg.html

(cl:defclass <ControlSequenceVW> (roslisp-msg-protocol:ros-message)
  ((v_sequence
    :reader v_sequence
    :initarg :v_sequence
    :type (cl:vector cl:float)
   :initform (cl:make-array 0 :element-type 'cl:float :initial-element 0.0))
   (w_sequence
    :reader w_sequence
    :initarg :w_sequence
    :type (cl:vector cl:float)
   :initform (cl:make-array 0 :element-type 'cl:float :initial-element 0.0)))
)

(cl:defclass ControlSequenceVW (<ControlSequenceVW>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <ControlSequenceVW>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'ControlSequenceVW)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name articulated_control-msg:<ControlSequenceVW> is deprecated: use articulated_control-msg:ControlSequenceVW instead.")))

(cl:ensure-generic-function 'v_sequence-val :lambda-list '(m))
(cl:defmethod v_sequence-val ((m <ControlSequenceVW>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader articulated_control-msg:v_sequence-val is deprecated.  Use articulated_control-msg:v_sequence instead.")
  (v_sequence m))

(cl:ensure-generic-function 'w_sequence-val :lambda-list '(m))
(cl:defmethod w_sequence-val ((m <ControlSequenceVW>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader articulated_control-msg:w_sequence-val is deprecated.  Use articulated_control-msg:w_sequence instead.")
  (w_sequence m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <ControlSequenceVW>) ostream)
  "Serializes a message object of type '<ControlSequenceVW>"
  (cl:let ((__ros_arr_len (cl:length (cl:slot-value msg 'v_sequence))))
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
   (cl:slot-value msg 'v_sequence))
  (cl:let ((__ros_arr_len (cl:length (cl:slot-value msg 'w_sequence))))
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
   (cl:slot-value msg 'w_sequence))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <ControlSequenceVW>) istream)
  "Deserializes a message object of type '<ControlSequenceVW>"
  (cl:let ((__ros_arr_len 0))
    (cl:setf (cl:ldb (cl:byte 8 0) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) __ros_arr_len) (cl:read-byte istream))
  (cl:setf (cl:slot-value msg 'v_sequence) (cl:make-array __ros_arr_len))
  (cl:let ((vals (cl:slot-value msg 'v_sequence)))
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
  (cl:setf (cl:slot-value msg 'w_sequence) (cl:make-array __ros_arr_len))
  (cl:let ((vals (cl:slot-value msg 'w_sequence)))
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
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<ControlSequenceVW>)))
  "Returns string type for a message object of type '<ControlSequenceVW>"
  "articulated_control/ControlSequenceVW")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'ControlSequenceVW)))
  "Returns string type for a message object of type 'ControlSequenceVW"
  "articulated_control/ControlSequenceVW")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<ControlSequenceVW>)))
  "Returns md5sum for a message object of type '<ControlSequenceVW>"
  "27d78ee3dbd06ca542a270fa283a2711")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'ControlSequenceVW)))
  "Returns md5sum for a message object of type 'ControlSequenceVW"
  "27d78ee3dbd06ca542a270fa283a2711")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<ControlSequenceVW>)))
  "Returns full string definition for message of type '<ControlSequenceVW>"
  (cl:format cl:nil "# Flattened per-vehicle control sequences (time-major):~%# index = t * n_vehicles + i~%float64[] v_sequence~%float64[] w_sequence~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'ControlSequenceVW)))
  "Returns full string definition for message of type 'ControlSequenceVW"
  (cl:format cl:nil "# Flattened per-vehicle control sequences (time-major):~%# index = t * n_vehicles + i~%float64[] v_sequence~%float64[] w_sequence~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <ControlSequenceVW>))
  (cl:+ 0
     4 (cl:reduce #'cl:+ (cl:slot-value msg 'v_sequence) :key #'(cl:lambda (ele) (cl:declare (cl:ignorable ele)) (cl:+ 8)))
     4 (cl:reduce #'cl:+ (cl:slot-value msg 'w_sequence) :key #'(cl:lambda (ele) (cl:declare (cl:ignorable ele)) (cl:+ 8)))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <ControlSequenceVW>))
  "Converts a ROS message object to a list"
  (cl:list 'ControlSequenceVW
    (cl:cons ':v_sequence (v_sequence msg))
    (cl:cons ':w_sequence (w_sequence msg))
))
