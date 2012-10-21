;; haskell
(require 'ghc-core)
(require 'haskell-mode)
(add-to-list 'auto-mode-alist '("\\.hc$" . haskell-mode))
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
