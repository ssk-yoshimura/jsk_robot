(load "irteus/demo/sample-robot-model.l") ;; sample-robot

(load "package://naoeus/nao-utils.l") ;; nao
(setq *nao* (NaoH25V50))
(objects (list *nao*))
(send *nao* :reset-pose)
(send *nao* :fix-leg-to-coords (make-coords) '(:rleg :lleg))

;; (setq walk-result nil)

(setq dt 0.1) ;; s

(defun walk-motion
    (robot)
  "walking motion using preview-control, gait-generator, and fullbody ik"
  (send *nao* :reset-pose)
  (send *nao* :fix-leg-to-coords (make-coords) '(:rleg :lleg))
  (let* ((is-small-robot
          (< (abs (elt (send (send (car (send robot :links)) :transformation (apply #'midcoords 0.5 (send robot :legs :end-coords))) :worldpos) 2)) 400))
         (default-step-height (if is-small-robot 10 50)))
    (send robot :reset-pose)
    (if is-small-robot
	(send robot :legs :move-end-pos #f(0 0 20)))
    (send robot :fix-leg-to-coords (make-coords))
    (objects (list robot))
    (warn ";; test1 ;; specify footstep-list~%")
    (let* ((test1-scale (if is-small-robot 0.25 1.0))
	   (footstep-list
	    (list (make-coords :coords (send robot :rleg :end-coords :copy-worldcoords) :name :rleg)
		  (make-coords :coords (send (send robot :lleg :end-coords :copy-worldcoords) :translate (scale test1-scale #f(100 0 0))) :name :lleg)
		  (make-coords :coords (send (send robot :rleg :end-coords :copy-worldcoords) :translate (scale test1-scale #f(200 0 0))) :name :rleg)
		  (make-coords :coords (send (send robot :lleg :end-coords :copy-worldcoords) :translate (scale test1-scale #f(300 0 0))) :name :lleg)
		  (make-coords :coords (send (send robot :rleg :end-coords :copy-worldcoords) :translate (scale test1-scale #f(400 0 0))) :name :rleg)
		  (make-coords :coords (send (send robot :lleg :end-coords :copy-worldcoords) :translate (scale test1-scale #f(400 0 0))) :name :lleg))))
      (objects (append (list robot) footstep-list))
      ;; footstep-list is coordinates list.
      ;; This should have :l/r method or :l/r name.
      (setq walk-result
	    (send robot :calc-walk-pattern-from-footstep-list
		  footstep-list :debug-view :no-message
		  :dt 0.1
		  :default-step-time 1.0
		  :default-step-height default-step-height))
    )
  t
  ;;
  #|
  (warn ";; test2 ;; calc footstep-list from go pos param~%")
  (objects (list robot
                 (apply #'midcoords 0.5 (send robot :legs :end-coords))
                 (send (send (apply #'midcoords 0.5 (send robot :legs :end-coords)) :translate (if is-small-robot (float-vector 100 30 0) (float-vector 500 150 0))) :rotate (deg2rad 45) :z)))
  (if is-small-robot (send robot :gen-footstep-parameter :ratio 0.3))
  (send robot :calc-walk-pattern-from-footstep-list
        (if is-small-robot
            (send robot :go-pos-params->footstep-list
                  100 30 45) ;; x[mm] y[mm] th[deg]
          (send robot :go-pos-params->footstep-list
                500 150 45)) ;; x[mm] y[mm] th[deg]
        :debug-view :no-message
        :default-step-height default-step-height)
|#
  ))


(defun walk-motion-for-sample-robot ()
  (unless (boundp '*robot*)
    (setq *robot* (instance sample-robot :init)))
  (walk-motion *robot*))

(defun walk-animation-sample ()
  (setq n (length walk-result))
  (dotimes (i n)
    (send *robot* :angle-vector (elt (elt walk-result i) 1))
    (send *robot* :move-to (elt (elt walk-result i) 3) :world)
    (send *irtviewer* :draw-objects) 
    (unix:usleep 100000))
  )

(defun walk-motion-nao ()
  (walk-motion *nao*))

(defun walk-animation-nao ()
  (setq n (length walk-result))
  (dotimes (i n)
    (send *nao* :angle-vector (elt (elt walk-result i) 1))
    (send *nao* :move-to (elt (elt walk-result i) 3) :world)
    (send *irtviewer* :draw-objects) 
    (unix:usleep 100000))
  )

(defun ri-walk ()
  (son)
  (send *nao* :reset-pose)
  (setq n (length walk-result))
  (dotimes (i n)
    (send *nao* :angle-vector (elt (elt walk-result i) 1))
    (send *ri* :angle-vector (send *nao* :angle-vector) 100)
    (send *ri* :wait-interpolation-smooth 100)
    )
  (soff))

(defun ri-walk-smooth ()

  (walk-motion-nao)
  
  (son)
  
  (setq n (length walk-result))
  (setq avs ())
  (dotimes (i n)
    (setq avs (cons (elt (elt walk-result i) 1) avs)))
  (setq avs (reverse avs))
  
  (send *ri* :angle-vector (car avs) 3000)
  (send *ri* :wait-interpolation)
  
  (send *ri* :angle-vector-sequence avs (list 200))
  (send *ri* :wait-interpolation)
  (soff))
