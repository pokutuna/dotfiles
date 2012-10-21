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
(setq shell-file-name "/usr/local/bin/zsh");;zshenv見に行く
(add-to-list 'exec-path "/opt/local/bin")
(add-to-list 'exec-path "/usr/local/bin")
(setenv "PATH" (mapconcat 'identity exec-path ":"))


;; LANG
(setenv "LANG" "ja_JP.UTF-8")


;; package.el
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)
