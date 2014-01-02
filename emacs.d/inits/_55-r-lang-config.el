(add-to-load-path "etc/ess-12.09-2/")
(add-to-list 'auto-mode-alist '("\\.r$|\\.R$" . R-mode))
(require 'ess-site)

(lazyload
 (R-mode) "ess-site"

 ;; smartchr
 (define-key ess-mode-map (kbd "<") (smartchr '("<" "<- `!!'")))
 )
