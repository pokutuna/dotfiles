;; helm が C-x C-j 上書きするのを抑制する
(setq dired-bind-jump nil)

(require 'helm)
(require 'helm-config)
(require 'helm-command)

(helm-mode 1)

(setq
 helm-idle-delay 0.02
 helm-input-idle-delay 0.02
 helm-candidate-number-limit 200
 helm-quick-update t
 helm-buffer-max-length 35
 )

;; soruces
(setq helm-for-files-preferred-list
      '(helm-source-buffers-list
        helm-source-files-in-current-dir
        helm-source-recentf
        ;; helm-source-bookmarks
        ;; helm-source-file-cache
        ;; helm-source-locate
        ))

;; keybinds
(global-set-key (kbd "C-;") 'helm-for-files)
(global-set-key [f7] 'helm-for-files)
(define-key helm-map (kbd "C-k") 'kill-line)
(define-key helm-map (kbd "C-h") 'delete-backward-char)
(define-key helm-map (kbd "C-p") 'helm-previous-line)
(define-key helm-map (kbd "C-n") 'helm-next-line)
(define-key helm-map (kbd "C-v") 'helm-next-page)
(define-key helm-map (kbd "M-v") 'helm-previous-page)
(define-key helm-map (kbd "M-n") 'helm-next-source)
(define-key helm-map (kbd "M-p") 'helm-previous-source)

;; override default actions
(global-set-key (kbd "M-y")     'helm-show-kill-ring)
(global-set-key (kbd "M-x")     'helm-M-x)
(global-set-key (kbd "C-x C-f") 'helm-find-files)
(global-set-key (kbd "C-x C-r") 'helm-recentf)
(global-set-key (kbd "C-c i")   'helm-imenu)
(global-set-key (kbd "C-x b")   'helm-buffers-list)


;; helm で TAB でファイル名の補完する(action を使わない)
(define-key helm-read-file-map (kbd "TAB") 'helm-execute-persistent-action)
(define-key helm-find-files-map (kbd "TAB") 'helm-execute-persistent-action)
(define-key helm-find-files-map (kbd "C-h") 'delete-backward-char)


;; features
(global-set-key (kbd "C-M-z") 'helm-resume) ;; 間違って選択する前に戻れる
(global-set-key (kbd "C-o") 'helm-occur)


;; helm-descbinds
;; C-c C-h で keybind 表示するやつ
(require 'helm-descbinds)
(helm-descbinds-mode)


;; helm + git
(require 'helm-git-grep)
(global-set-key (kbd "C-M-o") 'helm-git-grep)
(require 'helm-git-files)
(global-set-key (kbd "C-M-;") 'helm-git-files)


;; helm-ack
(require 'helm-ack)
(global-set-key (kbd "C-S-o") 'helm-ack)


;; helmコマンドで migemo を有効にする
;; (require 'helm-migemo)
;; (setq helm-migemize-command-idle-delay helm-idle-delay)
;; (helm-migemize-command helm-for-files)
