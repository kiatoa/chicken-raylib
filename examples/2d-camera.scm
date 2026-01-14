(import raylib)

(import (chicken random))
(import srfi-1)
(import srfi-4)

; some helper functions

(define (clamp x a b)
  (max a (min b x)))

(define (float->int x)
  (inexact->exact (floor x)))

(define (get-random-float)
  (/ (pseudo-random-integer 4096) 4096.0))

(define (get-random-value a b)
  (+ a (* (get-random-float) 
          (- b a))))

(define (rect-add-vec2 r v)
  (make-rect
    (+ (rect-x r) (vec2-x v))
    (+ (rect-y r) (vec2-y v))
    (rect-w r)
    (rect-h r)))

(define (fade color opacity)
  (make-color 
    (u8vector-ref color 0)
    (u8vector-ref color 1)
    (u8vector-ref color 2)
    (float->int (* opacity (u8vector-ref color 3)))))

; ----------------------------------------------------------------------------------------
;  Program main entry point
; ----------------------------------------------------------------------------------------

;  Initialization
; ----------------------------------------------------------------------------------------

(define screen-width 800)
(define screen-height 450)

(init-window screen-width screen-height "raylib [core] example - 2d camera")

(define MAX_BUILDINGS 100)
(define player (make-rect 400 280 40 40))

(define buildings 
  (let* ([widths (list-tabulate MAX_BUILDINGS (lambda (i) (get-random-value 50 200)))]
         [xs (fold (lambda (x l) (cons (+ x (car l)) l)) (list -6000) widths)]) ;; accumulate widths
    (map 
      (lambda (x w)
        (let ([h (get-random-value 100 800)])
          (make-rect 
            x
            (- (- screen-height 130) h) 
            w h))) 
      (reverse xs) widths)))

(define build-colors
  (list-tabulate 
    MAX_BUILDINGS 
    (lambda (i)
      (make-color
        (float->int (get-random-value 200 240))
        (float->int (get-random-value 200 240))
        (float->int (get-random-value 200 250))
        255))))

(define camera (make-camera2d))
(camera2d-target-set! camera (make-vec2 (+ 20 (rect-x player)) (+ 20 (rect-y player))))
(camera2d-offset-set! camera (make-vec2 (/ screen-width 2) (/ screen-height 2)))
(camera2d-rotation-set! camera 0)
(camera2d-zoom-set! camera 1)

(set-target-fps 60) ;; Set our game to run at 60 frames-per-second
; ----------------------------------------------------------------------------------------

; Main game loop
(let loop ()

  ; Update
  ; --------------------------------------------------------------------------------------
  ; Player movement
  (when (key-down? KEY_RIGHT)
    (set! player (rect-add-vec2 player (make-vec2 2 0))))
  (when (key-down? KEY_LEFT)
    (set! player (rect-add-vec2 player (make-vec2 -2 0))))

  ; Camera target follows player
  (camera2d-target-set! camera (make-vec2 (+ 20 (rect-x player)) (+ 20 (rect-y player))))

  ; Camera rotation controls
  (when (key-down? KEY_A)
    (camera2d-rotation-set! camera (- (camera2d-rotation camera) 1)))
  (when (key-down? KEY_S)
    (camera2d-rotation-set! camera (+ (camera2d-rotation camera) 1)))

  ; Limit camera rotation to 80 degrees (-40 to 40)
  (camera2d-rotation-set! camera (clamp (camera2d-rotation camera) -40 40))

  ; Camera zoom controls
  ; Uses log scaling to provide consistent zoom speed
  ; *** GetMouseWheelMove not implemented yet ***

  ; Camera reset (zoom and rotation)
  (when (key-pressed? KEY_R) 
    (camera2d-rotation-set! camera 0) 
    (camera2d-zoom-set! camera 1))

  ; Draw
  ; --------------------------------------------------------------------------------------
  (with-drawing
   (lambda ()
     (clear-background RAYWHITE)

     (with-mode-2d 
       camera
       (lambda ()
         (draw-rectangle -6000 320 13000 8000 DARKGRAY)

         (for-each draw-rectangle-rec buildings build-colors)

         (draw-rectangle-rec player RED)

         (draw-line 
           (float->int (vec2-x (camera2d-target camera)))
           (float->int (* screen-height -10))
           (float->int (vec2-x (camera2d-target camera)))
           (float->int (* screen-height 10))
           GREEN)
         (draw-line
           (float->int (* screen-width -10))
           (float->int (vec2-y (camera2d-target camera)))
           (float->int (* screen-width 10))
           (float->int (vec2-y (camera2d-target camera)))
           GREEN)))

     (draw-text "SCREEN AREA" 640 10 20 RED)
     (draw-text (number->string (get-fps)) 640 40 20 RED)

     (draw-rectangle 0 0 screen-width 5 RED)
     (draw-rectangle 0 5 5 (- screen-height 10) RED)
     (draw-rectangle (- screen-width 5) 5 5 (- screen-height 10) RED)
     (draw-rectangle 0 (- screen-height 5) screen-width 5 RED)

     (draw-rectangle 10 10 250 113 (fade SKYBLUE 0.5))
     (draw-rectangle-lines 10 10 250 113 BLUE)

     (draw-text "Free 2D camera controls:" 20 20 10 BLACK)
     (draw-text "- Right/Left to move player" 40 40 10 DARKGRAY)
     (draw-text "- Mouse Wheel to Zoom in-out" 40 60 10 RED)
     (draw-text "- A / S to Rotate" 40 80 10 DARKGRAY)
     (draw-text "- R to reset Zoom and Rotation" 40 100 10 DARKGRAY)))
  (unless (window-should-close?) ;; Detect window close button or ESC key
    (loop)))

; De-Initialization
; ----------------------------------------------------------------------------------------
(close-window) ;; Close window and OpenGL contex
; ----------------------------------------------------------------------------------------
