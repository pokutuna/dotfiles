(add-to-load-path "co/emacs-tss")

(require 'typescript)
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-mode))

;; tss command required
;; npm install -g typescript-tools
(require 'tss)
(tss-config-default)
