;;haml
;(install-elisp "https://github.com/nex3/haml-mode/raw/master/haml-mode.el")
(when (require 'haml-mode nil t)
  (add-to-list 'auto-mode-alist '("\\.haml$" . haml-mode)))


;;sass
;(install-elisp "https://github.com/nex3/sass-mode/raw/master/sass-mode.el")
(when (require 'sass-mode nil t)
  (add-to-list 'auto-mode-alist '("\\.sass$" . sass-mode)))


;;scss
;(install-elisp "https://github.com/blastura/dot-emacs/raw/master/lisp-personal/scss-mode.el")
(when (require 'scss-mode nil t)
  (add-to-list 'auto-mode-alist '("\\.scss\\'" . scss-mode)))


;;rainbow-mode
;(install-elisp http://git.naquadah.org/?p=rainbow.git;a=blob_plain;f=rainbow-mode.el;hb=refs/heads/master)
(add-hook 'html-mode-hook
          '(lambda ()
             (require 'rainbow-mode)
             (rainbow-mode 1)
             ))

(add-hook 'css-mode-hook
          '(lambda ()
             (require 'rainbow-mode)
             (rainbow-mode 1)
             ))

(add-hook 'sass-mode-hook
          '(lambda ()
             (require 'rainbow-mode)
             (rainbow-mode 1)
             ))

(add-hook 'scss-mode-hook
          '(lambda ()
             (require 'rainbow-mode)
             (rainbow-mode 1)
             ))

