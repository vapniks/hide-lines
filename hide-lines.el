;;; hide-lines.el --- Commands for hiding lines based on a regexp

;; Filename: hide-lines.el
;; Description: Commands for hiding lines based on a regexp
;; Author: Mark Hulme-Jones <ture at plig cucumber dot net>
;; Maintainer: Joe Bloggs <vapniks@yahoo.com>
;; Copyleft (Ↄ) 2013, Joe Bloggs, all rites reversed.
;; Version: 20130622
;; Last-Updated: 2013-06-22 22:38:04
;;           By: Joe Bloggs
;; URL: https://github.com/vapniks/hide-lines
;; Keywords: convenience
;; Compatibility: GNU Emacs 24.3.1
;; Package-Requires:  
;;
;; Features that might be required by this library:
;;
;; 
;;

;;; This file is NOT part of GNU Emacs

;;; License
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.
;; If not, see <http://www.gnu.org/licenses/>.

;;; Commentary
;; 
;; The simplest way to make hide-lines work is to add the following
;; lines to your .emacs file:
;; 
;; (autoload 'hide-lines "hide-lines" "Hide lines based on a regexp" t)
;; (global-set-key (kbd "C-c /") 'hide-lines)
;; 
;; Now, when you type C-c /, you will be prompted for a regexp
;; (regular expression).  All lines matching this regexp will be
;; hidden in the buffer.
;; 
;; Alternatively, you can type C-u C-c / (ie. provide a prefix
;; argument to the hide-lines command) to hide all lines that *do not*
;; match the specified regexp. If you want to reveal previously hidden
;; lines you can use any other prefix, e.g. C-u C-u C-c /
;; 

;;; Commands:
;;
;; Below are complete command list:
;;
;;  `hide-lines'
;;    Call `hide-lines-matching'. With a prefix arg of 4 (C-u) call `hide-lines-not-matching'.
;;    With any other prefix call `hide-lines-show-all'.
;;  `hide-lines-not-matching'
;;    Hide lines that don't match the specified regexp.
;;  `hide-lines-matching'
;;    Hide lines matching the specified regexp.
;;  `hide-lines-show-all'
;;    Show all areas hidden by the filter-buffer command
;;

;;; Installation:
;;
;; Put hide-lines.el in a directory in your load-path, e.g. ~/.emacs.d/
;; You can add a directory to your load-path with the following line in ~/.emacs
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;; where ~/elisp is the directory you want to add 
;; (you don't need to do this for ~/.emacs.d - it's added by default).
;;
;; Add the following to your ~/.emacs startup file.
;;
;; (require 'hide-lines)

;;; Change log:
;;	
;; 2013/06/22 - Add namespace prefixes to functions and variables.
;;              Add licence and add to Marmalade repo.
;;              Alter hide-lines so that it can also show all lines
;; 
;; 24/03/2004 - Incorporate fix for infinite loop bug from David Hansen.
;; 

;;; Acknowledgements:
;;
;; David Hansen.
;;

;;; TODO
;;
;; 
;;

;;; Require


;;; Code:

(defvar hide-lines-invisible-areas ()
 "List of invisible overlays used by hidelines")

(add-to-invisibility-spec 'hl)

;;;###autoload
(defun hide-lines (&optional arg)
  "Hide lines matching the specified regexp.
With prefix arg of 4 (C-u) hide lines that do not match the specified regexp.
With any other prefix arg, reveal all hidden lines."
  (interactive "p")
  (cond ((= arg 4) (call-interactively 'hide-lines-not-matching))
        ((= arg 1) (call-interactively 'hide-lines-matching))
        (t (call-interactively 'hide-lines-show-all))))

(defun hide-lines-add-overlay (start end)
  "Add an overlay from `start' to `end' in the current buffer.  Push the
overlay onto the hide-lines-invisible-areas list"
  (let ((overlay (make-overlay start end)))
    (setq hide-lines-invisible-areas (cons overlay hide-lines-invisible-areas))
    (overlay-put overlay 'invisible 'hl)))

;;;###autoload
(defun hide-lines-not-matching (search-text)
  "Hide lines that don't match the specified regexp."
  (interactive "MHide lines not matched by regexp: ")
  (set (make-local-variable 'line-move-ignore-invisible) t)
  (save-excursion 
    (goto-char (point-min))
    (let ((start-position (point-min))
          (pos (re-search-forward search-text nil t)))
      (while pos
        (beginning-of-line)
        (hide-lines-add-overlay start-position (point))
        (forward-line 1)
        (setq start-position (point))
        (if (eq (point) (point-max))
            (setq pos nil)
          (setq pos (re-search-forward search-text nil t))))
      (hide-lines-add-overlay start-position (point-max)))))

;;;###autoload
(defun hide-lines-matching  (search-text)
  "Hide lines matching the specified regexp."
  (interactive "MHide lines matching regexp: ")
  (set (make-local-variable 'line-move-ignore-invisible) t)
  (save-excursion
    (goto-char (point-min))
    (let ((pos (re-search-forward search-text nil t))
          start-position)
      (while pos
        (beginning-of-line)
        (setq start-position (point))
        (end-of-line)
        (hide-lines-add-overlay start-position (+ 1 (point)))
        (forward-line 1)
        (if (eq (point) (point-max))
            (setq pos nil)
          (setq pos (re-search-forward search-text nil t)))))))

;;;###autoload
(defun hide-lines-show-all ()
  "Show all areas hidden by the filter-buffer command."
  (interactive)
  (mapc (lambda (overlay) (delete-overlay overlay)) 
        hide-lines-invisible-areas)
  (setq hide-lines-invisible-areas ()))

(provide 'hide-lines)

;; (magit-push)
;; (yaoddmuse-post "EmacsWiki" "hide-lines.el" (buffer-name) (buffer-string) "update")

;;; hide-lines.el ends here
