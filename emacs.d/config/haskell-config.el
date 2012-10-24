;; haskell
(add-to-list 'auto-mode-alist '("\\.hc$" . haskell-mode))

(lazyload
 (haskell-mode) "haskell-mode"

 (require 'ghc-core)
 (require 'haskell-mode))

(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
