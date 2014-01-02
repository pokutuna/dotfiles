(require 'helm)
(require 'helm-config)
(require 'helm-command)

(setq
 helm-idle-delay 0.2
 helm-input-idle-delay 0.1
 helm-candidate-number-limit 200
 helm-quick-update t)

(helm-mode 1)

;; soruces
(setq helm-for-files-preferred-list
      '(helm-source-buffers-list
        helm-source-files-in-current-dir
        helm-source-recentf
        helm-source-bookmarks
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
(global-set-key (kbd "M-y") 'helm-show-kill-ring)
(global-set-key (kbd "M-x") 'helm-M-x)


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
(require 'helm-ls-git)
(global-set-key (kbd "C-M-;") 'helm-ls-git-ls)


;; helmコマンドで migemo を有効にする
(require 'helm-migemo)
(setq helm-migemize-command-idle-delay helm-idle-delay)
(helm-migemize-command helm-for-files)
