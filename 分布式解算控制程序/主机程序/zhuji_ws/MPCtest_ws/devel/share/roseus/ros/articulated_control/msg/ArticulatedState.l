;; Auto-generated. Do not edit!


(when (boundp 'articulated_control::ArticulatedState)
  (if (not (find-package "ARTICULATED_CONTROL"))
    (make-package "ARTICULATED_CONTROL"))
  (shadow 'ArticulatedState (find-package "ARTICULATED_CONTROL")))
(unless (find-package "ARTICULATED_CONTROL::ARTICULATEDSTATE")
  (make-package "ARTICULATED_CONTROL::ARTICULATEDSTATE"))

(in-package "ROS")
;;//! \htmlinclude ArticulatedState.msg.html
(if (not (find-package "STD_MSGS"))
  (ros::roseus-add-msgs "std_msgs"))


(defclass articulated_control::ArticulatedState
  :super ros::object
  :slots (_header _vehicles _thetas ))

(defmethod articulated_control::ArticulatedState
  (:init
   (&key
    ((:header __header) (instance std_msgs::Header :init))
    ((:vehicles __vehicles) ())
    ((:thetas __thetas) (make-array 0 :initial-element 0.0 :element-type :float))
    )
   (send-super :init)
   (setq _header __header)
   (setq _vehicles __vehicles)
   (setq _thetas __thetas)
   self)
  (:header
   (&rest __header)
   (if (keywordp (car __header))
       (send* _header __header)
     (progn
       (if __header (setq _header (car __header)))
       _header)))
  (:vehicles
   (&rest __vehicles)
   (if (keywordp (car __vehicles))
       (send* _vehicles __vehicles)
     (progn
       (if __vehicles (setq _vehicles (car __vehicles)))
       _vehicles)))
  (:thetas
   (&optional __thetas)
   (if __thetas (setq _thetas __thetas)) _thetas)
  (:serialization-length
   ()
   (+
    ;; std_msgs/Header _header
    (send _header :serialization-length)
    ;; articulated_control/VehicleState[] _vehicles
    (apply #'+ (send-all _vehicles :serialization-length)) 4
    ;; float64[] _thetas
    (* 8    (length _thetas)) 4
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; std_msgs/Header _header
       (send _header :serialize s)
     ;; articulated_control/VehicleState[] _vehicles
     (write-long (length _vehicles) s)
     (dolist (elem _vehicles)
       (send elem :serialize s)
       )
     ;; float64[] _thetas
     (write-long (length _thetas) s)
     (dotimes (i (length _thetas))
       (sys::poke (elt _thetas i) (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
       )
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; std_msgs/Header _header
     (send _header :deserialize buf ptr-) (incf ptr- (send _header :serialization-length))
   ;; articulated_control/VehicleState[] _vehicles
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _vehicles (let (r) (dotimes (i n) (push (instance articulated_control::VehicleState :init) r)) r))
     (dolist (elem- _vehicles)
     (send elem- :deserialize buf ptr-) (incf ptr- (send elem- :serialization-length))
     ))
   ;; float64[] _thetas
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _thetas (instantiate float-vector n))
     (dotimes (i n)
     (setf (elt _thetas i) (sys::peek buf ptr- :double)) (incf ptr- 8)
     ))
   ;;
   self)
  )

(setf (get articulated_control::ArticulatedState :md5sum-) "cfbc1c7809bcb64528484d5d27e5c607")
(setf (get articulated_control::ArticulatedState :datatype-) "articulated_control/ArticulatedState")
(setf (get articulated_control::ArticulatedState :definition-)
      "Header header
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

")



(provide :articulated_control/ArticulatedState "cfbc1c7809bcb64528484d5d27e5c607")


