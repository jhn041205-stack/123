;; Auto-generated. Do not edit!


(when (boundp 'articulated_control::VehicleState)
  (if (not (find-package "ARTICULATED_CONTROL"))
    (make-package "ARTICULATED_CONTROL"))
  (shadow 'VehicleState (find-package "ARTICULATED_CONTROL")))
(unless (find-package "ARTICULATED_CONTROL::VEHICLESTATE")
  (make-package "ARTICULATED_CONTROL::VEHICLESTATE"))

(in-package "ROS")
;;//! \htmlinclude VehicleState.msg.html


(defclass articulated_control::VehicleState
  :super ros::object
  :slots (_x _y _phi _L ))

(defmethod articulated_control::VehicleState
  (:init
   (&key
    ((:x __x) 0.0)
    ((:y __y) 0.0)
    ((:phi __phi) 0.0)
    ((:L __L) 0.0)
    )
   (send-super :init)
   (setq _x (float __x))
   (setq _y (float __y))
   (setq _phi (float __phi))
   (setq _L (float __L))
   self)
  (:x
   (&optional __x)
   (if __x (setq _x __x)) _x)
  (:y
   (&optional __y)
   (if __y (setq _y __y)) _y)
  (:phi
   (&optional __phi)
   (if __phi (setq _phi __phi)) _phi)
  (:L
   (&optional __L)
   (if __L (setq _L __L)) _L)
  (:serialization-length
   ()
   (+
    ;; float64 _x
    8
    ;; float64 _y
    8
    ;; float64 _phi
    8
    ;; float64 _L
    8
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; float64 _x
       (sys::poke _x (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; float64 _y
       (sys::poke _y (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; float64 _phi
       (sys::poke _phi (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; float64 _L
       (sys::poke _L (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; float64 _x
     (setq _x (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; float64 _y
     (setq _y (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; float64 _phi
     (setq _phi (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; float64 _L
     (setq _L (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;;
   self)
  )

(setf (get articulated_control::VehicleState :md5sum-) "ec55d4b4fb9a73db2de8096f64140e9a")
(setf (get articulated_control::VehicleState :datatype-) "articulated_control/VehicleState")
(setf (get articulated_control::VehicleState :definition-)
      "float64 x
float64 y
float64 phi
float64 L

")



(provide :articulated_control/VehicleState "ec55d4b4fb9a73db2de8096f64140e9a")


