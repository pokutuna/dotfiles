(add-to-load-path "co/popwin-el")
(require 'popwin)
(setq display-buffer-function 'popwin:display-buffer)
;; (setq display-buffer-function 'popwin:special-display-popup-window)
(setq popwin:popup-window-height 0.5)


;; anything
(setq anything-samewindow nil)
(push '("anything" :regexp t :height 0.5) popwin:special-display-config)


;; dired
(push '(dired-mode :height 0.5) popwin:special-display-config)


;; backtrace
(push '("*Backtrace*" :height 0.3) popwin:special-display-config)


;; text-translator
(push '("*translated*" :height 0.3 :stick t) popwin:special-display-config)


;; undo-tree
(push '(" *undo-tree*" :width 0.3 :position right) popwin:special-display-config)
