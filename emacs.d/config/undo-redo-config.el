;:redo C-'でリドゥ
;; (when (require 'redo+ nil t))

(global-set-key (kbd "C-'") 'redo)


;;undo-hist バッファを保存して消してもアンドゥで戻れる
;;(install-elisp "http://cx4a.org/pub/undohist.el")
(when (require 'undohist nil t)
  (undohist-initialize))


;;undo-tree
(require 'undo-tree)
(global-undo-tree-mode)
;;C-x u でundoの履歴を視覚化したバッファがでる、移動してqで抜ければその状態まで戻る


;;point-undo
;;(install-elisp "http://www.emacswiki.org/cgi-bin/wiki/download/point-undo.el")
(when (require 'point-undo nil t)
  (define-key global-map [f6] 'point-undo)
  (define-key global-map [f8] 'point-redo))
