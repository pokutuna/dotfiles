(require 'coffee-mode)
(add-to-list 'auto-mode-alist '("\\.coffee$" . coffee-mode))
(add-to-list 'auto-mode-alist '("Cakefile" . coffee-mode))


(defun coffee-custom ()
  "coffee-mode-hook"
 (set (make-local-variable 'tab-width) 2)
 (define-key coffee-mode-map [(meta R)] 'coffee-compile-file)

 (add-hook 'after-save-hook
           '(lambda ()
              (when (string-match "\.coffee" (buffer-name)) ; ~~~.coffee<>
                (coffee-compile-file)))))
)

(add-hook 'coffee-mode-hook
  '(lambda() (coffee-custom)))

(add-to-list 'auto-mode-alist '("\\.js.shd$" . coffee-mode))
(setq coffee-args-compile '("-cb"))
(setq ac-modes (cons 'coffee-mode ac-modes))


;; flymake for coffeescript
;; http://d.hatena.ne.jp/antipop/20110508/1304838383
(require 'flymake')
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

(add-hook 'coffee-mode-hook 'flymake-coffeescript-load)
