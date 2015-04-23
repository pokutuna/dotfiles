;; window
(setq inhibit-startup-message t) ;スタートアップメッセージ消す
(menu-bar-mode 0) ;メニューバー無し
(tool-bar-mode 0) ;ツールバー無し
(setq frame-title-format (format "%%f - emacs@%s" (system-name))) ;タイトルバーにパス表示
(display-time) ;バーに時刻表示
(column-number-mode t) ;バーにカーソル位置表示
(blink-cursor-mode t) ;カーソル点滅
;(global-linum-mode t) ;行番号表示


(cd "~/") ;カレントディレクトリをHOMEに

;(setq initial-scratch-message nil) ;*scratch* の初期メッセージ消す

(setq line-move-visual t) ;物理行移動

(setq completion-ignore-case t) ;ファイル名補完で大文字小文字を区別しない

(global-auto-revert-mode 1) ;他がファイルしたらバッファを自動で再読み込み

(fset 'yes-or-no-p 'y-or-n-p) ; yes-noをy-nに置き換え

(delete-selection-mode 1) ;リージョンをC-hで削除

;(setq kill-whole-line t) ;kill-lineで行末の改行文字も削除

(setq kill-ring-max 1000) ;kill-ring1000件覚える

(define-key global-map [ns-drag-file] 'ns-find-file) ;drag&dropで開く


; server start for emacs-client
(require 'server)
(unless (server-running-p)
  (server-start))

;; charset
(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)


;; basic keybind
(global-set-key (kbd "C-h") 'delete-backward-char) ;C-hでBS
(global-set-key (kbd "C-x ?") 'help-command) ;C-x ? をhelp-command
(global-set-key (kbd "C-Q") 'quoted-insert) ;C-q はランチャに割り当てる


;; 画面外の文字は折り返しして表示
(setq truncate-lines nil)
(setq truncate-partial-width-windows nil)
(global-set-key "\C-c\C-l" 'toggle-truncate-lines) ;C-c C-l で行折り返しon/off


;;indent
(setq-default tab-width 2) ;タブ幅を2に設定
(setq tab-stop-list '(2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40)) ;タブ幅の倍数を設定
(setq-default indent-tabs-mode nil) ;タブではなくスペースを使う
(setq indent-line-function 'indent-relative-maybe)
(setq-default fill-column 80) ; M-q などで折り返す幅


;;backup
(setq make-backup-files t)
(setq backup-directory-alist '((".*" . "~/.emacs.d/backup"))) ;backup先
(setq version-control t)
(setq delete-old-versions t)
(setq vc-make-backup-files t)


;;recentf
(setq recentf-max-menu-items 50)
(setq recentf-max-saved-items 100)

;; カーソルを前回編集していた位置に戻す
(load "saveplace")
(setq-default save-place t)


;;<1>をディレクトリ名にする
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)
;; (setq uniquify-buffer-name-style 'post-forward-angle-brackets)
(setq uniquify-min-dir-content 1)


;; C-x p を C-x o の逆順にwindow切り替える
(define-key ctl-x-map "p"
  #'(lambda (arg) (interactive "p") (other-window (- arg))))


;; C-c [hjkl] で window切り替え
(setq windmove-wrap-around t)
(define-key global-map (kbd "C-c j") 'windmove-down)
(define-key global-map (kbd "C-c k") 'windmove-up)
(define-key global-map (kbd "C-c h") 'windmove-left)
(define-key global-map (kbd "C-c l") 'windmove-right)


;; kill-ring に同じ内容の文字列を複数入れない
(defadvice kill-new (before ys:no-kill-new-duplicates activate)
  (setq kill-ring (delete (ad-get-arg 0) kill-ring)))


;; clipbord 共有
(setq x-select-enable-clipboard t)

;; osのクリップボード監視してkill-ringに入れる
;; http://d.hatena.ne.jp/hitode909/20110924/1316853933
(require 'clipboard-to-kill-ring)
(clipboard-to-kill-ring t)
(setq clipboard-to-kill-ring:interval 1.0)


;; emacs終了時に確認メッセージを出す。
;; 誤って終了してしまわないようにするため
;; ref: http://blog.livedoor.jp/techblog/archives/64599359.html
(defadvice save-buffers-kill-emacs
  (before safe-save-buffers-kill-emacs activate)
  "safe-save-buffers-kill-emacs"
  (unless (y-or-n-p "Really exit emacs? ")
    (keyboard-quit)))


;; ファイル保存時に行末のwhitespaceを削除
(setq delete-trailing-whitespace-exclude-patterns (list "\\.md$" "\\.markdown$"))

(require 'cl)
(eval-when-compile (require 'cl))
(defun delete-trailing-whitespace-with-exclude-pattern ()
  (interactive)
  (cond ((equal nil (loop for pattern in delete-trailing-whitespace-exclude-patterns
                          thereis (string-match pattern buffer-file-name)))
         (delete-trailing-whitespace))))

(add-hook 'before-save-hook 'delete-trailing-whitespace-with-exclude-pattern)


;; ファイル保存時にファイル末尾の改行を削除
;; http://www.emacswiki.org/emacs/DeletingWhitespace
(defun my-delete-trailing-blank-lines ()
  "Deletes all blank lines at the end of the file."
  (interactive)
  (save-excursion
    (save-restriction
      (widen)
      (goto-char (point-max))
      (delete-blank-lines))))

(add-hook 'before-save-hook
          '(lambda ()
             (my-delete-trailing-blank-lines)
             ))


;; ファイル保存時に空のファイルなら消すかどうか聞く
(defun delete-file-if-no-contents ()
  (when (and
         (buffer-file-name (current-buffer))
         (= (point-min) (point-max)))
    (when (y-or-n-p "Delete file and kill buffer?")
      (delete-file
       (buffer-file-name (current-buffer)))
      (kill-buffer (current-buffer)))))

(add-hook 'after-save-hook
          '(lambda ()
             (delete-file-if-no-contents)
             ))


;; GCを減らして軽くする
(setq gc-cons-threshold (* 10 gc-cons-threshold))


;; ダイアログを使わない
(setq use-dialog-box nil)
(defalias 'message-box 'message)


;; キーストロークのミニバッファへの表示を早く
(setq echo-keystrokes 0.1)


;; クリップボードにコピー
(setq x-select-enable-clipboard t)


;; 黄金比
;; (require 'golden-ratio)
;; (golden-ratio-enable)


;; M-k でカーソルの後ろの空白を全て消す
;; http://d.hatena.ne.jp/syohex/20111017/1318857029
(defun kill-following-spaces ()
  (interactive)
  (let ((orig-point (point)))
    (save-excursion
      (skip-chars-forward " \t\n")
      (delete-region orig-point (point)))))

(define-key global-map (kbd "M-k") 'kill-following-spaces)


;; 24.3.1 にしたら aling-rules-list が void-valiable と言われるのでロードしておく
(require 'align)

;; $SHELL が /bin/bash のままになってて動かないかもしれないので
(when (executable-find "/usr/local/bin/zsh")
  (setenv "SHELL" "/usr/local/bin/zsh")
  (exec-path-from-shell-initialize)
  )
