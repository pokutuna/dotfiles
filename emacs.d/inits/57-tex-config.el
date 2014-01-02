(add-to-list 'auto-mode-alist '("\\.tex$" . yatex-mode))

(require 'yatex)
(lazyload
 (yatex-mode) "yatex-mode"

 (setq YaTeX-kanji-code nil)
 )

(add-hook 'yatex-mode-hook'(lambda ()(setq auto-fill-function nil)))
