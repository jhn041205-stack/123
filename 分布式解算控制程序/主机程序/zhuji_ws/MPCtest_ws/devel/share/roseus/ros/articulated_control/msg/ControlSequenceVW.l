;; Auto-generated. Do not edit!


(when (boundp 'articulated_control::ControlSequenceVW)
  (if (not (find-package "ARTICULATED_CONTROL"))
    (make-package "ARTICULATED_CONTROL"))
  (shadow 'ControlSequenceVW (find-package "ARTICULATED_CONTROL")))
(unless (find-package "ARTICULATED_CONTROL::CONTROLSEQUENCEVW")
  (make-package "ARTICULATED_CONTROL::CONTROLSEQUENCEVW"))

(in-package "ROS")
;;//! \htmlinclude ControlSequenceVW.msg.html


(defclass articulated_control::ControlSequenceVW
  :super ros::object
  :slots (_v_sequence _w_sequence ))

(defmethod articulated_control::ControlSequenceVW
  (:init
   (&key
    ((:v_sequence __v_sequence) (make-array 0 :initial-element 0.0 :element-type :float))
    ((:w_sequence __w_sequence) (make-array 0 :initial-element 0.0 :element-type :float))
    )
   (send-super :init)
   (setq _v_sequence __v_sequence)
   (setq _w_sequence __w_sequence)
   self)
  (:v_sequence
   (&optional __v_sequence)
   (if __v_sequence (setq _v_sequence __v_sequence)) _v_sequence)
  (:w_sequence
   (&optional __w_sequence)
   (if __w_sequence (setq _w_sequence __w_sequence)) _w_sequence)
  (:serialization-length
   ()
   (+
    ;; float64[] _v_sequence
    (* 8    (length _v_sequence)) 4
    ;; float64[] _w_sequence
    (* 8    (length _w_sequence)) 4
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
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
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
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
   ;;
   self)
  )

(setf (get articulated_control::ControlSequenceVW :md5sum-) "27d78ee3dbd06ca542a270fa283a2711")
(setf (get articulated_control::ControlSequenceVW :datatype-) "articulated_control/ControlSequenceVW")
(setf (get articulated_control::ControlSequenceVW :definition-)
      "# Flattened per-vehicle control sequences (time-major):
# index = t * n_vehicles + i
float64[] v_sequence
float64[] w_sequence

")



(provide :articulated_control/ControlSequenceVW "27d78ee3dbd06ca542a270fa283a2711")


