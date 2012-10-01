;; replace-region-by-ruby.el

(defvar rrbruby:ruby-command "ruby"
  "command or path to Ruby interpreter")

(defvar rrbruby:region-variable "R"
  "variable name which region assigned as an instance of String in Ruby")

(defvar rrbruby:history nil)

(defun rrbruby:read-string ()
  (read-string "ruby: "
               (or (nth 0 rrbruby:history)
                   (format "print %s." rrbruby:region-variable))
               'rrbruby:history))

(defun rrbruby:escape-for-rubystring (string)
  (let ((replace-pat '(("\\\\" . "\\\\\\\\") ("'" . "\\\\'")))
        (buf-string string))
    (dolist (pat replace-pat buf-string)
      (setq buf-string (replace-regexp-in-string (car pat) (cdr pat) buf-string t)))))

(defun replace-region-by-ruby (start end expr)
  (interactive (list (region-beginning) (region-end) (rrbruby:read-string)))
  (unless (executable-find rrbruby:ruby-command) (error "ruby command not found"))
  (let ((script (make-temp-name (expand-file-name "rrbruby" temporary-file-directory)))
        (stderr (make-temp-name (expand-file-name "rrbrerr" temporary-file-directory)))
        (region (buffer-substring start end))
        (status))
    (write-region (format "%s='%s'; %s" rrbruby:region-variable
                          (rrbruby:escape-for-rubystring region) expr) nil script)
    (setq status (call-process-region
                  start end rrbruby:ruby-command t (list t stderr) nil script))
    (if (eq status 0)
        (message "rrbruby done!")
      (insert region)
      (let ((errbuf (find-file-noselect stderr)))
        (with-current-buffer errbuf
          (goto-char (point-min))
          (message (buffer-substring (search-forward ":") (point-max))))
        (kill-buffer errbuf)))
    (delete-file script)
    (delete-file stderr)
    ))

(defalias 'rrbruby (symbol-function 'replace-region-by-ruby))

(provide 'replace-region-by-ruby)
