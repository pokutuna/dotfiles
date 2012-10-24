;; perl
(defalias 'perl-mode 'cperl-mode)
(add-to-list 'auto-mode-alist '("\\.\\([pP][Llm]\\|al\\|t\\|cgi\\)\\'" . cperl-mode))
(add-to-list 'interpreter-mode-alist '("perl" . cperl-mode))
(add-to-list 'interpreter-mode-alist '("perl5" . cperl-mode))
(add-to-list 'interpreter-mode-alist '("miniperl" . cperl-mode))

(lazyload
 (cperl-mode) "cperl-mode"

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
       ;;cperl-auto-newline-after-colon t
       cperl-electric-paren t)

 ;; perlbrew-mini
 ;; http://dams.github.com/2011/05/27/perlbrew-emacs-flymake.html
 (add-to-load-path "co/perlbrew-mini")
 (require 'perlbrew-mini)
 ;; (perlbrew-mini-use-latest)
 (perlbrew-mini-use "perl-5.15.3")


 ;; perl tidy
 ;; sudo cpan install Perl::Tidy
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

 (define-key cperl-mode-map (kbd "C-c t") 'perltidy-region)
 (define-key cperl-mode-map (kbd "C-c C-t") 'perltidy-defun)


 ;; flymake for perl
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

 (define-key cperl-mode-map (kbd "M-n") 'next-flymake-error)
 (define-key cperl-mode-map (kbd "M-p") 'prev-flymake-error)


 ;; モジュールソースバッファの場合はその場で、
 ;; その他のバッファの場合は別ウィンドウに開く。
 ;; http://d.hatena.ne.jp/antipop/20101117/1289978771
 (put 'perl-module-thing 'end-op
      (lambda ()
        (re-search-forward "\\=[a-zA-Z][a-zA-Z0-9_:]*" nil t)))
 (put 'perl-module-thing 'beginning-op
      (lambda ()
        (if (re-search-backward "[^a-zA-Z0-9_:]" nil t)
            (forward-char)
          (goto-char (point-min)))))

 (defun find-perl-module-file ()
   (interactive)
   (let ((module (thing-at-point 'perl-module-thing))
         (file ""))
     (when (string= module "")
       (setq module (read-string "Module Name: ")))
     (setq file
           (replace-regexp-in-string "\n+$" ""
                                     (shell-command-to-string (format "perldoc -l %s" module))))
     (if (string-match "^No documentation" file)
         (error (format "module not found: %s" module))
       (find-file file))))

 )


(add-hook 'cperl-mode-hook 'flymake-perl-load)
(add-hook-fn
 'cperl-mode-hook

 (require 'perl-completion)
 (add-to-list 'ac-sources 'ac-source-perl-completion)
 (perl-completion-mode t)

 ;; parenthesis
 (parenthesis-register-keys "{('\"[<" cperl-mode-map)

 ;; smartchr
 (define-key cperl-mode-map (kbd ".") (smartchr '("->" "->{`!!'}" ".")))
 (define-key cperl-mode-map (kbd "-") (smartchr '("-" "->" "->{`!!'}")))
 (define-key cperl-mode-map (kbd ">") (smartchr '(">" "=>" ">>" ">=" "=> '`!!''" "=> \"`!!'\"")))
 (define-key cperl-mode-map (kbd "F") (smartchr '("F" "$" "$_" "$_->" "@$")))
 (define-key cperl-mode-map (kbd "M") (smartchr '("M" "my $`!!' = ")))
 (define-key cperl-mode-map (kbd "D") (smartchr '("D" "use Data::Dumper; warn Dumper `!!';")))
 (define-key cperl-mode-map (kbd "S") (smartchr '("S" "my ($self) = @_;" "my ($self, $`!!') = @_;")))
 (define-key cperl-mode-map (kbd ".") (smartchr '("->" "." "..")))
 (define-key cperl-mode-map (kbd "|") (smartchr '(" || " "|")))
 (define-key cperl-mode-map (kbd "&") (smartchr '(" && " "&")))
 (define-key cperl-mode-map (kbd "{") (smartchr '("{" "sub {")))
 )
