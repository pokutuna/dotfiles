(require 'flymake)

(setq flymake-gui-warnings-enabled nil) ; GUIの警告は表示しない
;(add-hook 'find-file-hook 'flymake-find-file-hook) ; 全てのファイルで flymakeを有効化


;; keybind
(add-hook
 'flymake-mode-hook
 '(lambda ()
    (local-set-key (kbd "M-n") 'flymake-goto-next-error)
    (local-set-key (kbd "M-p") 'flymake-goto-prev-error)))



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
            (define-key flyspell-mode-map (kbd "<C-M-i>") 'flyspell-correct-word-popup-el)
            (define-key flyspell-mode-map (kbd "M-n") 'flyspell-goto-next-error)
            ;(define-key flyspell-mode-map (kbd "M-p") 'flymake-goto-prev-error)
            ))

(add-to-list 'auto-mode-alist '("\\.txt" . flyspell-mode))
(add-to-list 'auto-mode-alist '("\\.tex" . flyspell-mode))
(add-to-list 'auto-mode-alist '("\\.properties" . flyspell-mode))
(add-to-list 'auto-mode-alist '("\\.dtd" . flyspell-mode))
