(add-hook 'c-mode-common-hook
          '(lambda ()
             (c-toggle-auto-hungry-state 1)
             (define-key c-mode-base-map "\C-m" 'newline-and-indent)))
