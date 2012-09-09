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
  (let ((region (buffer-substring start end)))
    (call-process-region start end "ruby" t t nil "-e"
                         (format "%s=%%q[%s]; %s" rrruby:region-variable region expr))))

(provide 'replace-region-by-ruby)
