;; ~/.emacs.d から相対的に load-path を追加する
(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory (expand-file-name (concat user-emacs-directory path))))
        (add-to-list 'load-path default-directory)
        (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
            (normal-top-level-add-subdirs-to-load-path))))))

(add-to-load-path "elisp")


;; LANG
(setenv "LANG" "ja_JP.UTF-8")


;; package.el
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/") t)
(package-initialize)

;; PATH
(setq shell-file-name "/usr/local/bin/zsh")
(add-to-list 'exec-path "/usr/local/bin")
(setenv "PATH" (mapconcat 'identity exec-path ":"))


;; そのうちなくす or いい方法探す
(load-file "~/.emacs.d/elisp/init-helper-macro.el")

;; init-loader
(require 'init-loader)
(init-loader-load "~/.emacs.d/inits")

;; 0* : core global configs
;; 1* : util configs
;; 3* : basic extention configs
;; 5* : programming language configs
;; 9* : misc & other
