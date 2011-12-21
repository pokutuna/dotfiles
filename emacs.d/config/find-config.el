;; isearch と anything-c-moccurを交換
(global-set-key (kbd "C-o") 'isearch-forward)
(global-set-key (kbd "C-s") 'anything-c-moccur-occur-by-moccur)


;;ack
(defun ack ()
  (interactive)
  (let ((grep-find-command "ack --nocolor --nogroup "))
    (call-interactively 'grep-find)))


;;grep
(require 'grep) ;lgrepで直下をgrep、rgrepで再帰的に


;;grep-edit
;;(install-elisp "http://www.emacswiki.org/emacs/download/grep-edit.el")
(require 'grep-edit) ;C-c C-e で編集を反映 C-x s ! で全部保存


;;moccur
;;(install-elisp "http://www.emacswiki.org/emacs/download/color-moccur.el")
;;(install-elisp "http://www.emacswiki.org/emacs/download/moccur-edit.el")
(when (require 'color-moccur nil t)
  (define-key global-map (kbd "M-o") 'occur-by-moccur) ;M-o occur-by-moccur
  (setq moccur-split-word t)
  (add-to-list 'dmoccur-exclusion-mask "^#.+#$")
  (require 'moccur-edit nil t)
  (when (and (executable-find "cmigemo")
             (require 'migemo nil t))
    (setq moccur-user-migemo t)))


;;migemo
(when (and (executable-find "cmigemo")
           (require 'migemo nil t))
  (setq migemo-command "cmigemo")
  (setq migemo-options '("-q" "--emacs" "-i" "\a"))
  (setq migemo-dictionary (expand-file-name "~/.emacs.d/etc/migemo/migemo-dict"))
  (setq migemo-user-dictionary nil)
  (setq migemo-regex-dictionary nil)
  (setq migemo-user-pattern-alist t)
  (setq migemo-use-frequent-pattern-alist t)
  (setq migemo-pattern-alist-length 1000)
  (setq migemo-coding-system 'utf-8-unix)
  (migemo-init))


;;search region リージョン選択中にC-sで選択範囲でfind
(defadvice isearch-mode (around isearch-mode-default-string (forward &optional regexp op-fun recursive-edit word-p) activate)
  (if (and transient-mark-mode mark-active (not (eq (mark) (point))))
      (progn
        (isearch-update-ring (buffer-substring-no-properties (mark) (point)))
        (deactivate-mark)
        ad-do-it
        (if (not forward)
            (isearch-repeat-backward)
          (goto-char (mark))
          (isearch-repeat-forward)))
    ad-do-it))
