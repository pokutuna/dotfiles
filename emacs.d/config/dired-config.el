;; wdired
(require 'wdired)
(define-key dired-mode-map "r" ; dired中にrでリネーム
  'wdired-change-to-wdired-mode)


;; direx
;; http://cx4a.blogspot.jp/2011/12/popwineldirexel.html
(add-to-load-path "co/direx-el")
(require 'direx)
(require 'direx-project)
;; (global-set-key (kbd "C-x C-j") 'direx:jump-to-directory)
;; (global-set-key (kbd "C-x C-j") 'direx:jump-to-directory-other-window)
(global-set-key (kbd "C-x C-j") 'my:direx-jump-to-project-or-directory-other-window)

(defun my:direx-jump-to-project-or-directory-other-window ()
  (interactive)
  (if (direx-project:find-project-root-noselect
       (or buffer-file-name default-directory))
      (direx-project:jump-to-project-root-other-window)
    (direx:jump-to-directory-other-window)))



;; tramp
(require 'tramp)
(setq tramp-default-method "ssh")
(setq tramp-shell-prompt-pattern "^.*[#$%>] *")
