(setq initial-major-mode 'emacs-lisp-mode)
(add-to-list 'auto-mode-alist '("\\.el$" . emacs-lisp-mode))

(require 'lispxmp)
(define-key emacs-lisp-mode-map (kbd "C-c C-d") 'lispxmp)

(add-hook-fn 'emacs-lisp-mode-hook
             ;; parenthesis.elの補完を潰したい
             (define-key emacs-lisp-mode-map (kbd "'")
               (lambda () (interactive) (insert "'")))
             )

;; paredit
(require 'paredit)
(let ((mode-hook))
  (dolist (mode-hook '(emacs-lisp-mode-hook
                       lisp-interaction-mode-hook
                       lisp-mode-hook
                       ielm-mode-hook))
    (add-hook mode-hook 'enable-paredit-mode)))


;; auto byte compile
(require 'auto-async-byte-compile)
(setq auto-async-byte-compile-exclude-files-regexp "/inits/\\|/config/\\|/junk/\\|init.el")
(add-hook 'emacs-lisp-mode-hook 'enable-auto-async-byte-compile-mode)
