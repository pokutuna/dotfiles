(require 'go-mode)
(eval-after-load "go-mode"
  '(progn
     (require 'go-autocomplete)
     (add-hook 'go-mode-hook 'go-eldoc-setup)
     (add-hook 'before-save-hook 'gofmt-before-save)

     (when (require 'smartchr nil t)
       (define-key go-mode-map (kbd ":") (smartchr '(":" ":=")))
       )
     ))
