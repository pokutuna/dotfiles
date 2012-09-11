(add-to-load-path "co/yasnippet")
(require 'yasnippet)

;; (add-to-list 'yas/extra-mode-hooks
;;              'js2-mode-hook)

(setq yas-snippet-dirs
      '("~/.emacs.d/mysnippets"
        "~/.emacs.d/co/yasnippet/snippets"))
(yas-reload-all)
(yas-global-mode 1)


;; dropdown-list.el from comment in yasnippet.el
(require 'dropdown-list)
(setq yas-prompt-functions '(yas-dropdown-prompt
                             yas-ido-prompt
                             yas-completing-prompt))


;; コメントやリテラルではスニペットを展開しない
(setq yas-buffer-local-condition
      '(or (not (or (string= "font-lock-comment-face"
                             (get-char-property (point) 'face))
                    (string= "font-lock-string-face"
                             (get-char-property (point) 'face))))
           '(require-snippet-condition . force-in-comment)))


;;; yasnippet展開中はflymakeを無効にする
(defvar flymake-is-active-flag nil)
(defadvice yas-expand-snippet
  (before inhibit-flymake-syntax-checking-while-expanding-snippet activate)
  (setq flymake-is-active-flag
        (or flymake-is-active-flag
            (assoc-default 'flymake-mode (buffer-local-variables))))
  (when flymake-is-active-flag
    (flymake-mode-off)))
(add-hook 'yas-after-exit-snippet-hook
          '(lambda ()
             (when flymake-is-active-flag
               (flymake-mode-on)
               (setq flymake-is-active-flag nil))))
