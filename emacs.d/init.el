;; ~/.emacs.dから相対的にload-path追加関数
(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory (expand-file-name (concat user-emacs-directory path))))
        (add-to-list 'load-path default-directory)
        (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
            (normal-top-level-add-subdirs-to-load-path))))))

(add-to-load-path "elisp")


;; PATH
(setq shell-file-name "/usr/local/bin/zsh") ;;zshenv見に行く
(add-to-list 'exec-path "/usr/local/bin")
(setenv "PATH" (mapconcat 'identity exec-path ":"))


;; LANG
(setenv "LANG" "ja_JP.UTF-8")


;; package.el
(require 'package)

(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/") t)
(package-initialize)


;; init-loader
(require 'init-loader)
(init-loader-load "~/.emacs.d/inits")



(load-file "~/.emacs.d/config/init-helper-macro.el")
(load-file "~/.emacs.d/config/basic-config.el")
(load-file "~/.emacs.d/config/darwin-config.el")
(load-file "~/.emacs.d/config/face-config.el")
(load-file "~/.emacs.d/config/util-config.el")
(load-file "~/.emacs.d/config/find-config.el")
(load-file "~/.emacs.d/config/undo-redo-config.el")
(load-file "~/.emacs.d/config/dired-config.el") ;; tramp

(load-file "~/.emacs.d/config/auto-complete-config.el")
(load-file "~/.emacs.d/config/anything-config.el")
(load-file "~/.emacs.d/config/completion-config.el") ;; smartchr.el parenthesis.el
(load-file "~/.emacs.d/config/yasnippet-config.el")
(load-file "~/.emacs.d/config/popwin-config.el")
(load-file "~/.emacs.d/config/flymake-config.el")

;; languages
(load-file "~/.emacs.d/config/ruby-config.el")
(load-file "~/.emacs.d/config/scala-config.el")
(load-file "~/.emacs.d/config/perl-config.el")
(load-file "~/.emacs.d/config/js-config.el")
(load-file "~/.emacs.d/config/coffee-config.el")
(load-file "~/.emacs.d/config/c-lang-config.el")
(load-file "~/.emacs.d/config/haskell-config.el")
(load-file "~/.emacs.d/config/lisp-config.el")
;; (load-file "~/.emacs.d/config/r-lang-config.el")
(load-file "~/.emacs.d/config/markup-languages-config.el")

;; other
(load-file "~/.emacs.d/config/tex-config.el")
(load-file "~/.emacs.d/config/org-remember-config.el")
(load-file "~/.emacs.d/config/octave-config.el")
(load-file "~/.emacs.d/config/english-config.el")
