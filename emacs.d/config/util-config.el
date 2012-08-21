;; auto-install
;; (install-elisp "http://www.emacswiki.org/emacs/download/auto-install.el")
(when (require 'auto-install nil t)
  (setq auto-install-directory "~/.emacs.d/elisp/")
  (auto-install-update-emacswiki-package-name t)
  (auto-install-compatibility-setup))


;;cua 矩形選択
(cua-mode t)
(setq cua-enable-cua-keys nil)


;;カーソル位置を含むカッコとか文字列とかで選択
(require 'thing-opt)
(define-thing-commands)
(global-set-key (kbd "C-$") 'mark-word*)
(global-set-key (kbd "C-\"") 'mark-string)
(global-set-key (kbd "C-(") 'mark-up-list)


;; proxy
(defun activate-kgu-proxy ()
  (interactive)
  (setq url-proxy-services
        '(("http" . "proxy.ksc.kwansei.ac.jp:8080")
          ("https" . "proxy.ksc.kwansei.ac.jp:8080"))))
(defun deactivate-proxy ()
  (interactive)
  (setq url-proxy-services
        '(("no_proxy" . ""))))
(deactivate-proxy)


;;zizo
(require 'zizo)


;;htmlize
(require 'htmlize)


;; dict
;http://github.com/hitode909/dotfiles/raw/master/emacs.d/config/dictionary-config.el
(require 'dictionary-config)
(global-set-key (kbd "C-M-d") 'my-dictionary)
(setq dict-log-file "~/.emacs.d/memo/dictionaly.txt")


;; @レジスタコピペ C-w or M-w が連続で押されたらレジスタ@にコピペ
(defvar clipboard-register ?@)
(defadvice kill-region (before clipboard-cut activate)
  (when (eq last-command this-command)
    (set-register clipboard-register (car kill-ring))
    (message "Copy to clipboard")))
(defadvice kill-ring-save (before clipboard-copy activate)
  (when (eq last-command this-command)
    (set-register clipboard-register (car kill-ring))
    (message "Copy to clipboard")))

(defun clipboard-paste ()
  (interactive)
  (insert-register clipboard-register)
  (message "Paste from clipboard"))
(global-set-key (kbd "C-M-y") 'clipboard-paste) ;C-M-y でレジスタ@から貼り付け


;; Shebangがあるとき自動的にchmod +xする
(add-hook 'after-save-hook
          'executable-make-buffer-file-executable-if-script-p)


;;wdired
(require 'wdired)
(define-key dired-mode-map "r" ; dired中にrでリネーム
  'wdired-change-to-wdired-mode)


;;shell ;使わなさそう
;(install-elisp-from-emacswiki "multi-term.el")
(when (require 'multi-term nil t)
  (setq multi-term-program "/usr/local/bin/zsh"))
(add-hook 'shell-mode-hook ;shell-modeで上下でヒストリ補完
   (function (lambda ()
      (define-key shell-mode-map [up] 'comint-previous-input)
      (define-key shell-mode-map [down] 'comint-next-input))))


;;Egg emacs got git
;(install-elisp "http://github.com/byplayer/egg/raw/master/egg.el")
(when (executable-find "git")
  (require 'egg nil t))


;; 保存後に実行するシェルコマンド
(defun temp-shell-command-after-save ()
  (interactive)
  (let* command-to-exec
    (setq command-to-exec (read-input "shell-command: "))
    (add-hook 'after-save-hook
              '(lambda ()
                 (shell-command command-to-exec)
                 ) nil t)
    (princ (format "Shell-command `%s` will run when after saving this buffer." command-to-exec))
    ))


;; pyong-pyong.el
(add-to-load-path "co/pyong-pyong.el")
(require 'pyong-pyong)
(pyong:default-binding)
