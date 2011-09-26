(require 'yasnippet)
(require 'yasnippet-bundle)
(yas/initialize)
(yas/load-directory "~/.emacs.d/etc/snippets")


;; my snippets
(defvar my-snippet-directories
  (list (expand-file-name "~/.emacs.d/etc/mysnippets")))


;; このコマンドを実行することで、変更・追加が反映される。
;; あとから読みこんだ自分用のものが優先される。
(defun yas/load-all-directories ()
  (interactive)
  (yas/reload-all)
  (mapc 'yas/load-directory-1 my-snippet-directories))
(yas/load-all-directories)


;;http://tech.lampetty.net/tech/index.php/archives/384
(require 'dropdown-list)
(setq yas/text-popup-function #'yas/dropdown-list-popup-for-template)
;; コメントやリテラルではスニペットを展開しない
(setq yas/buffer-local-condition
      '(or (not (or (string= "font-lock-comment-face"
                             (get-char-property (point) 'face))
                    (string= "font-lock-string-face"
                             (get-char-property (point) 'face))))
           '(require-snippet-condition . force-in-comment)))


;;; yasnippet展開中はflymakeを無効にする
(defvar flymake-is-active-flag nil)
(defadvice yas/expand-snippet
  (before inhibit-flymake-syntax-checking-while-expanding-snippet activate)
  (setq flymake-is-active-flag
        (or flymake-is-active-flag
            (assoc-default 'flymake-mode (buffer-local-variables))))
  (when flymake-is-active-flag
    (flymake-mode-off)))
(add-hook 'yas/after-exit-snippet-hook
          '(lambda ()
             (when flymake-is-active-flag
               (flymake-mode-on)
               (setq flymake-is-active-flag nil))))

