;;; display-deadline.el --- Display the rest time to the deadline

;; Copyright (C) 2002 TSUCHIYA Masatoshi <tsuchiya@namazu.org>

;; Author: TSUCHIYA Masatoshi <tsuchiya@namazu.org>
;; Keywords: misc
;; Version: $Revision: 1.3 $

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, you can either send email to this
;; program's maintainer or write to: The Free Software Foundation,
;; Inc.; 59 Temple Place, Suite 330; Boston, MA 02111-1307, USA.

;;; Commentary:

;; This file provides the function to display the rest time to the
;; deadline in the mode line.

;; The latest version of this program can be downloaded from
;; http://namazu.org/~tsuchiya/elisp/display-deadline.el.

;;; Install:

;; (1) Put this file to the appropriate directory.
;; (2) Put these expressions to your ~/.emacs.
;;
;;     (require 'display-deadline)
;;     (display-deadline "%d days remains to the end of the year"
;;                       (encode-time 0 0 0 1 1 2003))
;;
;; (3) When you use XEmacs, the following expression is also required.
;;
;;     (setq display-time-compatible t)

;;; Code:

(eval-and-compile
  (if (>= emacs-major-version 20)
      (require 'time)))

(defun display-deadline (format deadline)
  "Display the rest time to the DEADLINE with the FORMAT in the mode line.
The following `%' escapes are available for use in FORMAT string:

%d is the number of rest dates to the DEADLINE.
%h is the hours.
%m is the minutes.
%H is the number of rest hours to the DEADLINE.
%M is the number of rest minutes to the DEADLINE.
%% is a literal '%'.
"
  (if (let ((now (current-time)))
	(>= (+ (* 65536 (- (nth 0 deadline) (nth 0 now)))
	       (- (nth 1 deadline) (nth 1 now))) 0))
      (let ((table '(("%%" "%%" nil)
		     ("%d" "%d" (/ sec 86400))
		     ("%h" "%02d" (/ (mod sec 86400) 3600))
		     ("%m" "%02d" (/ (mod sec 3600) 60))
		     ("%H" "%d" (/ sec 3600))
		     ("%M" "%d" (/ sec 60))))
	    (start 0)
	    buf sexp)
	(while (string-match "%." format start)
	  (setq buf (cons (substring format start (match-beginning 0)) buf))
	  (let ((x (assoc (match-string 0 format) table)))
	    (if x
		(setq buf (cons (nth 1 x) buf)
		      sexp (if (nth 2 x) (cons (nth 2 x) sexp) sexp))
	      (setq buf (cons (concat "%" (match-string 0 format)) buf))))
	  (setq start (match-end 0)))
	(setq display-time-string-forms
	      `((let* ((now (current-time))
		       (sec (+ (* 65536 (- ,(nth 0 deadline) (nth 0 now)))
			       (- ,(nth 1 deadline) (nth 1 now)))))
		  (if (>= sec 0)
		      (format ,(apply (function concat)
				      (nreverse
				       (cons (substring format start) buf)))
			      ,@(nreverse sexp))))))
	(display-time))))

(provide 'display-deadline)

;;; display-deadline.el ends here.
