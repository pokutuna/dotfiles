(defvar rrruby:region-variable "R")

(defvar rrruby:history nil)

(defun replace-region-by-ruby (start end expr)
  (interactive (list (region-beginning) (region-end)
                     (read-string "ruby: "
                                  (or (nth 0 rrruby:history)
                                      (format "puts %s." rrruby:region-variable))
                                  'rrruby:history)))
  (unless (executable-find "ruby")
    (error "ruby command not found"))
  (let ((tempfile (make-temp-name (expand-file-name "rrruby" temporary-file-directory)))
        (region (buffer-substring start end))
        (sha1 (sha1 expr)))
    (write-region (format "%s=<<%s\n%s\%s\n%s" rrruby:region-variable sha1 region sha1 expr)
                  nil tempfile)
    (call-process-region start end "ruby" t t nil tempfile)
    (delete-file tempfile)
    (message "done!")))

(provide 'replace-region-by-ruby)
