;;; lua-lambda.el --- Turn certain anonymous functions into lambdas

;; Copyright © 2019 Jacob Salzberg

;; Author: Jacob Salzberg <jssalzbe@ncsu.edu>
;; URL: https://github.com/jsalzbergedu/lua-lambda-emacs
;; Version: 0.1.0
;; Keywords: lua lambda

;; This file is not a part of GNU Emacs

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:
(defvar lua-lambda-symbol "λ"
  "The symbol that should be used for lambda.")

(defconst lua-lambda-regex "function([^)]*?)[[:space:]]*?return "
  "Regex to find the character")

(defun lua-lambda--overlay-one ()
  "Overlays a lambda.
Returns non-nil on success, nil on failure"
  (with-silent-modifications
    (when (re-search-forward lua-lambda-regex nil t nil)
      (let ((beg (match-beginning 0))
            (end (match-end 0)))
        (when (re-search-forward " end")
          (let ((o (make-overlay beg (+ beg (length "function")))))
            (overlay-put o 'lua-lambda t)
            (overlay-put o 'display lua-lambda-symbol))
          (let ((o (make-overlay end (- end (length "return ")))))
            (overlay-put o 'lua-lambda t)
            (overlay-put o 'display ""))
          (let ((o (make-overlay (point) (- (point) (length " end")))))
            (overlay-put o 'lua-lambda t)
            (overlay-put o 'display "")))))))

(defun lua-lambda--region (start end)
  "Overlay the entire buffer."
  (setq start (point-min)
        end (point-max))
  (remove-overlays (point-min) (point-max) 'lua-lambda t)
  (save-excursion
    (goto-char start)
    (while (and (< (point) end) (lua-lambda--overlay-one))
      t)))

;;;###autoload
(define-minor-mode lua-lambda-mode
  "A minor mode to overlay certain expressions with lambdas"
  nil
  nil
  nil
  (remove-overlays (point-min) (point-max) 'pseudocode t)
  (when lua-lambda-mode
    (jit-lock-register #'lua-lambda--region t)
    (lua-lambda--region (point-min) (point-max))))


;;; lua-lambda.el ends here
