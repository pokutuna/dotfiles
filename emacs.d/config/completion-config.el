;;smartchr
;;(install-elisp "http://github.com/imakado/emacs-smartchr/raw/master/smartchr.el")
(when (require 'smartchr nil t)
  (define-key global-map (kbd "=") (smartchr '("=" "==" "===")))
  (define-key global-map (kbd "+") (smartchr '("+" "++")))
  (define-key global-map (kbd "{") (smartchr '("{ `!!' }" "{")))
  (define-key global-map (kbd ">")
    (smartchr '(">" "=>" "=> '`!!''" "=> \"`!!'\"")))
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


;;jaunte.el
(add-to-load-path "co/jaunte.el")
(require 'jaunte)
(global-set-key (kbd "C-c C-j") 'jaunte)
(global-set-key (kbd "M-z") 'jaunte)
