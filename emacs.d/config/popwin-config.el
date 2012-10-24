(require 'popwin)
(setq display-buffer-function 'popwin:display-buffer)
;; (setq display-buffer-function 'popwin:special-display-popup-window)
(setq popwin:popup-window-height 0.5)


;; anything
(setq anything-samewindow nil)
(push '("anything" :regexp t :height 0.5) popwin:special-display-config)


;; dired
(push '(dired-mode :height 0.5) popwin:special-display-config)


;; direx
;; direx:direx-modeのバッファをウィンドウ左辺に幅25でポップアップ
;; :dedicatedにtを指定することで、direxウィンドウ内でのバッファの切り替えが
;; ポップアップ前のウィンドウに移譲される
(push '(direx:direx-mode :position left :width 25 :dedicated t)
      popwin:special-display-config)


;; backtrace
(push '("*Backtrace*" :height 0.3) popwin:special-display-config)


;; text-translator
(push '("*translated*" :height 0.3 :stick t) popwin:special-display-config)


;; undo-tree
(push '(" *undo-tree*" :width 0.3 :position right) popwin:special-display-config)


;; auto-async-byte-compile
(push '(" *auto-async-byte-compile*" :height 0.3 :stick t) popwin:special-display-config)


(push '("*Remember*" :height 0.4 :stick t) popwin:special-display-config)
