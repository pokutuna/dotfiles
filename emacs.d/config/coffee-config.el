(add-to-list 'auto-mode-alist '("\\.coffee$" . coffee-mode))
(add-to-list 'auto-mode-alist '("Cakefile" . coffee-mode))
(add-to-list 'auto-mode-alist '("\\.js.shd$" . coffee-mode))

(require 'coffee-mode)
(lazyload
 (coffee-mode) "coffee-mode"

 (make-local-variable 'tab-width)
 (set 'tab-width 2)
 (setq coffee-args-compile '("-cb"))
 (setq ac-modes (cons 'coffee-mode ac-modes))

 (add-hook-fn 'after-save-hook
              (when (string-match "\.coffee" (buffer-name)) (coffee-compile-file))
              )

 ;; flymake for coffeescript
 ;; http://d.hatena.ne.jp/antipop/20110508/1304838383
 (setq flymake-coffeescript-err-line-patterns
       '(("\\(Error: In \\([^,]+\\), .+ on line \\([0-9]+\\).*\\)" 2 3 nil 1)))

 (defconst flymake-allowed-coffeescript-file-name-masks
   '(("\\.coffee$" flymake-coffeescript-init)))

 (defun flymake-coffeescript-init ()
   (let* ((temp-file (flymake-init-create-temp-buffer-copy
                      'flymake-create-temp-inplace))
          (local-file (file-relative-name
                       temp-file
                       (file-name-directory buffer-file-name))))
     (list "coffee" (list local-file))))

 (defun flymake-coffeescript-load ()
   (interactive)
   (defadvice flymake-post-syntax-check (before flymake-force-check-was-interrupted)
     (setq flymake-check-was-interrupted t))
   (ad-activate 'flymake-post-syntax-check)
   (setq flymake-allowed-file-name-masks
         (append flymake-allowed-file-name-masks
                 flymake-allowed-coffeescript-file-name-masks))
   (setq flymake-err-line-patterns flymake-coffeescript-err-line-patterns)
   (flymake-mode t))

 (message "coffee!")
 )

(add-hook 'coffee-mode-hook 'flymake-coffeescript-load)
(add-hook-fn
 'coffe-mode-hook

 ;; smartchr
 (define-key coffee-mode-map (kbd ">")
   (smartchr '(">" "=> " ">> " ">" ">= " "=> '`!!''" "=> \"`!!'\"")))
 (define-key coffee-mode-map (kbd ".")
   (smartchr '("." "-> ")))

 ;; swap default C-j and C-m
 (define-key coffee-mode-map (kbd "C-j") 'coffee-newline-and-indent)
 (define-key coffee-mode-map (kbd "C-m") 'newline-and-indent)
 )
