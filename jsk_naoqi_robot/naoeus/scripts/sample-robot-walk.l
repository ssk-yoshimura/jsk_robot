(load "irteus/demo/sample-robot-model.l")
(setq *robot* (instance sample-robot :init))
(send *robot* :reset-pose)
(send *robot* :fix-leg-to-coords (make-coords))
(objects (list *robot*))

(let ((footstep-list
       (list (make-coords :coords (send *robot* :rleg :end-coords :copy-worldcoords) :name :rleg)
	     (make-coords :coords (send (send *robot* :lleg :end-coords :copy-worldcoords)
					:translate #f(100 0 0)) :name :lleg)
	     (make-coords :coords (send (send *robot* :rleg :end-coords :copy-worldcoords)
					:translate #f(200 0 0)) :name :rleg)
	     (make-coords :coords (send (send *robot* :lleg :end-coords :copy-worldcoords)
					:translate #f(300 0 0)) :name :lleg)
	     (make-coords :coords (send (send *robot* :rleg :end-coords :copy-worldcoords)
					:translate #f(400 0 0)) :name :rleg)
	     (make-coords :coords (send (send *robot* :lleg :end-coords :copy-worldcoords)
					:translate #f(400 0 0)) :name :lleg))))
  (objects (append (list *robot*) footstep-list))
  (send *robot* :calc-walk-pattern-from-footstep-list
	footstep-list
	:default-step-height 50
	:default-step-time 1.0
	:dt 1.0
	:debug-view t)
  )
