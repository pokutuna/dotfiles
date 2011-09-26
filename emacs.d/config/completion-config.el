;;auto-complete
(when (require 'auto-complete-config nil t)
  (ac-config-default)
  (global-auto-complete-mode t)
  (auto-complete-mode t)

  (setq ac-auto-start 2)
  (setq ac-auto-show-menu 0.4)
  (setq ac-ignore-case t)
  (setq popup-use-optimized-column-computation t)

  ;;keybind
  (global-set-key (kbd "M-i") 'auto-complete)
  (define-key ac-mode-map (kbd "M-TAB") 'auto-complete)
  (define-key ac-complete-mode-map (kbd "M-n") 'ac-next)
  (define-key ac-complete-mode-map (kbd "M-p") 'ac-previous)
  (ac-set-trigger-key "TAB")

  (add-to-list 'ac-dictionary-directories (expand-file-name "~/.emacs.d/ac-dict"))
  )


;;smartchr
;;(install-elisp "http://github.com/imakado/emacs-smartchr/raw/master/smartchr.el")
(when (require 'smartchr nil t)
  (define-key global-map (kbd "=") (smartchr '("=" "==" "===")))
  (define-key global-map (kbd "+") (smartchr '("+" "++")))
  (define-key global-map (kbd "{") (smartchr '("{ `!!' }" "{")))
  (define-key global-map (kbd ">")
    (smartchr '(">" "=>" "=> '`!!''" "=> \"`!!'\"")))
  (define-key global-map (kbd "|")
    (smartchr '("|" "|`!!'|" " || " )))
  (define-key global-map (kbd "\"")
    (smartchr '("\"" "\"`!!'\"" "\"\"\"`!!'\"\"\"")))
  (define-key global-map (kbd "'")
    (smartchr '("'" "'`!!''")))
  )


;;parenthesis
;;http://d.hatena.ne.jp/khiker/20080118/parenthesis
(require 'parenthesis)
(parenthesis-register-keys "{('\"[" global-map)
(parenthesis-init)

