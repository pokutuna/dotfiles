(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.json$" . js2-mode))

(lazyload (js2-mode) "js2-mode"
          ;; (setq-default js2-basic-offset 2)
          (setq-default js2-basic-offset 4)
          )

(add-hook-fn 'js2-mode-hook
             (define-key js2-mode-map "\M-n" 'next-error)

             ;; requires jsonlint, `$ npm install jsonlint -g`
             ;; TODO こういうの一発でいれたい
             (flymake-json-maybe-load)

             (add-to-list 'align-rules-list
                          '(colon-key-value
                            (regexp . ":\\(\\s-*\\)")
                            (modes  . '(js2-mode))
                            ))
             )


;; (defun js-mode-hooks ()
;;   (setq flymake-jsl-mode-map 'js-mode-map)
;;   (when (require 'flymake-jsl nil t)
;;     (setq flymake-check-was-interrupted t)
;;     (flymake-mode t)))
;; (add-hook 'js-mode-hook 'js-mode-hooks)
