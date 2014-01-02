;; http://e-arrows.sakura.ne.jp/2010/03/macros-in-emacs-el.html

;; ---
(defmacro add-hook-fn (name &rest body)
  `(add-hook ,name #'(lambda () ,@body)))

;; ;; 普通の設定例
;; (add-hook 'php-mode-hook
;;           #'(lambda ()
;;               (require 'symfony)
;;               (setq tab-width 2)))

;; ;; 改善案
;; (add-hook-fn 'php-mode-hook
;;              (require 'symfony)
;;              (setq tab-width 2))


;; ---
(defmacro global-set-key-fn (key args &rest body)
  `(global-set-key ,key (lambda ,args ,@body)))

;; ;; 普通の設定例
;; (global-set-key-fn (kbd "C-M-h") (lambda () (interactive) (move-to-window-line 0)))
;; (global-set-key-fn (kbd "C-M-m") (lambda () (interactive) (move-to-window-line nil)))
;; (global-set-key-fn (kbd "C-M-l") (lambda () (interactive) (move-to-window-line -1)))

;; ;; 改善案
;; (global-set-key-fn (kbd "C-M-h") nil (interactive) (move-to-window-line 0))
;; (global-set-key-fn (kbd "C-M-m") nil (interactive) (move-to-window-line nil))
;; (global-set-key-fn (kbd "C-M-l") nil (interactive) (move-to-window-line -1))


;; ---
(defmacro append-to-list (to lst)
  `(setq ,to (append ,lst ,to)))

;; ;; 普通の設定例
;; (setq exec-path
;;       (append
;;         '("/usr/bin" "/bin"
;;           "/usr/sbin" "/sbin" "/usr/local/bin"
;;           "/usr/X11/bin")
;;         exec-path))

;; ;; 改善案
;; (append-to-list exec-path
;;                 '("/usr/bin" "/bin"
;;                   "/usr/sbin" "/sbin" "/usr/local/bin"
;;                   "/usr/X11/bin"))


;; ---
(defmacro req (lib &rest body)
  `(when (locate-library ,(symbol-name lib))
     (require ',lib) ,@body))

;; ;; 普通の設定例
;; (when (locate-library "elscreen")
;;   (require 'elscreen)
;;   ...)

;; ;; 改善案
;; (req elscreen
;;   ...)


;; ---
(defmacro lazyload (func lib &rest body)
  `(when (locate-library ,lib)
     ,@(mapcar (lambda (f) `(autoload ',f ,lib nil t)) func)
     (eval-after-load ,lib
       '(progn
          ,@body))))


;; ;; 使用例
;; (lazyload (php-mode) "php-mode"
;;           (req symfony))
;; ;; add-hookは外に書く
;; (add-hook-fn 'php-mode-hook
;;              (setq tab-width 2)
;;              (c-set-offset 'arglist-intro '+)
;;              (c-set-offset 'arglist-close 0))
