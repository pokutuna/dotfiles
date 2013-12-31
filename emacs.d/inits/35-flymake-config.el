(require 'flymake)

(setq flymake-gui-warnings-enabled nil) ; GUIの警告は表示しない
;(add-hook 'find-file-hook 'flymake-find-file-hook) ; 全てのファイルで flymakeを有効化


;; keybind
(add-hook
 'flymake-mode-hook
 '(lambda ()
    (local-set-key (kbd "M-n") 'flymake-goto-next-error)
    (local-set-key (kbd "M-p") 'flymake-goto-prev-error)))
