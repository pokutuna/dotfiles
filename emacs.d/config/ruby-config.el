(add-to-list 'auto-mode-alist '("Rakefile" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.rb$|\\.cgi$" . ruby-mode))
(add-to-list 'interpreter-mode-alist '("ruby" . ruby-mode))

(lazyload
 (ruby-mode) "ruby-mode"

 (setq ruby-indent-level 2)
 (setq ruby-indent-tabs-mode nil)
 (setq ruby-deep-indent-paren-style nil) ;C-M-\ でindentととのえる


 ;; auto-magic-comment
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


 ;; RSense
 ;; (setq rsense-home (expand-file-name "~/.emacs.d/etc/rsense-0.3"))
 (setq rsense-home (expand-file-name "~/.emacs.d/etc/rsense-0.3"))
 (add-to-list 'load-path (concat rsense-home "/etc"))
 (setq rsense-rurema-home (expand-file-name "~/.emacs.d/etc/rurema")) ;るりま表示
 (require 'rsense)


 ;; anything-rdefs
 (require 'anything-rdefs)
 (setq ar:command "rdefs")

 ;;;rails
 ;; rinari
 (require 'rinari)
 ;; rhtml
 (add-to-load-path "co/rhtml")
 (require 'rhtml-mode)
)

(lazyload (ruby-electric-mode) "ruby-electric")
(lazyload (ruby-block-mode) "ruby-block"
          (setq ruby-block-highlight-toggle t))
(lazyload (rubydb) "rubydb3x")

(add-hook-fn 'ruby-mode-hook
             (ruby-electric-mode t)
             (ruby-block-mode t)

             (parenthesis-register-keys "(\"['" ruby-mode-map)
             (define-key ruby-mode-map (kbd "{")
               (smartchr '("{`!!'}" "{ |`!!'|}" "do |`!!'|\nend")))

             ;; flymake
             (if (not (null buffer-file-name)) (flymake-mode))

             ;; rsense
             (add-to-list 'ac-sources 'ac-source-rsense-method)
             (add-to-list 'ac-sources 'ac-source-rsense-constant)
             (local-set-key (kbd "M-i") 'ac-complete-rsense)

             ;; rdefs
             (local-set-key (kbd "C-@") 'anything-rdefs)
             )


(add-hook-fn 'rhtml-mode-hook (rinari-launch))

;;rvm
;; (add-to-load-path "co/rvm")
;; (require 'rvm)
;; (rvm-use-default)


;; rbenv
;; http://marc-bowes.com/2012/03/10/rbenv-with-emacs.html
(setenv "PATH" (concat (getenv "HOME") "/.rbenv/shims:" (getenv "HOME") "/.rbenv/bin:" (getenv "PATH")))
(setq exec-path (cons (concat (getenv "HOME") "/.rbenv/shims") (cons (concat (getenv "HOME") "/.rbenv/bin") exec-path)))
