;; general
(add-hook 'c-mode-common-hook
          '(lambda ()
             (c-toggle-auto-hungry-state 1)
             (define-key c-mode-base-map "\C-m" 'newline-and-indent)
             (c-set-style "k&r")
             (setq indent-tabs-mode nil)
             (setq c-basic-offset 2)
             (parenthesis-register-keys "{('\"[" c-mode-map)
             ))
