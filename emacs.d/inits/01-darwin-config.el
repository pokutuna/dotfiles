(when (eq system-type 'darwin) ; Macの時のみ
  ;; option <-> command
  (setq ns-command-modifier (quote meta))
  (setq ns-alternate-modifier (quote super))


  ;; インラインパッチ適応されているかどうか
  (defvar is_inline-patch (eq (boundp 'mac-input-method-parameters) t))

  (when is_inline-patch
    (setq  default-input-method "MacOSX")
    )
)
