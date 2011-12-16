(autoload 'ruby-mode "ruby-mode"
  "Mode for editing ruby source files" t)
(setq auto-mode-alist
      (append '(("\\.rb$|\\.cgi$" . ruby-mode)) auto-mode-alist))
(setq interpreter-mode-alist (append '(("ruby" . ruby-mode))
                                     interpreter-mode-alist))


;; ruby-mode for Rakefile
(add-to-list 'auto-mode-alist '("Rakefile" . ruby-mode))


(autoload 'run-ruby "inf-ruby"
  "Run an inferior Ruby process")
(autoload 'inf-ruby-keys "inf-ruby"
  "Set local key defs for inf-ruby in ruby-mode")
(add-hook 'ruby-mode-hook
          (lambda ()
            (inf-ruby-keys)))
; *.rbを開けばruby-modeになる。M-x run-rubyでirbが起動する。


;; ruby-electric
(add-hook 'ruby-mode-hook
          (lambda()
            (require 'ruby-electric)
            (ruby-electric-mode t)
            (parenthesis-register-keys "{(\"['" ruby-mode-map) ; override ruby-delectric completion
            ))


(setq ruby-indent-level 2)
(setq ruby-indent-tabs-mode nil)
(setq ruby-deep-indent-paren-style nil) ;C-M-\ でindentととのえる


(autoload 'rubydb "rubydb3x"
  "run rubydb on program file in buffer *gud-file*.
the directory containing file becomes the initial working directory
and source-file directory for your debugger." t)


;; ruby-block
(require 'ruby-block)
(add-hook 'ruby-mode-hook
          (lambda ()
            (ruby-block-mode t)
            (setq ruby-block-highlight-toggle t)))


;; rcodetools
(require 'rcodetools) ;rcodetools



;;rvm
(add-to-load-path "co/rvm")
(require 'rvm)
(rvm-use-default)


;;RSense
(setq rsense-home (expand-file-name "~/.emacs.d/etc/rsense-0.3"))
(add-to-list 'load-path (concat rsense-home "/etc"))
(require 'rsense)

;.や::で補完
(add-hook 'ruby-mode-hook
          (lambda ()
            (add-to-list 'ac-sources 'ac-source-rsense-method)
            (add-to-list 'ac-sources 'ac-source-rsense-constant)))

(setq rsense-rurema-home (expand-file-name "~/.emacs.d/etc/rurema")) ;るりま表示

(add-hook 'ruby-mode-hook
          (lambda ()
            (local-set-key (kbd "M-i") 'ac-complete-rsense)))


;;rails
;rinari
(add-to-load-path "co/rinari")
(require 'rinari)
;rhtml
(add-to-load-path "co/rhtml")
(require 'rhtml-mode)
(add-hook 'rhtml-mode-hook
  (lambda () (rinari-launch)))


;auto-magic-comment
(defun ruby-insert-magic-comment-if-needed ()
  "バッファのcoding-systemをもとにmagic commentをつける。"
  (when (and (eq major-mode 'ruby-mode)
             (find-multibyte-characters (point-min) (point-max) 1))
    (save-excursion
      (goto-char 1)
      (when (looking-at "^#!")
        (forward-line 1))
      (if (re-search-forward "^#.+coding" (point-at-eol) t)
          (delete-region (point-at-bol) (point-at-eol))
        (open-line 1))
      (let* ((coding-system (symbol-name buffer-file-coding-system))
             (encoding (cond ((string-match "japanese-iso-8bit\\|euc-j" coding-system)
                              "euc-jp")
                             ((string-match "shift.jis\\|sjis\\|cp932" coding-system)
                              "shift_jis")
                             ((string-match "utf-8" coding-system)
                              "utf-8"))))
        (insert (format "# -*- coding: %s -*-" encoding))))))
(add-hook 'before-save-hook 'ruby-insert-magic-comment-if-needed)


;; flymake for ruby
;; http://d.hatena.ne.jp/khiker/20070630/emacs_ruby_flymake
(require 'flymake)
;; Invoke ruby with '-c' to get syntax checking
(defun flymake-ruby-init ()
  (let* ((temp-file   (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
         (local-file  (file-relative-name
                       temp-file
                       (file-name-directory buffer-file-name))))
    (list "ruby" (list "-c" local-file))))
(push '(".+\\.rb$" flymake-ruby-init) flymake-allowed-file-name-masks)
(push '("Rakefile$" flymake-ruby-init) flymake-allowed-file-name-masks)
(push '("^\\(.*\\):\\([0-9]+\\): \\(.*\\)$" 1 2 nil 3) flymake-err-line-patterns)

(add-hook
 'ruby-mode-hook
 '(lambda ()
    ;; Don't want flymake mode for ruby regions in rhtml files
   (if (not (null buffer-file-name)) (flymake-mode))))
