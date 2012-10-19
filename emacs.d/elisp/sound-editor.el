;;; sound-editor.el --- give sound feedback to input
;; Usage:
;;   (require 'sound-editor)
;;   on:  M-x start-sound-editor
;;   off: M-x exit-sound-editor

(require 'cl)
(require 'deferred)

(defvar sound-editor:enabled nil)
(defvar sound-editor:dribble-file-path nil)
(defvar sound-editor:tail-process nil)
(defvar sound-editor:say-processes nil)
(defvar sound-editor:say-process-index 0)
(defvar sound-editor:say-process-size 10)

(defun sound-editor:startup-say-processes ()
  (sound-editor:delete-say-processes)
  (setq sound-editor:say-processes nil)
  (let ((i 0))
    (while (< i sound-editor:say-process-size)
      (setq sound-editor:say-processes
            (cons (sound-editor:new-say-process) sound-editor:say-processes))
      (setq i (1+ i)))))

(defun sound-editor:new-say-process ()
  (let ((process (start-process "sound-editor:say" nil "say")))
    (set-process-sentinel process 'sound-editor:say-process-sentinel)
    process))

(defun sound-editor:delete-say-processes ()
  (if (listp sound-editor:say-processes)
      (dolist (process sound-editor:say-processes)
        (if (processp process) (delete-process process)))))

(defun sound-editor:say-balanced (msg)
  (let ((process))
    (if (not (< sound-editor:say-process-index sound-editor:say-process-size))
        (setq sound-editor:say-process-index 0))
    (setq process (nth sound-editor:say-process-index sound-editor:say-processes))
    (if (processp process)
        (process-send-string process (concat msg "\n")))
    (setq sound-editor:say-process-index (1+ sound-editor:say-process-index))))

(defun sound-editor:sound-editor-filter (process input)
  (lexical-let ((in input))
  (deferred:$
    (deferred:next (lambda () (sound-editor:filter-keyname in)))
    (deferred:nextc it (lambda ($) (sound-editor:parse-not-ascii $)))
    (deferred:nextc it (lambda ($) (sound-editor:say-balanced $)))
    )))
;; (defun sound-editor:sound-editor-filter (process input)
;;   (sound-editor:say-balanced
;;    (sound-editor:parse-not-ascii (sound-editor:filter-keyname input))))

(defun sound-editor:say-process-sentinel (process event)
  (let ((index (position process sound-editor:say-processes)))
    (delete-process process)
    (if (and index sound-editor:enabled)
        (setf (nth index sound-editor:say-processes) (sound-editor:new-say-process)))))

(defun sound-editor:parse-not-ascii (input)
  (sound-editor:replace-match-by-func
   "0x[0-9a-f]*" input
   (lambda (match)
     (or (ignore-errors (string (string-to-number (substring match 2) 16))) ""))))

(defun sound-editor:filter-keyname (input)
  (sound-editor:replace-match-by-func
   "<[^>]*>" input
   (lambda (match)
     (or (if (not (string-match ".*echo.*" match)) (substring match 1 -1)) ""))))

(defun sound-editor:replace-match-by-func (regexp string lambda)
  (let ((strbuf string))
    (while (string-match regexp strbuf)
      (setq strbuf
            (replace-match
             (funcall lambda (substring strbuf (match-beginning 0) (match-end 0)))
             nil nil strbuf) ))
    strbuf))

(defun start-sound-editor ()
  (interactive)
  (unless (executable-find "say") (error "`say` command not found"))
  (unless (executable-find "tail") (error "`tail` command not found"))
  (setq sound-editor:enabled t)
  (setq sound-editor:dribble-file-path
        (make-temp-name (expand-file-name temporary-file-directory)))
  (open-dribble-file sound-editor:dribble-file-path)
  (sound-editor:startup-say-processes)
  (if (processp sound-editor:tail-process) (delete-process sound-editor:tail-process))
  (setq sound-editor:tail-process
        (start-process "sound-editor-sound-editor:tail-process" nil "tail" "-f" sound-editor:dribble-file-path))
  (set-process-filter sound-editor:tail-process 'sound-editor:sound-editor-filter)
  (sound-editor:say-balanced "start sound editor"))

(defun exit-sound-editor ()
  (interactive)
  (setq sound-editor:enabled nil)
  (open-dribble-file nil)
  (delete-file sound-editor:dribble-file-path)
  (sound-editor:delete-say-processes)
  (delete-process sound-editor:tail-process))

(provide 'sound-editor)
