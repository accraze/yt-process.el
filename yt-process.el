;; yt-process.el --- Process YouTube videos with fabric patterns -*- lexical-binding: t -*-

;; Copyright (C) 2025 accraze
;; Author: Andy Craze <accraze@gmail.com>
;; Version: 0.1.0
;; Package-Requires: ((emacs "27.1"))
;; Keywords: multimedia, youtube
;; URL: https://github.com/yourusername/yt-process

;;; Commentary:
;; This package provides functionality to process YouTube videos using
;; the yt and fabric command line tools.  It supports various processing
;; patterns like summarize and extract_wisdom.

;;; Code:

(defgroup yt-process nil
  "YouTube video processing with fabric patterns."
  :group 'external
  :prefix "yt-process-")

(defcustom yt-process-patterns
  '("summarize" "extract_wisdom")
  "List of available fabric processing patterns."
  :type '(repeat string)
  :group 'yt-process)

(defcustom yt-process-default-pattern "summarize"
  "Default pattern to use for processing."
  :type 'string
  :group 'yt-process)

(defun yt-process--validate-url (url)
  "Validate if URL is a proper YouTube URL."
  (string-match-p
   "^https?://\\(?:www\\.\\)?\\(?:youtube\\.com/watch\\?v=\\|youtu\\.be/\\)[A-Za-z0-9_-]+"
   url))

(defun yt-process--check-dependencies ()
  "Check if required command line tools are available."
  (let ((missing-deps (seq-filter (lambda (cmd) (not (executable-find cmd)))
                                  '("yt" "fabric"))))
    (when missing-deps
      (error "Missing required commands: %s" (mapconcat #'identity missing-deps ", ")))))

(defun yt-process-video (url &optional pattern)
  "Process YouTube video at URL using specified PATTERN.
If PATTERN is nil, use `yt-process-default-pattern'."
  (interactive "sYouTube URL: ")
  ;; Validate inputs
  (unless (yt-process--validate-url url)
    (error "Invalid YouTube URL: %s" url))
  (let ((pattern (or pattern yt-process-default-pattern)))
    (unless (member pattern yt-process-patterns)
      (error "Invalid pattern: %s" pattern))

    ;; Check dependencies
    (yt-process--check-dependencies)

    ;; Create buffer for output
    (let ((buf (get-buffer-create "*YouTube Processing*")))
      (with-current-buffer buf
        (erase-buffer)
        (insert (format "Processing video: %s\nPattern: %s\n\n" url pattern)))

      ;; Run process
      (make-process
       :name "yt-process"
       :buffer buf
       :command (list "bash" "-c"
                      (format "yt '%s' | fabric --pattern '%s'" url pattern))
       :sentinel (lambda (process event>)
                   (when (string= event "finished\n")
                     (message "YouTube processing completed"))))

      ;; Display buffer
      (display-buffer buf))))

;;;###autoload
(defun yt-process-video-with-pattern (url)
  "Process YouTube video at URL, prompting for pattern choice."
  (interactive "sYouTube URL: ")
  (let ((pattern (completing-read "Processing pattern: " yt-process-patterns
                                  nil t nil nil yt-process-default-pattern)))
    (yt-process-video url pattern)))

(provide 'yt-process)
;;; yt-process.el ends here
