(transient-mark-mode t) ;regionに色を付ける


;; color-theme & 行ハイライト
(if window-system ;window-systemの時だけ
    (progn
      (require 'color-theme nil t)
      (color-theme-initialize)
      ;;(color-theme-clarity)
      ;;(color-theme-euphoria)
      (color-theme-gnome2)
      ;;(color-theme-gray30)
      ;;(color-theme-robin-hood)
      ;;(color-theme-subtle-hacker)
      ;;(color-theme-dark-laptop)
      ;;(color-theme-hober)

      ;; (require 'zenburn-theme)

      (defface my-hl-line-face ;themeの背景に応じたカーソル行強調
        '((((class color) (background dark))
           (:background "MidnightBlue" t))
          (((class color) (background light))
           (:background "LightGoldenrodYellow" t))
          (t (:bold t)))
        "hl-line's my face")
      (setq hl-line-face 'my-hl-line-face)
      (global-hl-line-mode t))
  )


;; paren
(show-paren-mode t) ;カッコ強調表示
(setq show-paren-delay 0) ;カッコ強調表示ディレイ0
(setq show-paren-style 'expression) ;カッコ内強調表示
(set-face-background 'show-paren-match-face nil) ;カッコ内背景強調オフ
(set-face-underline-p 'show-paren-match-face "yellow") ;カッコ内アンダーライン


;; カーソルの縦軸ハイライト
(require 'col-highlight)
(col-highlight-set-interval 1)
(col-highlight-toggle-when-idle t)
(setq col-highlight-face 'my-hl-line-face)


;; ;; EOF以降を強調表示する
;; (setq-default indicate-empty-lines t)
;; (setq-default indicate-buffer-boundaries 'right)


;; 全角SPC、tab、行末スペースを強調表示
(defface my-face-b-1 '((t (:background "medium aquamarine"))) nil)
(defface my-face-b-2 '((t (:background "gray26"))) nil)
(defface my-face-u-1 '((t (:foreground "red" :underline t))) nil)
(defvar my-face-b-1 'my-face-b-1)
(defvar my-face-b-2 'my-face-b-2)
(defvar my-face-u-1 'my-face-u-1)
(defadvice font-lock-mode (before my-font-lock-mode ())
  (font-lock-add-keywords
   major-mode
   '(
     ("　" 0 my-face-b-1 append)
     ("\t" 0 my-face-b-2 append)
     ("[ ]+$" 0 my-face-u-1 append)
     )))
(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
(ad-activate 'font-lock-mode)
(add-hook 'find-file-hooks '(lambda ()
                              (if font-lock-mode nil
                                (font-lock-mode t))) t)


;; hiwin-mode アクティブなwindowを強調
;; (require 'hiwin)
;; (hiwin-mode)


;; 表示Font
(if window-system
    (progn
      (set-face-attribute 'default nil
                          ;:family "Inconsolata"
                          ;:family "Consolas"
                          :family "VL Gothic"
                          ;:family "Ricty"
                          :height 130)
      (set-fontset-font "fontset-default"
                        'japanese-jisx0208
                        '("VL Gothic" . "iso10646-1"))
      (set-fontset-font "fontset-default"
                        'katakana-jisx0201
                        '("VL Gothic" . "iso10646-1"))
      )
  )



;; hitode氏カーソル
(set-cursor-color "orange")
;(setq blink-cursor-interval 0.05)
;(setq blink-cursor-interval 0.5)
(setq blink-cursor-interval 0.2)
(setq blink-cursor-delay 0.2)
(blink-cursor-mode 1)
