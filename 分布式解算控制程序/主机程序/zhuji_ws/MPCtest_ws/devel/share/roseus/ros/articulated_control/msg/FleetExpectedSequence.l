;; Auto-generated. Do not edit!


(when (boundp 'articulated_control::FleetExpectedSequence)
  (if (not (find-package "ARTICULATED_CONTROL"))
    (make-package "ARTICULATED_CONTROL"))
  (shadow 'FleetExpectedSequence (find-package "ARTICULATED_CONTROL")))
(unless (find-package "ARTICULATED_CONTROL::FLEETEXPECTEDSEQUENCE")
  (make-package "ARTICULATED_CONTROL::FLEETEXPECTEDSEQUENCE"))

(in-package "ROS")
;;//! \htmlinclude FleetExpectedSequence.msg.html
(if (not (find-package "STD_MSGS"))
  (ros::roseus-add-msgs "std_msgs"))


(defclass articulated_control::FleetExpectedSequence
  :super ros::object
  :slots (_header _n_vehicles _horizon _leg_length _v_sequence _w_sequence _phi_sequence _theta_sequence ))

(defmethod articulated_control::FleetExpectedSequence
  (:init
   (&key
    ((:header __header) (instance std_msgs::Header :init))
    ((:n_vehicles __n_vehicles) 0)
    ((:horizon __horizon) 0)
    ((:leg_length __leg_length) 0.0)
    ((:v_sequence __v_sequence) (make-array 0 :initial-element 0.0 :element-type :float))
    ((:w_sequence __w_sequence) (make-array 0 :initial-element 0.0 :element-type :float))
    ((:phi_sequence __phi_sequence) (make-array 0 :initial-element 0.0 :element-type :float))
    ((:theta_sequence __theta_sequence) (make-array 0 :initial-element 0.0 :element-type :float))
    )
   (send-super :init)
   (setq _header __header)
   (setq _n_vehicles (round __n_vehicles))
   (setq _horizon (round __horizon))
   (setq _leg_length (float __leg_length))
   (setq _v_sequence __v_sequence)
   (setq _w_sequence __w_sequence)
   (setq _phi_sequence __phi_sequence)
   (setq _theta_sequence __theta_sequence)
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
  (:horizon
   (&optional __horizon)
   (if __horizon (setq _horizon __horizon)) _horizon)
  (:leg_length
   (&optional __leg_length)
   (if __leg_length (setq _leg_length __leg_length)) _leg_length)
  (:v_sequence
   (&optional __v_sequence)
   (if __v_sequence (setq _v_sequence __v_sequence)) _v_sequence)
  (:w_sequence
   (&optional __w_sequence)
   (if __w_sequence (setq _w_sequence __w_sequence)) _w_sequence)
  (:phi_sequence
   (&optional __phi_sequence)
   (if __phi_sequence (setq _phi_sequence __phi_sequence)) _phi_sequence)
  (:theta_sequence
   (&optional __theta_sequence)
   (if __theta_sequence (setq _theta_sequence __theta_sequence)) _theta_sequence)
  (:serialization-length
   ()
   (+
    ;; std_msgs/Header _header
    (send _header :serialization-length)
    ;; int32 _n_vehicles
    4
    ;; int32 _horizon
    4
    ;; float64 _leg_length
    8
    ;; float64[] _v_sequence
    (* 8    (length _v_sequence)) 4
    ;; float64[] _w_sequence
    (* 8    (length _w_sequence)) 4
    ;; float64[] _phi_sequence
    (* 8    (length _phi_sequence)) 4
    ;; float64[] _theta_sequence
    (* 8    (length _theta_sequence)) 4
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; std_msgs/Header _header
       (send _header :serialize s)
     ;; int32 _n_vehicles
       (write-long _n_vehicles s)
     ;; int32 _horizon
       (write-long _horizon s)
     ;; float64 _leg_length
       (sys::poke _leg_length (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; float64[] _v_sequence
     (write-long (length _v_sequence) s)
     (dotimes (i (length _v_sequence))
       (sys::poke (elt _v_sequence i) (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
       )
     ;; float64[] _w_sequence
     (write-long (length _w_sequence) s)
     (dotimes (i (length _w_sequence))
       (sys::poke (elt _w_sequence i) (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
       )
     ;; float64[] _phi_sequence
     (write-long (length _phi_sequence) s)
     (dotimes (i (length _phi_sequence))
       (sys::poke (elt _phi_sequence i) (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
       )
     ;; float64[] _theta_sequence
     (write-long (length _theta_sequence) s)
     (dotimes (i (length _theta_sequence))
       (sys::poke (elt _theta_sequence i) (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
       )
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; std_msgs/Header _header
     (send _header :deserialize buf ptr-) (incf ptr- (send _header :serialization-length))
   ;; int32 _n_vehicles
     (setq _n_vehicles (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; int32 _horizon
     (setq _horizon (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; float64 _leg_length
     (setq _leg_length (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; float64[] _v_sequence
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _v_sequence (instantiate float-vector n))
     (dotimes (i n)
     (setf (elt _v_sequence i) (sys::peek buf ptr- :double)) (incf ptr- 8)
     ))
   ;; float64[] _w_sequence
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _w_sequence (instantiate float-vector n))
     (dotimes (i n)
     (setf (elt _w_sequence i) (sys::peek buf ptr- :double)) (incf ptr- 8)
     ))
   ;; float64[] _phi_sequence
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _phi_sequence (instantiate float-vector n))
     (dotimes (i n)
     (setf (elt _phi_sequence i) (sys::peek buf ptr- :double)) (incf ptr- 8)
     ))
   ;; float64[] _theta_sequence
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _theta_sequence (instantiate float-vector n))
     (dotimes (i n)
     (setf (elt _theta_sequence i) (sys::peek buf ptr- :double)) (incf ptr- 8)
     ))
   ;;
   self)
  )

(setf (get articulated_control::FleetExpectedSequence :md5sum-) "0beb448df9f9c2436a4d59ffca7378f5")
(setf (get articulated_control::FleetExpectedSequence :datatype-) "articulated_control/FleetExpectedSequence")
(setf (get articulated_control::FleetExpectedSequence :definition-)
      "Header header
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

")



(provide :articulated_control/FleetExpectedSequence "0beb448df9f9c2436a4d59ffca7378f5")


