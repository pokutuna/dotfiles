(require 'typescript)
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-mode))

(when (require 'tide nil t)
  (add-hook 'typescript-mode-hook
            (lambda ()
              (tide-setup)
              (flycheck-mode t)
              (setq flycheck-check-syntax-automatically '(save mode-enabled))
              (eldoc-mode t)
              (company-mode-on))
            ))
