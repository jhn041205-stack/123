;; Auto-generated. Do not edit!


(when (boundp 'articulated_control::FleetState)
  (if (not (find-package "ARTICULATED_CONTROL"))
    (make-package "ARTICULATED_CONTROL"))
  (shadow 'FleetState (find-package "ARTICULATED_CONTROL")))
(unless (find-package "ARTICULATED_CONTROL::FLEETSTATE")
  (make-package "ARTICULATED_CONTROL::FLEETSTATE"))

(in-package "ROS")
;;//! \htmlinclude FleetState.msg.html
(if (not (find-package "STD_MSGS"))
  (ros::roseus-add-msgs "std_msgs"))


(defclass articulated_control::FleetState
  :super ros::object
  :slots (_header _n_vehicles _phis _thetas ))

(defmethod articulated_control::FleetState
  (:init
   (&key
    ((:header __header) (instance std_msgs::Header :init))
    ((:n_vehicles __n_vehicles) 0)
    ((:phis __phis) (make-array 0 :initial-element 0.0 :element-type :float))
    ((:thetas __thetas) (make-array 0 :initial-element 0.0 :element-type :float))
    )
   (send-super :init)
   (setq _header __header)
   (setq _n_vehicles (round __n_vehicles))
   (setq _phis __phis)
   (setq _thetas __thetas)
   self)
  (:header
   (&rest __header)
   (if (keywordp (car __header))
       (send* _header __header)
     (progn
       (if __header (setq _header (car __header)))
       _header)))
  (:n_vehicles
   (&optional __n_vehicles)
   (if __n_vehicles (setq _n_vehicles __n_vehicles)) _n_vehicles)
  (:phis
   (&optional __phis)
   (if __phis (setq _phis __phis)) _phis)
  (:thetas
   (&optional __thetas)
   (if __thetas (setq _thetas __thetas)) _thetas)
  (:serialization-length
   ()
   (+
    ;; std_msgs/Header _header
    (send _header :serialization-length)
    ;; int32 _n_vehicles
    4
    ;; float64[] _phis
    (* 8    (length _phis)) 4
    ;; float64[] _thetas
    (* 8    (length _thetas)) 4
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; std_msgs/Header _header
       (send _header :serialize s)
     ;; int32 _n_vehicles
       (write-long _n_vehicles s)
     ;; float64[] _phis
     (write-long (length _phis) s)
     (dotimes (i (length _phis))
       (sys::poke (elt _phis i) (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
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
   ;; int32 _n_vehicles
     (setq _n_vehicles (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; float64[] _phis
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _phis (instantiate float-vector n))
     (dotimes (i n)
     (setf (elt _phis i) (sys::peek buf ptr- :double)) (incf ptr- 8)
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

(setf (get articulated_control::FleetState :md5sum-) "45f54608f7b08a0f1eb43e850318378f")
(setf (get articulated_control::FleetState :datatype-) "articulated_control/FleetState")
(setf (get articulated_control::FleetState :definition-)
      "Header header
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

")



(provide :articulated_control/FleetState "45f54608f7b08a0f1eb43e850318378f")


