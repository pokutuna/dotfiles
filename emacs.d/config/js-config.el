(add-to-load-path "co/js2-mode")

;; indent 2 spaces
;; (setq-default c-basic-offset 4)
(setq-default c-basic-offset 2)

;; patched js2
;; http://d.hatena.ne.jp/sabottenda/20110526/1306411032
(autoload 'js2-mode "js2-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

(add-hook 'js2-mode-hook
          '(lambda ()
             (define-key js2-mode-map "\M-n" 'next-error)
             ))



;; (defun js-mode-hooks ()
;;   (setq flymake-jsl-mode-map 'js-mode-map)
;;   (when (require 'flymake-jsl nil t)
;;     (setq flymake-check-was-interrupted t)
;;     (flymake-mode t)))
;; (add-hook 'js-mode-hook 'js-mode-hooks)