;;;init.el

;; load-path追加関数
(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory (expand-file-name (concat user-emacs-directory path))))
        (add-to-list 'load-path default-directory)
        (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
            (normal-top-level-add-subdirs-to-load-path))))))
(add-to-load-path "elisp")

;; PATH
(setq shell-file-name "/usr/local/bin/zsh");;zshenv見に行く
(add-to-list 'exec-path "/opt/local/bin")
(add-to-list 'exec-path "/usr/local/bin")
(setenv "PATH" (mapconcat 'identity exec-path ":"))

;; proxy
(defun activate-kgu-proxy ()
  (interactive)
  (setq url-proxy-services
        '(("http" . "proxy.ksc.kwansei.ac.jp:8080")
          ("https" . "proxy.ksc.kwansei.ac.jp:8080"))))
(defun deactivate-proxy ()
  (interactive)
  (setq url-proxy-services
        '(("no_proxy" . ""))))
(deactivate-proxy)

;; auto-install
;; (install-elisp "http://www.emacswiki.org/emacs/download/auto-install.el")
(when (require 'auto-install nil t)
  (setq auto-install-directory "~/.emacs.d/elisp/")
  (auto-install-update-emacswiki-package-name t)
  (auto-install-compatibility-setup))

;; window
(setq inhibit-startup-message t) ;スタートアップメッセージ消す
;(tool-bar-mode 0) ;ツールバー無し
(menu-bar-mode t) ;メニューバー無し
(setq frame-title-format (format "%%f - emacs@%s" (system-name))) ;タイトルバーにパス表示
(display-time) ;バーに時刻表示
(column-number-mode t) ;バーにカーソル位置表示
(blink-cursor-mode t) ;カーソル点滅
;(global-linum-mode t) ;行番号表示

;;color-theme
(if window-system
    (progn
      (when (require 'color-theme nil t)
        (color-theme-initialize)
        ;;(color-theme-clarity)
        ;;(color-theme-euphoria)
        (color-theme-gnome2)
        ;;(color-theme-gray30)
        ;;(color-theme-robin-hood)
        ;;(color-theme-subtle-hacker)
        ;;(color-theme-dark-laptop)
        ;;(color-theme-hober)
        )
      )
    )

;;paren
(setq show-paren-delay 0) ;カッコ強調表示ディレイ0
(show-paren-mode t) ;カッコ強調表示
(setq show-paren-style 'expression) ;カッコ内強調表示
(set-face-background 'show-paren-match-face nil) ;カッコ内背景強調オフ
(set-face-underline-p 'show-paren-match-face "yellow") ;カッコ内アンダーライン


(cd "~/") ;カレントディレクトリをHOMEに

;;backup
(setq backup-directory-alist '(("" . "~/.emacs.d/backup"))) ;backup先
(setq version-control t)
(setq kept-new-version 5)
(setq kept-old-version 5)
(setq vc-make-backup-files t)

;;indent
(setq-default tab-width 2) ;タブ幅を2に設定
(setq tab-stop-list '(2 4 6 8 10 12 14 16 18 20 22 24)) ;タブ幅の倍数を設定
(setq-default indent-tabs-mode nil) ;タブではなくスペースを使う
(setq indent-line-function 'indent-relative-maybe)

;;line
(setq line-move-visual t) ;物理行移動
(global-set-key "\C-c\C-l" 'toggle-truncate-lines) ;C-c C-l で行折り返しon/off

(defface my-hl-line-face ;themeの背景に応じたカーソル行強調
  '((((class color) (background dark))
     (:background "MidnightBlue" t))
    (((class color) (background light))
     (:background "LightGoldenrodYellow" t))
    (t (:bold t)))
  "hl-line's my face")
(setq hl-line-face 'my-hl-line-face)
(global-hl-line-mode t) ;カーソル行強調オン

;;col-highlight
(require 'col-highlight)
(col-highlight-set-interval 1)
(col-highlight-toggle-when-idle t)
(setq col-highlight-face 'my-hl-line-face)

;;charset in mac
(set-language-environment "Japanese")
;; (require 'ucs-normalize)
(prefer-coding-system 'utf-8)
;; (setq file-name-coding-system 'utf-8-hfs)
;; (setq locale-coding-system 'utf-8-hfs)

(cond
 ((or (eq window-system 'mac) (eq window-system 'ns))
  ;; Mac OS X の HFS+ ファイルフォーマットではファイル名は NFD (の様な物)で扱うため以下の設定をする必要がある
  (require 'ucs-normalize)
  (setq file-name-coding-system 'utf-8-hfs)
  (setq locale-coding-system 'utf-8-hfs))
 ((or (eq system-type 'cygwin) (eq system-type 'windows-nt)
     (setq file-name-coding-system 'utf-8)
     (setq locale-coding-system 'utf-8)
     ;; もしコマンドプロンプトを利用するなら sjis にする
     ;; (setq file-name-coding-system 'sjis)
     ;; (setq locale-coding-system 'sjis)
     ;; 古い Cygwin だと EUC-JP にする
     ;; (setq file-name-coding-system 'euc-jp)
     ;; (setq locale-coding-system 'euc-jp)
     ))
 (t
  (setq file-name-coding-system 'utf-8)
  (setq locale-coding-system 'utf-8)))

;charset in unix
;; (set-language-environment "Japanese")
;; (set-terminal-coding-system 'utf-8)
;; (set-keyboard-coding-system 'utf-8)
;; (set-buffer-file-coding-system 'utf-8-unix)
;; (setq default-buffer-file-coding-system 'utf-8)
;; (prefer-coding-system 'utf-8)
;; (set-default-coding-systems 'utf-8)
;; (setq file-name-coding-system 'utf-8)
;; (set-clipboard-coding-system 'utf-8)
;; (setq default-input-method 'japanese-anthy)

;Command Option入れ替え in Mac
(setq ns-command-modifier (quote meta))
(setq ns-alternate-modifier (quote super))
;システムに修飾キーを渡さない in Mac
;; (setq mac-pass-control-to-system nil)
;; (setq mac-pass-command-to-system nil)
;; (setq mac-pass-option-to-system nil)


(global-set-key (kbd "C-h") 'delete-backward-char)
(global-set-key (kbd "C-x ?") 'help-command) ;C-x ? をhelp-command
(global-set-key (kbd "C-Q") 'quoted-insert)

;;cua 矩形選択
(cua-mode t)
(setq cua-enable-cua-keys nil)

;;@レジスタコピペ C-w or M-w が連続で押されたらレジスタ@にコピペ
(defvar clipboard-register ?@)
(defadvice kill-region (before clipboard-cut activate)
  (when (eq last-command this-command)
    (set-register clipboard-register (car kill-ring))
    (message "Copy to clipboard")))
(defadvice kill-ring-save (before clipboard-copy activate)
  (when (eq last-command this-command)
    (set-register clipboard-register (car kill-ring))
    (message "Copy to clipboard")))

(defun clipboard-paste ()
  (interactive)
  (insert-register clipboard-register)
  (message "Paste from clipboard"))
(global-set-key (kbd "C-M-y") 'clipboard-paste) ;C-M-y でレジスタ@から貼り付け

;;search region リージョン選択中にC-sで選択範囲で検索
(defadvice isearch-mode (around isearch-mode-default-string (forward &optional regexp op-fun recursive-edit word-p) activate)
  (if (and transient-mark-mode mark-active (not (eq (mark) (point))))
      (progn
        (isearch-update-ring (buffer-substring-no-properties (mark) (point)))
        (deactivate-mark)
        ad-do-it
        (if (not forward)
            (isearch-repeat-backward)
          (goto-char (mark))
          (isearch-repeat-forward)))
    ad-do-it))

(require 'thing-opt) ;範囲選択コマンド
(define-thing-commands)
(global-set-key (kbd "C-$") 'mark-word*)
(global-set-key (kbd "C-\"") 'mark-string)
(global-set-key (kbd "C-(") 'mark-up-list)


;;parenthesis
;;http://d.hatena.ne.jp/khiker/20080118/parenthesis
(require 'parenthesis)
(parenthesis-register-keys "{('\"[" global-map)


;;Font
(if window-system
    (progn
      (set-face-attribute 'default nil
                          ;:family "Inconsolata"
                          ;:family "Consolas"
                          :family "VL Gothic"
                          ;:family "Ricty"
                          :height 130)
      (set-fontset-font "fontset-default"
                        'japanese-jisx0208
                        '("NfMotoyaCedar" . "iso10646-1"))
      (set-fontset-font "fontset-default"
                        'katakana-jisx0201
                        '("NfMotoyaCedar" . "iso10646-1"))
      )
  )
;; (when window-system
;;   (cond
;;    ((eq window-system 'x)
;;     (set-default-font "VL ゴシック-10")
;;     (set-fontset-font
;;      (frame-parameter nil 'font)
;;      'japanese-jisx0208
;;      '("VL ゴシック" . "unicode-bmp"))
;;     )
;;    ((eq window-system 'mac)
;;     (set-face-attribute 'default nil
;;                         :family "vl gothic"
;;                         :height 120)
;; ;    (set-fontset-font "fontset-default"
;; ;                      'japanese-jisx0208
;; ;                      '("vl gothic" . "jisx0201.*"))
;;     )
;;    )
;;   )


;;全角SPC、tab、行末スペースを強調表示
(defface my-face-b-1 '((t (:background "medium aquamarine"))) nil)
(defface my-face-b-2 '((t (:background "gray26"))) nil)
(defface my-face-u-1 '((t (:foreground "SteelBlue" :underline t))) nil)
(defvar my-face-b-1 'my-face-b-1)
(defvar my-face-b-2 'my-face-b-2)
(defvar my-face-u-1 'my-face-u-1)
(defadvice font-lock-mode (before my-font-lock-mode ())
  (font-lock-add-keywords
   major-mode
   '(
     ("　" 0 my-face-b-1 append)
     ("\t" 0 my-face-b-2 append)
     ("[ ]+$" 0 my-face-u-1 append)
     )))
(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
(ad-activate 'font-lock-mode)
(add-hook 'find-file-hooks '(lambda ()
                              (if font-lock-mode nil
                                (font-lock-mode t))) t)

;;moccur
;(install-elisp "http://www.emacswiki.org/emacs/download/color-moccur.el")
;(install-elisp "http://www.emacswiki.org/emacs/download/moccur-edit.el")
(when (require 'color-moccur nil t)
  (define-key global-map (kbd "M-o") 'occur-by-moccur) ;M-o occur-by-moccur
  (setq moccur-split-word t)
  (add-to-list 'dmoccur-exclusion-mask "^#.+#$")
  (require 'moccur-edit nil t)
  (when (and (executable-find "cmigemo")
             (require 'migemo nil t))
    (setq moccur-user-migemo t)))
;使い方TODO

;;grep
(require 'grep) ;lgrepで直下をgrep、rgrepで再帰的に
;;grep-edit
;(install-elisp "http://www.emacswiki.org/emacs/download/grep-edit.el")
(require 'grep-edit) ;C-c C-e で編集を反映 C-x s ! で全部保存

;;migemo
(when (and (executable-find "cmigemo")
           (require 'migemo nil t))
  (setq migemo-command "cmigemo")
  (setq migemo-options '("-q" "--emacs" "-i" "\a"))
  (setq migemo-dictionary (expand-file-name "~/.emacs.d/etc/migemo/migemo-dict"))
  (setq migemo-user-dictionary nil)
  (setq migemo-regex-dictionary nil)
  (setq migemo-user-pattern-alist t)
  (setq migemo-use-frequent-pattern-alist t)
  (setq migemo-pattern-alist-length 1000)
  (setq migemo-coding-system 'utf-8-unix)
  (migemo-init))

;:redo C-'でリドゥ
(when (require 'redo+ nil t)
  (global-set-key (kbd "C-'") 'redo))

;;undo-hist バッファを保存して消してもアンドゥで戻れる
;(install-elisp "http://cx4a.org/pub/undohist.el")
(when (require 'undohist nil t)
  (undohist-initialize))

;;undo-tree
;(install-elisp "http://dr-qubit.org/undo-tree/undo-tree.el")
(when (require 'undo-tree nil t)
  (global-undo-tree-mode))
;C-x u でundoの履歴を視覚化したバッファがでる、移動してqで抜ければその状態まで戻る

;;point-undo
;(install-elisp "http://www.emacswiki.org/cgi-bin/wiki/download/point-undo.el")
(when (require 'point-undo nil t)
  (define-key global-map [f5] 'point-undo)
  (define-key global-map [f6] 'point-redo))

;;wdired
(require 'wdired)
(define-key dired-mode-map "r"
  'wdired-change-to-wdired-mode)

;;auto-complete
(when (require 'auto-complete-config nil t)
  (ac-config-default)
  (add-to-list 'ac-dictionary-directories (expand-file-name "~/.emacs.d/ac-dict"))
  (global-set-key (kbd "M-i") 'auto-complete)
  (define-key ac-mode-map (kbd "M-TAB") 'auto-complete)
  (global-auto-complete-mode t)
  (setq ac-auto-start 2)
  (setq ac-auto-show-menu 0.5)
  (setq ac-ignore-case t)
  (define-key ac-complete-mode-map (kbd "M-n") 'ac-next)
  (define-key ac-complete-mode-map (kbd "M-p") 'ac-previous)
  (ac-set-trigger-key "TAB")
  (setq popup-use-optimized-column-computation t)
  (auto-complete-mode t)
  )

;;smartchr
;(install-elisp "http://github.com/imakado/emacs-smartchr/raw/master/smartchr.el")
(when (require 'smartchr nil t)
  (define-key global-map (kbd "=") (smartchr '("=" "==" "===")))
  (define-key global-map (kbd "+") (smartchr '("+" "++")))
  (define-key global-map (kbd "{") (smartchr '("{ `!!' }" "{")))
  (define-key global-map (kbd ">")
    (smartchr '(">" "=>" "=> '`!!''" "=> \"`!!'\"")))
  (define-key global-map (kbd "|")
    (smartchr '("|" "|`!!'|" " || " )))
  (define-key global-map (kbd "\"")
    (smartchr '("\"" "\"`!!'\"" "\"\"\"`!!'\"\"\"")))
  (define-key global-map (kbd "'")
    (smartchr '("'" "'`!!''")))
  )

;;skeleton括弧補完
(setq skeleton-pair 1)
;;parenthesis
(parenthesis-register-keys "{('\"[" text-mode-map)


;;Anything
;(auto-install-batch "anything")
(when (require 'anything nil t)
  (setq
   anything-idle-delay 0.2
   anything-input-idle-delay 0.1
   anything-candidate-number-limit 100
   anything-quick-update t
   anything-enable-shortcuts 'alphabet)

  (custom-set-variables '(anything-command-map-prefix-key (kbd "C-c C-f")))
  (define-key global-map (kbd "C-c C-f SPC") 'anything-execute-anything-command)
  ;(define-key global-map (kbd "C-c C-c") 'anything-filelist+)
  (define-key global-map (kbd "C-c C-c") 'anything-for-files)
  (define-key global-map [f7] 'anything-filelist+)
  (define-key global-map (kbd "C-;") 'anything-project)
  (define-key anything-map (kbd "M-n") 'anything-next-source)
  (define-key anything-map (kbd "M-p") 'anything-previous-source)
  (define-key anything-map (kbd "C-v") 'anything-next-source)
  (define-key anything-map (kbd "M-v") 'anything-previous-source)
  (define-key anything-map (kbd "C-h") 'delete-backward-char)

  (when (require 'anything-startup nil t)
    (setq anything-su-or-sudo "sudo"))

  (require 'anything-match-plugin nil t)
  (and (equal current-language-environment "Japanese")
       (executable-find "cmigemo")
       (require 'anything-migemo nil t))

  (when (require 'anything-complete nil t)
    ;(anything-read-string-mode 1)
    (anything-lisp-complete-symbol-set-timer 150))

  (require 'anything-show-completion nil t)

  (when (require 'auto-install nil t)
    (require 'anything-auto-install nil t))

  (require 'anything-grep nil t)

  (when (require 'descbinds-anything nil t)
    (descbinds-anything-install)
    (define-key global-map (kbd "C-x C-h") 'descbinds-anything))

  (global-set-key (kbd "M-y") 'anything-show-kill-ring) ;M-yでkill-ringをanything選択

  ;anything-projectでgit等のバージョン管理対象からanything
  ;(install-elisp "http://github.com/imakado/anything-project/raw/master/anything-project.el")
  (when (require 'anything-project nil t)
    (setq ap:project-files-filters
          '((lambda (files)
              (remove-if 'file-directory-p files)
              (remove-if '(lambda (file) (string-match-p "~$" file)) files)))))

  ;moccurをanythingで
  ;(install-elisp "http://svn.coderepos.org/share/lang/elisp/anything-c-moccur/trunk/anything-c-moccur.el")
  (when (require 'anything-c-moccur nil t)
    (setq
     anything-c-moccur-anything-idle-delay 0.1
     lanything-c-moccur-highlight-info-line-flag t
     anything-c-moccur-enable-auto-look-flag t
     anything-c-moccur-enable-initial-pattern t))
  (global-set-key (kbd "C-M-o") 'anything-c-moccur-occur-by-moccur)

  )

;;yasnippet
(when (require 'yasnippet nil t)
  (require 'yasnippet-bundle)
  (setq yas/my-directory (expand-file-name "~/.emacs.d/etc/snippets"))
  (yas/load-directory yas/my-directory)
  (yas/initialize))

;;http://tech.lampetty.net/tech/index.php/archives/384
(require 'dropdown-list)
(setq yas/text-popup-function #'yas/dropdown-list-popup-for-template)
;; コメントやリテラルではスニペットを展開しない
(setq yas/buffer-local-condition
      '(or (not (or (string= "font-lock-comment-face"
                             (get-char-property (point) 'face))
                    (string= "font-lock-string-face"
                             (get-char-property (point) 'face))))
           '(require-snippet-condition . force-in-comment)))
 
;;; yasnippet展開中はflymakeを無効にする
(defvar flymake-is-active-flag nil)
(defadvice yas/expand-snippet
  (before inhibit-flymake-syntax-checking-while-expanding-snippet activate)
  (setq flymake-is-active-flag
        (or flymake-is-active-flag
            (assoc-default 'flymake-mode (buffer-local-variables))))
  (when flymake-is-active-flag
    (flymake-mode-off)))
(add-hook 'yas/after-exit-snippet-hook
          '(lambda ()
             (when flymake-is-active-flag
               (flymake-mode-on)
               (setq flymake-is-active-flag nil))))

;; あとから読みこんだ自分用のものが優先される。
;; また、スニペットを変更、追加した場合、
;; このコマンドを実行することで、変更・追加が反映される。
(defun yas/load-all-directories ()
  (interactive)
  (yas/reload-all)
  (mapc 'yas/load-directory-1 my-snippet-directories))

;;元からあるやつ
(setq yas/root-directory (expand-file-name "~/.emacs.d/etc/snippets"))

;; 自分用スニペットディレクトリ(リストで複数指定可)
(defvar my-snippet-directories
  (list (expand-file-name "~/.emacs.d/etc/mysnippets")))

(yas/initialize)
(yas/load-all-directories)




;;shell ;使わなさそう
;(install-elisp-from-emacswiki "multi-term.el")
(when (require 'multi-term nil t)
  (setq multi-term-program "/usr/local/bin/zsh"))
(add-hook 'shell-mode-hook ;shell-modeで上下でヒストリ補完
   (function (lambda ()
      (define-key shell-mode-map [up] 'comint-previous-input)
      (define-key shell-mode-map [down] 'comint-next-input))))


;;Outputz
;; (when (require 'outputz nil t)
;;   (setq outputz-key "UYUaZynGnr3M");; 復活の呪文
;;   (setq outputz-uri "http://%s") ;; 適当なURL。%sにmajor-modeの名前が入るので、major-modeごとのURLで投稿できます。
;;   (global-outputz-mode t))

;;zizo
(require 'zizo)

;;htmlize
(require 'htmlize)

;;dict
;http://github.com/hitode909/dotfiles/raw/master/emacs.d/config/dictionary-config.el
(require 'dictionary-config)
(global-set-key (kbd "C-M-d") 'my-dictionary)
(setq dict-log-file "~/Dropbox/memo/dictionaly.txt")

;;flyspell
(defun flyspell-correct-word-popup-el ()
  "Pop up a menu of possible corrections for misspelled word before point."
  (interactive)
  ;; use the correct dictionary
  (flyspell-accept-buffer-local-defs)
  (let ((cursor-location (point))
        (word (flyspell-get-word nil)))
    (if (consp word)
        (let ((start (car (cdr word)))
              (end (car (cdr (cdr word))))
              (word (car word))
              poss ispell-filter)
          ;; now check spelling of word.
          (ispell-send-string "%\n") ;put in verbose mode
          (ispell-send-string (concat "^" word "\n"))
          ;; wait until ispell has processed word
          (while (progn
                   (accept-process-output ispell-process)
                   (not (string= "" (car ispell-filter)))))
          ;; Remove leading empty element
          (setq ispell-filter (cdr ispell-filter))
          ;; ispell process should return something after word is sent.
          ;; Tag word as valid (i.e., skip) otherwise
          (or ispell-filter
              (setq ispell-filter '(*)))
          (if (consp ispell-filter)
              (setq poss (ispell-parse-output (car ispell-filter))))
          (cond
           ((or (eq poss t) (stringp poss))
            ;; don't correct word
            t)
           ((null poss)
            ;; ispell error
            (error "Ispell: error in Ispell process"))
           (t
            ;; The word is incorrect, we have to propose a replacement.
            (flyspell-do-correct (popup-menu* (car (cddr poss)) :scroll-bar t :margin t)
                                 poss word cursor-location start end cursor-location)))
          (ispell-pdict-save t)))))
;; 修正したい単語の上にカーソルをもっていき, C-M-return を押すことで候補を選択
(add-hook 'flyspell-mode-hook
          (lambda ()
            (define-key flyspell-mode-map (kbd "<C-M-return>") 'flyspell-correct-word-popup-el)
            ))
(add-to-list 'auto-mode-alist '("\\.txt" . flyspell-mode))
(add-to-list 'auto-mode-alist '("\\.tex" . flyspell-mode))
(add-to-list 'auto-mode-alist '("\\.properties" . flyspell-mode))
(add-to-list 'auto-mode-alist '("\\.dtd" . flyspell-mode))

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


;;ack
(defun ack ()
  (interactive)
  (let ((grep-find-command "ack --nocolor --nogroup "))
    (call-interactively 'grep-find)))

