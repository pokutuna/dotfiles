;; load-path & PATH
(load-file "~/.emacs.d/config/load-path-config.el")
(load-file "~/.emacs.d/config/basic-config.el")
(load-file "~/.emacs.d/config/util-config.el")
(load-file "~/.emacs.d/config/face-config.el")
(load-file "~/.emacs.d/config/find-config.el")
(load-file "~/.emacs.d/config/undo-redo-config.el")

(load-file "~/.emacs.d/config/auto-complete-config.el")
(load-file "~/.emacs.d/config/anything-config.el")
(load-file "~/.emacs.d/config/completion-config.el") ;; smartchr.el parenthesis.el
(load-file "~/.emacs.d/config/yasnippet-config.el")
(load-file "~/.emacs.d/config/flymake-config.el")


;;Egg emacs got git
;(install-elisp "http://github.com/byplayer/egg/raw/master/egg.el")
(when (executable-find "git")
  (require 'egg nil t))

;;;lang
;;C
(add-hook 'c-mode-common-hook
          '(lambda ()
             (c-toggle-auto-hungry-state 1)
             (define-key c-mode-base-map "\C-m" 'newline-and-indent)))

;;Ruby
(autoload 'ruby-mode "ruby-mode"
  "Mode for editing ruby source files" t)
(setq auto-mode-alist
      (append '(("\\.rb$|\\.cgi$" . ruby-mode)) auto-mode-alist))
(setq interpreter-mode-alist (append '(("ruby" . ruby-mode))
                                     interpreter-mode-alist))
(autoload 'run-ruby "inf-ruby"
  "Run an inferior Ruby process")
(autoload 'inf-ruby-keys "inf-ruby"
  "Set local key defs for inf-ruby in ruby-mode")
(add-hook 'ruby-mode-hook
          '(lambda ()
             (inf-ruby-keys)))
; *.rbを開けばruby-modeになる。M-x run-rubyでirbが起動する。

;; ruby-electric
(require 'ruby-electric)
(add-hook 'ruby-mode-hook '(lambda () (ruby-electric-mode t)))
(setq ruby-indent-level 2)
(setq ruby-indent-tabs-mode nil)

;; rubydb
(autoload 'rubydb "rubydb3x"
  "run rubydb on program file in buffer *gud-file*.
the directory containing file becomes the initial working directory
and source-file directory for your debugger." t)

;; ruby-block
(require 'ruby-block)
(add-hook 'ruby-mode-hook
          '(lambda ()
             (ruby-block-mode t)
             (setq ruby-block-highlight-toggle t)))

(setq ruby-deep-indent-paren-style nil) ;C-M-\ でindentととのえる

(add-hook 'ruby-mode-hook
    '(lambda ()
         (setq tab-width 2)
         (setq indent-tabs-mode nil)
         (setq ruby-indent-level tab-width)
))

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



;;rvm
;(install-elisp "https://github.com/senny/rvm.el/raw/master/rvm.el")
(require 'rvm) ;rvm
(rvm-use-default)
(require 'rcodetools) ;rcodetools

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
;ido-mode
;(when (require 'ido nil t) ;;recommended by rinari
;  (ido-mode t))
;rinari
(add-to-list 'load-path (expand-file-name "~/.emacs.d/elisp/rinari"))
(require 'rinari)
;rhtml
(add-to-list 'load-path (expand-file-name "~/.emacs.d/elisp/rhtml"))
(require 'rhtml-mode)
(add-hook 'rhtml-mode-hook
  (lambda () (rinari-launch)))

;;haml
;(install-elisp "https://github.com/nex3/haml-mode/raw/master/haml-mode.el")
(when (require 'haml-mode nil t)
  (add-to-list 'auto-mode-alist '("\\.haml$" . haml-mode)))
;;sass
;(install-elisp "https://github.com/nex3/sass-mode/raw/master/sass-mode.el")
(when (require 'sass-mode nil t)
  (add-to-list 'auto-mode-alist '("\\.sass$" . sass-mode)))
;;scss
;(install-elisp "https://github.com/blastura/dot-emacs/raw/master/lisp-personal/scss-mode.el")
(when (require 'scss-mode nil t)
  (add-to-list 'auto-mode-alist '("\\.scss\\'" . scss-mode)))

;;Scala
(add-to-list 'load-path "/usr/local/share/scala/misc/scala-tool-support/emacs")
(require 'scala-mode-auto)
(require 'scala-mode-constants)
(require 'scala-mode-feature)
(add-hook 'scala-mode-hook
            '(lambda ()
               (yas/minor-mode-on)
               (scala-mode-feature-electric-mode t)
               (define-key scala-mode-map "\C-c\C-a" 'scala-run-scala)
               (define-key scala-mode-map "\C-c\C-b" 'scala-eval-buffer)
               (define-key scala-mode-map "\C-c\C-r" 'scala-eval-region)
               ))

;;ensime
(add-to-list 'load-path (expand-file-name "~/.emacs.d/etc/ensime/elisp/"))
(require 'ensime)
(add-hook 'scala-mode-hook 'ensime-scala-mode-hook)

(defun my-ac-scala-mode ()
  (add-to-list 'ac-sources 'ac-source-dictionary)
  (add-to-list 'ac-sources 'ac-source-yasnippet)
  (add-to-list 'ac-sources 'ac-source-words-in-buffer)
  (add-to-list 'ac-sources 'ac-source-words-in-same-mode-buffers)
  (setq ac-sources (reverse ac-sources))
  )

(add-hook 'scala-mode-hook 'my-ac-scala-mode)
(add-hook 'ensime-mode-hook 'my-ac-scala-mode)

;improve scala-mode indentation
(defadvice scala-block-indentation (around improve-indentation-after-brace activate)
  (if (eq (char-before) ?\{)
      (setq ad-return-value (+ (current-indentation) scala-mode-indent:step))
    ad-do-it))
(defun scala-newline-and-indent ()
  (interactive)
  (delete-horizontal-space)
  (let ((last-command nil))
    (newline-and-indent))
  (when (scala-in-multi-line-comment-p)
    (insert "* ")))
(add-hook 'scala-mode-hook
          (lambda ()
            (define-key scala-mode-map (kbd "RET") 'scala-newline-and-indent)))

;;;Javascript
(setq-default c-basic-offset 4)
(when (load "js2" t)
  (setq js2-cleanup-whitespace nil
        js2-mirror-mode nil
        js2-bounce-indent-flag nil)
  (defun indent-and-back-to-indentation ()
    (interactive)
    (indent-for-tab-command)
    (let ((point-of-indentation
           (save-excursion
             (back-to-indentation)
             (point))))
      (skip-chars-forward "\s " point-of-indentation)))
  (define-key js2-mode-map "\C-i" 'indent-and-back-to-indentation)
  (define-key js2-mode-map "\C-m" nil)
  (add-to-list 'auto-mode-alist '("\\.js$" . js2-mode)))
(defun js-mode-hooks ()
  (setq flymake-jsl-mode-map 'js-mode-map)
  (when (require 'flymake-jsl nil t)
    (setq flymake-check-was-interrupted t)
    (flymake-mode t)))
(add-hook 'js-mode-hook 'js-mode-hooks)

;;yatex
(add-to-list 'load-path (expand-file-name "~/.emacs.d/elisp/yatex"))
(setq auto-mode-alist
      (cons (cons "\\.tex$" 'yatex-mode) auto-mode-alist))
(autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)
(setq YaTeX-kanji-code 3)

;;;org & remember mode
(add-to-list 'load-path "~/.emacs.d/elisp/remember-el")
(add-to-list 'load-path "~/.emacs.d/elisp/org-mode/lisp")
(require 'org-install)
(setq org-startup-truncated nil)
(setq org-return-follows-link t)
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(org-remember-insinuate)
(setq org-directory "~/.emacs.d/memo/")
(setq org-default-notes-file (concat org-directory "agenda.org"))
(setq org-remember-templates
      '(("Todo" ?t "** TODO %?\n   %i\n   %a\n   %t" nil "Inbox")
        ("Bug" ?b "** TODO %?   :bug:\n   %i\n   %a\n   %t" nil "Inbox")
        ("Idea" ?i "** %?\n   %i\n   %a\n   %t" nil "New Ideas")
        ))
(define-key org-mode-map [(control up)] 'outline-previous-visible-heading)
(define-key org-mode-map [(control down)] 'outline-next-visible-heading)
(define-key org-mode-map [(control shift up)] 'outline-backward-same-level)
(define-key org-mode-map [(control shift down)] 'outline-forward-same-level)

;;remember-mode for code reading
(defvar org-code-reading-software-name nil)
;; ~/memo/code-reading.org に記録する
(defvar org-code-reading-file "code-reading.org")
(defun org-code-reading-read-software-name ()
  (set (make-local-variable 'org-code-reading-software-name)
       (read-string "Code Reading Software: "
                    (or org-code-reading-software-name
                        (file-name-nondirectory
                         (buffer-file-name))))))

(defun org-code-reading-get-prefix (lang)
  (concat "[" lang "]"
          "[" (org-code-reading-read-software-name) "]"))
(defun org-remember-code-reading ()
  (interactive)
  (let* ((prefix (org-code-reading-get-prefix (substring (symbol-name major-mode) 0 -5)))
         (org-remember-templates
          `(("CodeReading" ?r "** %(identity prefix)%?\n   \n   %a\n   %t"
             ,org-code-reading-file "Memo"))))
    (org-remember)))

;;html
;(install-elisp "http://tuvalu.santafe.edu/~nelson/hhm-beta/html-helper-mode.el")
;(install-elisp "http://tuvalu.santafe.edu/~nelson/hhm-beta/tempo.el")
;(when (require 'html-helper-mode nil t)
;  (autoload 'html-helper-mode "html-helper-mode" "Yay HTML" t)
;  (setq auto-mode-alist (cons '("\\.html$" . html-helper-mode) auto-mode-alist)))
(put 'upcase-region 'disabled nil)

;; octave
(autoload 'octave-mode "octave-mod" nil t)
(setq auto-mode-alist
           (cons '("\\.m$" . octave-mode) auto-mode-alist))
(add-hook 'octave-mode-hook
               (lambda ()
                 (abbrev-mode 1)
                 (auto-fill-mode 1)
                 (if (eq window-system 'x)
                     (font-lock-mode 1))))

;; haskell
(load "~/.emacs.d/elisp/haskell-mode/haskell-site-file")
(add-to-list 'auto-mode-alist '("\\.hc$" . haskell-mode))
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)


;; perl
(autoload 'cprl-mode "cperl-mode" "alternate mode for editing Perl programs" t)
(add-to-list 'auto-mode-alist '("\\.\\([pP][Llm]\\|al\\|t\\|cgi\\)\\'" . cperl-mode))
(add-to-list 'interpreter-mode-alist '("perl" . cperl-mode))
(add-to-list 'interpreter-mode-alist '("perl5" . cperl-mode))
(add-to-list 'interpreter-mode-alist '("miniperl" . cperl-mode))

(defalias 'perl-mode 'cperl-mode)

(setq cperl-indent-level 4
      cperl-continued-statement-offset 4
      cperl-close-paren-offset -4
      cperl-label-offset -4
      cperl-comment-column 40
      cperl-highlight-variables-indiscriminately t
      cperl-indent-parens-as-block t
      cperl-tab-always-indent nil
      cperl-font-lock t
      cperl-auto-newline t
      cperl-auto-newline-after-colon t
      cperl-electric-paren t
      )

(add-hook 'cperl-mode-hook
          '(lambda ()
             (progn
               (setq indent-tabs-mode nil)
               (setq tab-width nil))))

(add-hook  'cperl-mode-hook
           (lambda ()
             (require 'perl-completion)
             (add-to-list 'ac-sources 'ac-source-perl-completion)
             (add-to-list 'ac-sources 'ac-source-yasnippet) ;;yasnipet
             (perl-completion-mode t)
             ))

; perl tidy
; sudo cpan install Perl::Tidy
(defun perltidy-region ()
  "Run perltidy on the current region."
  (interactive)
  (save-excursion
    (shell-command-on-region (point) (mark) "perltidy -q" nil t)))
(defun perltidy-defun ()
  "Run perltidy on the current defun."
  (interactive)
  (save-excursion (mark-defun)
                  (perltidy-region)))
(global-set-key "\C-ct" 'perltidy-region)
(global-set-key "\C-c\C-t" 'perltidy-defun)

;; ;; flymake (Emacs22から標準添付されている)
(require 'flymake)

;; set-perl5lib
;; 開いたスクリプトのパスに応じて、@INCにlibを追加してくれる
;; 以下からダウンロードする必要あり
;; http://svn.coderepos.org/share/lang/elisp/set-perl5lib/set-perl5lib.el
(require 'set-perl5lib)

;; エラーをミニバッファに表示
;; http://d.hatena.ne.jp/xcezx/20080314/1205475020
(defun flymake-display-err-minibuf ()
  "Displays the error/warning for the current line in the minibuffer"
  (interactive)
  (let* ((line-no             (flymake-current-line-no))
         (line-err-info-list  (nth 0 (flymake-find-err-info flymake-err-info line-no)))
         (count               (length line-err-info-list)))
    (while (> count 0)
      (when line-err-info-list
        (let* ((file       (flymake-ler-file (nth (1- count) line-err-info-list)))
               (full-file  (flymake-ler-full-file (nth (1- count) line-err-info-list)))
               (text (flymake-ler-text (nth (1- count) line-err-info-list)))
               (line       (flymake-ler-line (nth (1- count) line-err-info-list))))
          (message "[%s] %s" line text)))
      (setq count (1- count)))))

;; Perl用設定
;; http://unknownplace.org/memo/2007/12/21#e001
(defvar flymake-perl-err-line-patterns
  '(("\\(.*\\) at \\([^ \n]+\\) line \\([0-9]+\\)[,.\n]" 2 3 nil 1)))

(defconst flymake-allowed-perl-file-name-masks
  '(("\\.pl$" flymake-perl-init)
    ("\\.pm$" flymake-perl-init)
    ("\\.t$" flymake-perl-init)))

(defun flymake-perl-init ()
  (let* ((temp-file (flymake-init-create-temp-buffer-copy
                     'flymake-create-temp-inplace))
         (local-file (file-relative-name
                      temp-file
                      (file-name-directory buffer-file-name))))
    (list "perl" (list "-wc" local-file))))

(defun flymake-perl-load ()
  (interactive)
  (defadvice flymake-post-syntax-check (before flymake-force-check-was-interrupted)
    (setq flymake-check-was-interrupted t))
  (ad-activate 'flymake-post-syntax-check)
  (setq flymake-allowed-file-name-masks (append flymake-allowed-file-name-masks flymake-allowed-perl-file-name-masks))
  (setq flymake-err-line-patterns flymake-perl-err-line-patterns)
  (set-perl5lib)
  (flymake-mode t))

(add-hook 'cperl-mode-hook 'flymake-perl-load)

;;flymakeで前後のエラーに飛ぶ
(defun next-flymake-error ()
  (interactive)
  (flymake-goto-next-error)
  (let ((err (get-char-property (point) 'help-echo)))
    (when err
      (message err))))

(defun prev-flymake-error ()
  (interactive)
  (flymake-goto-prev-error)
  (let ((err (get-char-property (point) 'help-echo)))
    (when err
      (message err))))

;;(global-set-key "\C-ce" 'next-flymake-error)
(add-hook 'cperl-mode-hook
          (lambda ()
            (define-key cperl-mode-map (kbd "M-n") 'next-flymake-error)
            (define-key cperl-mode-map (kbd "M-p") 'prev-flymake-error)
            ))


;; モジュールソースバッファの場合はその場で、
;; その他のバッファの場合は別ウィンドウに開く。
(put 'perl-module-thing 'end-op
     (lambda ()
       (re-search-forward "\\=[a-zA-Z][a-zA-Z0-9_:]*" nil t)))
(put 'perl-module-thing 'beginning-op
     (lambda ()
       (if (re-search-backward "[^a-zA-Z0-9_:]" nil t)
           (forward-char)
         (goto-char (point-min)))))

;;parenthesis
(add-hook 'cperl-mode-hook
          (lambda ()
            (parenthesis-register-keys "{('\"[<" cperl-mode-map)))

;;perl smartchar
(add-hook 'cperl-mode-hook
          (lambda ()
            (define-key cperl-mode-map (kbd ".") (smartchr '("->" "->{`!!'}" ".")))
            (define-key cperl-mode-map (kbd "-") (smartchr '("-" "->" "->{`!!'}")))
            ;(define-key cperl-mode-map (kbd ";") (smartchr '(";\n" ";")))
            ))


