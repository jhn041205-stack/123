
(cl:in-package :asdf)

(defsystem "articulated_control-msg"
  :depends-on (:roslisp-msg-protocol :roslisp-utils :std_msgs-msg
)
  :components ((:file "_package")
    (:file "ArticulatedState" :depends-on ("_package_ArticulatedState"))
    (:file "_package_ArticulatedState" :depends-on ("_package"))
    (:file "ControlSequenceVW" :depends-on ("_package_ControlSequenceVW"))
    (:file "_package_ControlSequenceVW" :depends-on ("_package"))
    (:file "FleetExpectedSequence" :depends-on ("_package_FleetExpectedSequence"))
    (:file "_package_FleetExpectedSequence" :depends-on ("_package"))
    (:file "FleetPhi" :depends-on ("_package_FleetPhi"))
    (:file "_package_FleetPhi" :depends-on ("_package"))
    (:file "FleetState" :depends-on ("_package_FleetState"))
    (:file "_package_FleetState" :depends-on ("_package"))
    (:file "VehicleState" :depends-on ("_package_VehicleState"))
    (:file "_package_VehicleState" :depends-on ("_package"))
  ))