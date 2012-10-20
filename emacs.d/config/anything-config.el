;;(auto-install-batch "anything")
(require 'anything-config)
(setq
 anything-idle-delay 0.2
 anything-input-idle-delay 0.1
 anything-candidate-number-limit 100
 anything-quick-update t
 anything-enable-shortcuts 'alphabet
 )

;; keybinds
(global-set-key (kbd "C-;") 'anything)
(custom-set-variables '(anything-command-map-prefix-key (kbd "C-c C-f")))
(define-key global-map (kbd "C-c C-f SPC") 'anything-execute-anything-command)
(define-key global-map [f7] 'anything-filelist+)
(define-key global-map (kbd "C-c C-c") 'anything-filelist+)
;;(define-key global-map (kbd "C-c C-c") 'anything-for-files)
(global-set-key (kbd "C-S-p") 'anything-project)
(global-set-key (kbd "C-M-p") 'anything-project)
(define-key anything-map (kbd "C-p") 'anything-previous-line)
(define-key anything-map (kbd "C-n") 'anything-next-line)
(define-key anything-map (kbd "C-v") 'anything-next-page)
(define-key anything-map (kbd "M-v") 'anything-previous-page)
(define-key anything-map (kbd "M-n") 'anything-next-source)
(define-key anything-map (kbd "M-p") 'anything-previous-source)
(define-key anything-map (kbd "C-h") 'delete-backward-char)


(setq anything-sources
      (list
       anything-c-source-pyong-last-jumped
       anything-c-source-pyong
       anything-c-source-buffers ; C-b使う
       anything-c-source-recentf
       anything-c-source-files-in-current-dir
       anything-c-source-mac-spotlight
       anything-c-source-bookmarks
       anything-c-source-complex-command-history
       ))


;; いろいろ読み込む
(require 'anything-startup)
(setq anything-su-or-sudo "sudo")


;; migemoでマッチ
(require 'anything-match-plugin)
(and (equal current-language-environment "Japanese")
     (executable-find "cmigemo")
     (require 'anything-migemo))


;; よくわからん たぶんC-bとかM-xとかの補完
(require 'anything-complete)
;;(anything-read-string-mode 1)
(anything-lisp-complete-symbol-set-timer 150)
(require 'anything-show-completion nil t)


;; auto-installの対象をwikiとかから補完
(when (require 'auto-install nil t)
  (require 'anything-auto-install nil t))


;; helpをanythingで表示、選んで実行できる
(require 'descbinds-anything)
(descbinds-anything-install)
(define-key global-map (kbd "C-x C-h") 'descbinds-anything)


;; M-yでkill-ringをanything選択
(global-set-key (kbd "M-y") 'anything-show-kill-ring)
(setq anything-kill-ring-threshold 0)


;;anything-projectでgit等のバージョン管理対象からanything
;;(install-elisp "http://github.com/imakado/anything-project/raw/master/anything-project.el")
(require 'anything-project nil t)
(setq ap:project-files-filters
      (list
       (lambda (files) (remove-if 'file-directory-p files))
       (lambda (files) (remove-if '(lambda (file) (string-match-p "~$" file)) files))
       (lambda (files) (remove-if '(lambda (file) (string-match-p "\\.class$" file)) files))
       (lambda (files) (remove-if '(lambda (file) (string-match-p "target/" file)) files)) ;; for sbt
       ))


;;moccurをanythingで
;;(install-elisp "http://svn.coderepos.org/share/lang/elisp/anything-c-moccur/trunk/anything-c-moccur.el")
(require 'anything-c-moccur)
(setq
 anything-c-moccur-anything-idle-delay 0.1
 lanything-c-moccur-highlight-info-line-flag t
 anything-c-moccur-enable-auto-look-flag t
 anything-c-moccur-enable-initial-pattern t)
(global-set-key (kbd "C-o") 'anything-c-moccur-occur-by-moccur)
(global-set-key (kbd "C-M-o") 'anything-c-moccur-dmoccur) ;ディレクトリ
(add-hook 'dired-mode-hook ;dired
          '(lambda ()
             (local-set-key (kbd "O") 'anything-c-moccur-dired-do-moccur-by-moccur)))
