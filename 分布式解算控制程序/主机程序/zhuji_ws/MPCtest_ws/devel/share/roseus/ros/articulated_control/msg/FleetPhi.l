;; Auto-generated. Do not edit!


(when (boundp 'articulated_control::FleetPhi)
  (if (not (find-package "ARTICULATED_CONTROL"))
    (make-package "ARTICULATED_CONTROL"))
  (shadow 'FleetPhi (find-package "ARTICULATED_CONTROL")))
(unless (find-package "ARTICULATED_CONTROL::FLEETPHI")
  (make-package "ARTICULATED_CONTROL::FLEETPHI"))

(in-package "ROS")
;;//! \htmlinclude FleetPhi.msg.html
(if (not (find-package "STD_MSGS"))
  (ros::roseus-add-msgs "std_msgs"))


(defclass articulated_control::FleetPhi
  :super ros::object
  :slots (_header _n_vehicles _phis _timestamps_ms ))

(defmethod articulated_control::FleetPhi
  (:init
   (&key
    ((:header __header) (instance std_msgs::Header :init))
    ((:n_vehicles __n_vehicles) 0)
    ((:phis __phis) (make-array 0 :initial-element 0.0 :element-type :float))
    ((:timestamps_ms __timestamps_ms) (make-array 0 :initial-element 0 :element-type :integer))
    )
   (send-super :init)
   (setq _header __header)
   (setq _n_vehicles (round __n_vehicles))
   (setq _phis __phis)
   (setq _timestamps_ms __timestamps_ms)
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
  (:timestamps_ms
   (&optional __timestamps_ms)
   (if __timestamps_ms (setq _timestamps_ms __timestamps_ms)) _timestamps_ms)
  (:serialization-length
   ()
   (+
    ;; std_msgs/Header _header
    (send _header :serialization-length)
    ;; int32 _n_vehicles
    4
    ;; float64[] _phis
    (* 8    (length _phis)) 4
    ;; uint64[] _timestamps_ms
    (* 8    (length _timestamps_ms)) 4
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
     ;; uint64[] _timestamps_ms
     (write-long (length _timestamps_ms) s)
     (dotimes (i (length _timestamps_ms))
#+(or :alpha :irix6 :x86_64)
       (progn (sys::poke (elt _timestamps_ms i) (send s :buffer) (send s :count) :long) (incf (stream-count s) 8))
#-(or :alpha :irix6 :x86_64)
       (cond ((and (class (elt _timestamps_ms i)) (= (length ((elt _timestamps_ms i) . bv)) 2)) ;; bignum
              (write-long (ash (elt ((elt _timestamps_ms i) . bv) 0) 0) s)
              (write-long (ash (elt ((elt _timestamps_ms i) . bv) 1) -1) s))
             ((and (class (elt _timestamps_ms i)) (= (length ((elt _timestamps_ms i) . bv)) 1)) ;; big1
              (write-long (elt ((elt _timestamps_ms i) . bv) 0) s)
              (write-long (if (>= (elt _timestamps_ms i) 0) 0 #xffffffff) s))
             (t                                         ;; integer
              (write-long (elt _timestamps_ms i) s)(write-long (if (>= (elt _timestamps_ms i) 0) 0 #xffffffff) s)))
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
   ;; uint64[] _timestamps_ms
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _timestamps_ms (instantiate integer-vector n))
     (dotimes (i n)
     
#+(or :alpha :irix6 :x86_64)
      (setf (elt _timestamps_ms i) (prog1 (sys::peek buf ptr- :long) (incf ptr- 8)))
#-(or :alpha :irix6 :x86_64)
      (setf (elt _timestamps_ms i) (let ((b0 (prog1 (sys::peek buf ptr- :integer) (incf ptr- 4)))
                  (b1 (prog1 (sys::peek buf ptr- :integer) (incf ptr- 4))))
              (cond ((= b1 -1) b0)
                     ((and (= b1  0)
                           (<= lisp::most-negative-fixnum b0 lisp::most-positive-fixnum))
                      b0)
                    ((= b1  0) (make-instance bignum :size 1 :bv (integer-vector b0)))
                    (t (make-instance bignum :size 2 :bv (integer-vector b0 (ash b1 1)))))))
     ))
   ;;
   self)
  )

(setf (get articulated_control::FleetPhi :md5sum-) "912f038e1cf337e5ff7786fe07ace650")
(setf (get articulated_control::FleetPhi :datatype-) "articulated_control/FleetPhi")
(setf (get articulated_control::FleetPhi :definition-)
      "Header header
int32 n_vehicles
float64[] phis
uint64[] timestamps_ms

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



(provide :articulated_control/FleetPhi "912f038e1cf337e5ff7786fe07ace650")


