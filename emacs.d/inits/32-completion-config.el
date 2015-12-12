;; key-combo.el
(when (require 'key-combo nil t)
  (global-key-combo-mode t)
  (key-combo-define-global "+" '("+" "++"))
  (key-combo-define-global "{" '("{ `!!' }" "{"))
  (key-combo-define-global ">" '(">" "=>" "=> '`!!''" "=> \"`!!'\""))
  (key-combo-define-global "\"" '("\"" "\"`!!'\"" "\"\"\"`!!'\"\"\""))
  (key-combo-define-global "'" '("'" "'`!!''"))
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
