;;haml
;(install-elisp "https://github.com/nex3/haml-mode/raw/master/haml-mode.el")
(add-to-list 'auto-mode-alist '("\\.haml$" . haml-mode))
(add-to-list 'auto-mode-alist '("\\.scaml$" . haml-mode))
(lazyload (haml-mode) "haml-mode"
          (require 'flymake-haml))
(add-hook 'haml-mode-hook 'flymake-haml-load)


;; slim
(add-to-list 'auto-mode-alist '("\\.slim$" . slim-mode))
(lazyload (slim-mode) "slim-mode")


;;sass
;(install-elisp "https://github.com/nex3/sass-mode/raw/master/sass-mode.el")
(add-to-list 'auto-mode-alist '("\\.sass$" . sass-mode))
(lazyload (sass-mode) "sass-mode"
          (require 'flymake-sass))
(add-hook 'sass-mode-hook 'flymake-sass-load)


;;scss
;(install-elisp "https://github.com/blastura/dot-emacs/raw/master/lisp-personal/scss-mode.el")
(add-to-list 'auto-mode-alist '("\\.scss\\'" . scss-mode))
(lazyload (scss-mode) "scss-mode")


;;less
(setq less-css-compile-at-save nil)

;;rainbow-mode
;(install-elisp http://git.naquadah.org/?p=rainbow.git;a=blob_plain;f=rainbow-mode.el;hb=refs/heads/master)
(require 'rainbow-mode)
(let ((mode-hook))
  (dolist (mode-hook '(html-mode-hook
                       css-mode-hook
                       sass-mode-hook
                       scss-mode-hook))
    (add-hook mode-hook '(lambda () (rainbow-mode t)))))


;; template-toolkit
(add-to-list 'auto-mode-alist '("\\.tt$" . tt-mode))
(lazyload (tt-mode) "tt-mode")



;;zencoding
(add-to-load-path "co/zencoding")

(lazyload
 (sgml-mode) "zencoding-mode"
 (require 'zencoding-mode)
 ;; http://d.hatena.ne.jp/hitode909/20111001/1317459632
 (define-key zencoding-mode-keymap (kbd "C-j") 'indent-new-comment-line)
 (define-key zencoding-mode-keymap (kbd "<C-return>") 'zencoding-expand-yas)
 (define-key zencoding-mode-keymap (kbd "C-c C-m") 'zencoding-expand-yas)
 (define-key zencoding-mode-keymap (kbd "C-c C-p") 'zencoding-expand-line)

 ;; with mark-multiple.el
 (require 'rename-sgml-tag)
 (define-key sgml-mode-map (kbd "C-c C-r") 'rename-sgml-tag)
 )

(add-hook 'sgml-mode-hook 'zencoding-mode)
