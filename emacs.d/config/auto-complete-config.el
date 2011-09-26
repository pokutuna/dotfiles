;;auto-complete
;; http://dev.ariel-networks.com/Members/matsuyama/auto-complete
(require 'auto-complete-config nil t)
(ac-config-default)
(global-auto-complete-mode t)
(auto-complete-mode t)
(setq ac-dwim t)
(setq ac-ignore-case 'smart)
(setq popup-use-optimized-column-computation t)
(setq ac-auto-start 2)
(setq ac-auto-show-menu 0.4)
(setq ac-menu-height 20)

;;keybind
(global-set-key (kbd "M-i") 'auto-complete)
(define-key ac-mode-map (kbd "M-TAB") 'auto-complete)
(define-key ac-complete-mode-map (kbd "M-n") 'ac-next)
(define-key ac-complete-mode-map (kbd "M-p") 'ac-previous)
(ac-set-trigger-key "TAB")

(add-to-list 'ac-dictionary-directories (expand-file-name "~/.emacs.d/ac-dict"))

(when (boundp 'ac-modes)
  (setq ac-modes
        (append ac-modes
                (list 'espresso-mode 'javascript-mode 'css-mode 'text-mode ))))


;;lookで英単語補完 http://d.hatena.ne.jp/kitokitoki/20101205/p2
(defun my-ac-look ()
  "look コマンドの出力をリストで返す"
  (interactive)
  (unless (executable-find "look")
    (error "look コマンドがありません"))
  (let ((search-word (thing-at-point 'word)))
    (with-temp-buffer
      (call-process-shell-command "look" nil t 0 search-word)
      (split-string-and-unquote (buffer-string) "\n"))))

(defun ac-complete-look ()
  (interactive)
  (auto-complete '(ac-source-look)))

(defvar ac-source-look
  '((candidates . my-ac-look)
    (requires . 2)))  ;; 2文字以上ある場合にのみ対応させる

(global-set-key (kbd "M-h") 'ac-complete-look)

;; ;; ふつうのac-sourceに追加する版
;; (setq ac-source-look
;; '((candidates . my-ac-look)
;;   (requires . 4)))
;; ;; 4文字以上の入力のみ対象とするように変更. 2 だと候補が多すぎてうっとうしい

;; ;; 補完対象とするモードの ac-sources に対して
;; (push 'ac-source-look ac-sources) ;追加
