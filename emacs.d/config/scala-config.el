(add-to-list 'load-path "/usr/local/share/scala/misc/scala-tool-support/emacs")

(require 'scala-mode-auto)
(require 'scala-mode-constants)
(require 'scala-mode-feature)
(add-hook 'scala-mode-hook
            '(lambda ()
               (yas/minor-mode-on)
               (scala-mode-feature-electric-mode t)
               (define-key scala-mode-map "\C-c\C-a" 'scala-run-scala)
               (define-key scala-mode-map "\C-c\C-b" 'scala-eval-buffer)
               (define-key scala-mode-map "\C-c\C-r" 'scala-eval-region)
               ))


;; ensime
(add-to-list 'load-path (expand-file-name "~/.emacs.d/etc/ensime/elisp/"))
(require 'ensime)
(add-hook 'scala-mode-hook 'ensime-scala-mode-hook)

(defun my-ac-scala-mode ()
  (add-to-list 'ac-sources 'ac-source-dictionary)
  (add-to-list 'ac-sources 'ac-source-yasnippet)
  (add-to-list 'ac-sources 'ac-source-words-in-buffer)
  (add-to-list 'ac-sources 'ac-source-words-in-same-mode-buffers)
  (setq ac-sources (reverse ac-sources))
  )

(add-hook 'scala-mode-hook 'my-ac-scala-mode)
(add-hook 'ensime-mode-hook 'my-ac-scala-mode)


;; 改行とかのインデントマシにする
(defadvice scala-block-indentation (around improve-indentation-after-brace activate)
  (if (eq (char-before) ?\{)
      (setq ad-return-value (+ (current-indentation) scala-mode-indent:step))
    ad-do-it))
(defun scala-newline-and-indent ()
  (interactive)
  (delete-horizontal-space)
  (let ((last-command nil))
    (newline-and-indent))
  (when (scala-in-multi-line-comment-p)
    (insert "* ")))
(add-hook 'scala-mode-hook
          (lambda ()
            (define-key scala-mode-map (kbd "RET") 'scala-newline-and-indent)))


;; parenthesis
(add-hook 'scala-mode-hook
          (lambda ()
            (parenthesis-register-keys "{('\"[" scala-mode-map)
            ))