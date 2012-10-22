(require 'lispxmp)
(define-key emacs-lisp-mode-map (kbd "C-c C-d") 'lispxmp)


 ; parenthesis.elの補完を潰したい
(add-hook 'emacs-lisp-mode-hook
          '(lambda ()
            (define-key emacs-lisp-mode-map (kbd "'")
              (lambda () (interactive) (insert "'")))
            ))



(require 'paredit)
(let ((mode-hook))
  (dolist (mode-hook '(emacs-lisp-mode-hook
                       lisp-interaction-mode-hook
                       lisp-mode-hook
                       ielm-mode-hook))
    (add-hook mode-hook 'enable-paredit-mode)))


;; auto byte compile
(require 'auto-async-byte-compile)
(setq auto-async-byte-compile-exclude-files-regexp "/config/\\|/junk/\\|init.el")
(add-hook 'emacs-lisp-mode-hook 'enable-auto-async-byte-compile-mode)


;; ;; eldoc
;; (let ((mode-hook))
;;   (dolist (mode-hook) '())
;;   )
