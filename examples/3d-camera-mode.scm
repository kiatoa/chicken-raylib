(import raylib)


(define screen-width 800)
(define screen-height 450)

(init-window screen-width screen-height "raylib [core] example - 3d camera mode")

(define camera (make-camera3d))

(camera3d-position-set! camera (vector3 0 10 10))
(camera3d-target-set! camera (vector3 0 0 0))
(camera3d-target-set! camera (vector3 0 0 0))
(camera3d-up-set! camera (vector3 0 1 0))
(camera3d-fovy-set! camera 45)
(camera3d-projection-set! camera CAMERA_PERSPECTIVE)

(define cube-position (vector3 0 0 0))

(set-target-fps 60)

(define (draw-scene)
  (draw-cube cube-position 2 2 2 RED)
  (draw-cube-wires cube-position 2 2 2 MAROON)
  (draw-grid 10 1))

(let loop ()
  (with-drawing
    (lambda ()
      (clear-background RAYWHITE)
      (with-mode-3d camera draw-scene)
      (draw-text "Welcome to the third dimension!" 10 40 20 DARKGRAY)
      (draw-fps 10 10)
      ))
  (unless (window-should-close?) (loop)))

(close-window)
