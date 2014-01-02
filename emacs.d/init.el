;; ~/.emacs.d から相対的に load-path を追加する
(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory (expand-file-name (concat user-emacs-directory path))))
        (add-to-list 'load-path default-directory)
        (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
            (normal-top-level-add-subdirs-to-load-path))))))

(add-to-load-path "elisp")


;; PATH
(setq shell-file-name "/usr/local/bin/zsh")
(add-to-list 'exec-path "/usr/local/bin")
(setenv "PATH" (mapconcat 'identity exec-path ":"))


;; LANG
(setenv "LANG" "ja_JP.UTF-8")


;; package.el
;; cl-lib に依存したものが package.el で load する package に
;; 含まれている(helm)ので、先に load しておく必要がある
(load "~/.emacs.d/elpa/cl-lib-0.3/cl-lib")
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/") t)
(package-initialize)


(load-file "~/.emacs.d/config/init-helper-macro.el") ;;

;; init-loader
(require 'init-loader)
(init-loader-load "~/.emacs.d/inits")

;; 0* : core global configs
;; 1* : util configs
;; 3* : basic extention configs
;; 5* : programming language configs
;; 9* : misc & other


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
