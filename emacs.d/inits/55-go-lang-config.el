(require 'go-mode)
(eval-after-load "go-mode"
  '(progn
     (require 'go-autocomplete)
     (add-hook 'go-mode-hook 'go-eldoc-setup)

     ;; `goimports` runs `gofmt` & fixes import
     ;; (add-hook 'before-save-hook 'gofmt-before-save)

     (when (require 'smartchr nil t)
       (define-key go-mode-map (kbd ":") (smartchr '(":" ":=")))
       )

     ;; `goimports` required
     ;; $ go get code.google.com/p/go.tools/cmd/goimports
     (when (executable-find "goimports")
       (setq gofmt-command "goimports")
       (add-hook 'before-save-hook 'gofmt-before-save)
       )
     ))
