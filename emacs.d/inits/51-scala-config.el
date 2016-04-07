(require 'scala-mode2)

(require 'ensime)
(add-hook 'scala-mode-hook 'ensime-mode)
(setq ensime-completion-style 'auto-complete)
(setq ensime-goto-test-config-defaults
      (plist-merge ensime-goto-test-config-defaults
                   '(:test-class-suffixes ("Spec" "Test" "Check"))
                   ))

(add-hook 'scala-mode-hook '(lambda ()
  (yas/minor-mode-on)
  ;; parenthesis
  (parenthesis-register-keys "{(\"[" scala-mode-map)

  (local-set-key (kbd "C-m") 'newline-and-indent)
  (local-set-key (kbd "C-j") 'reindent-then-newline-and-indent)
))

; 動くか確認
(defun my-ac-scala-source ()
  (add-to-list 'ac-sources 'ac-source-dictionary)
  (add-to-list 'ac-sources 'ac-source-yasnippet)
  (add-to-list 'ac-sources 'ac-source-words-in-buffer)
  ;; (add-to-list 'ac-sources 'ac-source-words-in-same-mode-buffers)
  (setq ac-sources (reverse ac-sources))
  )

(add-hook 'scala-mode-hook 'my-ac-scala-source)
(add-hook 'scala-mode-hook 'ensime-scala-mode-hook)
(add-hook 'ensime-mode-hook 'my-ac-scala-source)
