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


;; ;;skeleton-pair-dwim
;; ;;(auto-install-from-url "https://github.com/uk-ar/skeleton-pair-dwim/raw/master/skeleton-pair-dwim.el")
;; (require 'skeleton-pair-dwim)
;; (skeleton-pair-dwim-load-default)


;;jaunte.el
(require 'jaunte)
(global-set-key (kbd "C-c C-j") 'jaunte)
(global-set-key (kbd "M-z") 'jaunte)
