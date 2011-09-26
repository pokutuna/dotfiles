;;yatex
(add-to-list 'load-path (expand-file-name "~/.emacs.d/elisp/yatex"))
(setq auto-mode-alist
      (cons (cons "\\.tex$" 'yatex-mode) auto-mode-alist))
(autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)
(setq YaTeX-kanji-code 3)
