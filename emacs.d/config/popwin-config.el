(add-to-load-path "co/popwin-el")
(require 'popwin)
(setq display-buffer-function 'popwin:display-buffer)
(setq popwin:popup-window-height 0.5)


;; anything
(setq anything-samewindow nil)
(push '("*anything*" :height 0.5) popwin:special-display-config)


;; dired
(push '(dired-mode :position top) popwin:special-display-config)