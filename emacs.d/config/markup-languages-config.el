;;haml
;(install-elisp "https://github.com/nex3/haml-mode/raw/master/haml-mode.el")
(when (require 'haml-mode nil t)
  (add-to-list 'auto-mode-alist '("\\.haml$" . haml-mode))
  (add-to-list 'auto-mode-alist '("\\.scaml$" . haml-mode))
  (require 'flymake-haml)
  (add-hook 'haml-mode-hook 'flymake-haml-load))


;;sass
;(install-elisp "https://github.com/nex3/sass-mode/raw/master/sass-mode.el")
(when (require 'sass-mode nil t)
  (add-to-list 'auto-mode-alist '("\\.sass$" . sass-mode))
  (require 'flymake-sass)
  (add-hook 'sass-mode-hook 'flymake-sass-load))


;;scss
;(install-elisp "https://github.com/blastura/dot-emacs/raw/master/lisp-personal/scss-mode.el")
(when (require 'scss-mode nil t)
  (add-to-list 'auto-mode-alist '("\\.scss\\'" . scss-mode)))


;;rainbow-mode
;(install-elisp http://git.naquadah.org/?p=rainbow.git;a=blob_plain;f=rainbow-mode.el;hb=refs/heads/master)
(require 'rainbow-mode)
(let ((mode-hook))
  (dolist (mode-hook '(html-mode-hook
                       css-mode-hook
                       sass-mode-hook
                       scss-mode-hook))
    (add-hook mode-hook '(lambda () (rainbow-mode t)))))


;;zencoding
(add-to-load-path "co/zencoding")
(require 'zencoding-mode)
(add-hook 'sgml-mode-hook 'zencoding-mode)


;; http://d.hatena.ne.jp/hitode909/20111001/1317459632
(define-key zencoding-mode-keymap (kbd "C-j") 'indent-new-comment-line)
(define-key zencoding-mode-keymap (kbd "<C-return>") 'zencoding-expand-yas)
(define-key zencoding-mode-keymap (kbd "C-c C-m") 'zencoding-expand-yas)
(define-key zencoding-mode-keymap (kbd "C-c C-p") 'zencoding-expand-line)
