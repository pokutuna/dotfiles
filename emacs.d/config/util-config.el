;; auto-install
;; (install-elisp "http://www.emacswiki.org/emacs/download/auto-install.el")
(when (require 'auto-install nil t)
  (setq auto-install-directory "~/.emacs.d/elisp/")
  (auto-install-update-emacswiki-package-name nil)
  (auto-install-compatibility-setup))


;;cua 矩形選択
(cua-mode t)
(setq cua-enable-cua-keys nil)


;; mark-multiple.el
(require 'mark-more-like-this)
(global-set-key (kbd "C-<") 'mark-previous-like-this)
(global-set-key (kbd "C->") 'mark-next-like-this)
(global-set-key (kbd "C-M-m") 'mark-more-like-this)
(global-set-key (kbd "C-*") 'mark-all-like-this)



;; bookmark保存先
(setq bookmark-default-file "~/.emacs.d/etc/bookmark")


;;カーソル位置を含むカッコとか文字列とかで選択
(require 'thingopt)
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


;;shell ;使わなさそう
;(install-elisp-from-emacswiki "multi-term.el")
(when (require 'multi-term nil t)
  (setq multi-term-program "/usr/local/bin/zsh"))
(add-hook 'shell-mode-hook ;shell-modeで上下でヒストリ補完
   (function (lambda ()
      (define-key shell-mode-map [up] 'comint-previous-input)
      (define-key shell-mode-map [down] 'comint-next-input))))


;;Egg emacs got git
(when (executable-find "git")
  (require 'egg nil t)
  (require 'magit nil t))


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


;; open-junk-file.el
(require 'open-junk-file)
(setq open-junk-file-format "~/.emacs.d/etc/junk/%Y/%m/%d-%H%M%S.")
(global-set-key (kbd "C-x C-z") 'open-junk-file)


;; pyong-pyong.el
(add-to-load-path "co/pyong-pyong.el")
(require 'pyong-pyong)
(pyong:default-binding)


;; replace-region-by-ruby
(add-to-load-path "co/replace-region-by-ruby.el")
(require 'replace-region-by-ruby)


;; sound-editor
(require 'sound-editor)
