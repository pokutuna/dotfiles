;;yatex
(add-to-list 'load-path (expand-file-name "~/.emacs.d/elisp/yatex1.76"))
(setq auto-mode-alist
      (cons (cons "\\.tex$" 'yatex-mode) auto-mode-alist))
(autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)
(setq YaTeX-kanji-code nil)
