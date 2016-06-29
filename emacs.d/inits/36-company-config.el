(require 'company)

(setq company-minimum-prefix-length 1)
(setq company-selection-wrap-around t)

;; keybind
(define-key company-mode-map (kbd "M-i") 'company-complete)
(define-key company-active-map (kbd "C-h") nil)
(define-key company-active-map (kbd "<tab>") 'company-complete-common-or-cycle)
(define-key company-active-map (kbd "M-d") 'company-show-doc-buffer)

;; faces like auto-complete.el
;; http://qiita.com/wh11e7rue/items/6ffe27797c3eac13b67e
(add-hook
 'company-mode-hook
 '(lambda ()
    (copy-face 'popup-menu-face 'company-tooltip)
    (copy-face 'popup-menu-face 'company-tooltip-common)
    (copy-face 'popup-menu-selection-face 'company-tooltip-selection)
    (copy-face 'popup-menu-selection-face 'company-tooltip-common-selection)
    (copy-face 'popup-menu-summary-face 'company-tooltip-annotation)
    (copy-face 'popup-menu-selection-face 'company-tooltip-annotation-selection)
    (copy-face 'popup-scroll-bar-background-face 'company-scrollbar-bg)
    (copy-face 'popup-scroll-bar-foreground-face 'company-scrollbar-fg)
    (copy-face 'ac-completion-face 'company-preview)
    (copy-face 'ac-completion-face 'company-preview-common)
    )
 )
