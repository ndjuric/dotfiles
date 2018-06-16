(setq kill-ring-max 200
      kill-do-not-save-duplicates t
      save-interprogram-paste-before-kill t)

(defun my/clear-kill-ring ()
  (interactive)
  (progn (setq kill-ring nil) (garbage-collect)))

(bind-key "C-c r c" 'my/clear-kill-ring)

(setq select-enable-primary t)
(setq select-enable-clipboard t)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

(setq-default fill-column 80) ;; default is 70

;; By default, Emacs thinks a sentence is a full-stop followed by 2 spaces.
(setq-default sentence-end-double-space nil)

;; expand-region: expand region semantically
(use-package expand-region
  :bind ("C-=" . er/expand-region)
  :config
  (setq expand-region-contract-fast-key "|")
  (setq expand-region-reset-fast-key "<ESC><ESC>"))

;; subword: subword movement and editing for camelCase
(use-package subword
  :ensure nil
  :defer 1
  :config (global-subword-mode))

;; save-place: save cursor position when buffer is killed
(use-package saveplace
  :ensure nil
  :defer 2
  :config (save-place-mode))

(defun xah-clean-empty-lines (&optional *begin *end *n)
  "Replace repeated blank lines to just 1.
   Works on whole buffer or text selection, respects `narrow-to-region'.
   *N is the number of newline chars to use in replacement.
   If 0, it means lines will be joined.
   By befault, *N is 2. It means, 1 visible blank line.

   URL `http://ergoemacs.org/emacs/elisp_compact_empty_lines.html'
   Version 2017-01-27
  "
  (interactive
   (if (region-active-p)
       (list (region-beginning) (region-end))
     (list (point-min) (point-max))))
  (when (not *begin)
    (setq *begin (point-min) *end (point-max)))
  (save-excursion
    (save-restriction
      (narrow-to-region *begin *end)
      (progn
        (goto-char (point-min))
        (while (re-search-forward "\n\n\n+" nil "NOERROR")
          (replace-match (make-string (if *n *n 2) 10)))))))

(defun xah-clean-whitespace (&optional *begin *end)
  "Delete trailing whitespace, and replace repeated blank lines to just 1.
   Only space and tab is considered whitespace here.
   Works on whole buffer or text selection, respects `narrow-to-region'.
   URL `http://ergoemacs.org/emacs/elisp_compact_empty_lines.html'
   Version 2016-10-15"
  (interactive
   (if (region-active-p)
       (list (region-beginning) (region-end))
     (list (point-min) (point-max))))
  (when (null *begin)
    (setq *begin (point-min)  *end (point-max)))
  (save-excursion
    (save-restriction
      (narrow-to-region *begin *end)
      (progn
        (goto-char (point-min))
        (while (search-forward-regexp "[ \t]+\n" nil "noerror")
          (replace-match "\n")))
      (xah-clean-empty-lines (point-min) (point-max))
      (progn
        (goto-char (point-max))
        (while (equal (char-before) 32) ; char 32 is space
          (delete-char -1))))))

(defvar yank-indent-modes '(js2-mode
                            emacs-lisp-mode
                            rust-mode
                            web-mode
                            css-mode
                            c++-mode
                            c-mode
                            racket-mode
                            typescript-mode
                            go-mode
                            sh-mode
                            shell-mode)
  "Modes in which to indent regions that are yanked (or yank-popped)")

(defvar yank-advised-indent-threshold 5000
  "Threshold (# chars) over which indentation does not automatically occur.")

(defun yank-advised-indent-function (beg end)
  "Do indentation, as long as the region isn't too large."
  (if (<= (- end beg) yank-advised-indent-threshold)
      (indent-region beg end nil)))

(defadvice yank (after yank-indent activate)
  "If current mode is one of 'yank-indent-modes, indent yanked text
   (with prefix arg don't indent)."
  (if (and (not (ad-get-arg 0))
           (--any? (derived-mode-p it) yank-indent-modes))
      (let ((transient-mark-mode nil))
        (yank-advised-indent-function (region-beginning) (region-end)))))

(defadvice yank-pop (after yank-pop-indent activate)
  "If current mode is one of 'yank-indent-modes, indent yanked text
   (with prefix arg don't indent)."
  (if (and (not (ad-get-arg 0))
           (member major-mode yank-indent-modes))
      (let ((transient-mark-mode nil))
        (yank-advised-indent-function (region-beginning) (region-end)))))

;; Update The Timestamp Before saving a file
(add-hook 'before-save-hook #'time-stamp)

(bind-keys
 ("C-c o s" . cycle-spacing)
 ("C-h" . delete-backward-char)
 ("C-M-h" . backward-kill-word)
 ("M-;" . comment-line)
 ("C-c o o" . xah-clean-whitespace))

;; configuration for auto-fill-mode
(use-package simple :ensure nil
  :chords (("m," . beginning-of-buffer)
           (",." . end-of-buffer))
  :hook ((prog-mode text-mode org-mode) . auto-fill-mode)
  :config
  (setq comment-auto-fill-only-comments t))

(defun indent-buffer ()
  "Indent the currently visited buffer."
  (interactive)
  (indent-region (point-min) (point-max)))

(defcustom prelude-indent-sensitive-modes
  '(coffee-mode python-mode slim-mode haskell-mode haml-mode yaml-mode)
  "Modes for which auto-indenting is suppressed."
  :type 'list)

(defun indent-region-or-buffer ()
  "Indent a region if selected, otherwise the whole buffer."
  (interactive)
  (unless (member major-mode prelude-indent-sensitive-modes)
    (save-excursion
      (if (region-active-p)
          (progn
            (indent-region (region-beginning) (region-end))
            (message "Indented selected region."))
        (progn
          (indent-buffer)
          (message "Indented buffer.")))
      (whitespace-cleanup))))

(defun indent-defun (&optional l r)
  "Indent current defun.
   Throw an error if parentheses are unbalanced.
   If L and R are provided, use them for finding the start and end of defun."
  (interactive)
  (let ((p (point-marker)))
    (set-marker-insertion-type p t)
    (indent-region
     (save-excursion
       (when l (goto-char l))
       (beginning-of-defun 1) (point))
     (save-excursion
       (when r (goto-char r))
       (end-of-defun 1) (point)))
    (goto-char p)))

(bind-keys
 ("C-M-\\" . indent-region-or-buffer)
 ("C-c d i" . indent-defun))

(defun unfill-paragraph ()
  "Replace newline chars in current paragraph by single spaces.
   This command does the inverse of `fill-paragraph'."
  (interactive)
  (let ((fill-column most-positive-fixnum))
    (call-interactively 'fill-paragraph)))
(bind-key "M-Q" 'unfill-paragraph)

(defun unfill-region (start end)
  "Replace newline chars in region from START to END by single spaces.
   This command does the inverse of `fill-region'."
  (interactive "r")
  (let ((fill-column most-positive-fixnum))
    (fill-region start end)))

(defun xah-title-case-region-or-line (*begin *end)
  "Title case text between nearest brackets, or current line, or text selection.
   Capitalize first letter of each word, except words like {to, of, the, a, in, 
   or, and, …}. If a word already contains cap letters such as HTTP, URL, they
   are left as is.

   When called in a elisp program, *begin *end are region boundaries.
   URL `http://ergoemacs.org/emacs/elisp_title_case_text.html'
   Version 2017-01-11"
  (interactive
   (if (use-region-p)
       (list (region-beginning) (region-end))
     (let (-p1
           -p2
           (-skipChars "^\"<>(){}[]“”‘’‹›«»「」『』【】〖〗《》〈〉〔〕"))
       (progn
         (skip-chars-backward -skipChars (line-beginning-position))
         (setq -p1 (point))
         (skip-chars-forward -skipChars (line-end-position))
         (setq -p2 (point)))
       (list -p1 -p2))))
  (let* ((-strPairs [
                     [" A " " a "]
                     [" And " " and "]
                     [" At " " at "]
                     [" As " " as "]
                     [" By " " by "]
                     [" Be " " be "]
                     [" Into " " into "]
                     [" In " " in "]
                     [" Is " " is "]
                     [" It " " it "]
                     [" For " " for "]
                     [" Of " " of "]
                     [" Or " " or "]
                     [" On " " on "]
                     [" Via " " via "]
                     [" The " " the "]
                     [" That " " that "]
                     [" To " " to "]
                     [" Vs " " vs "]
                     [" With " " with "]
                     [" From " " from "]
                     ["'S " "'s "]
                     ["'T " "'t "]
                     ]))
    (save-excursion
      (save-restriction
        (narrow-to-region *begin *end)
        (upcase-initials-region (point-min) (point-max))
        (let ((case-fold-search nil))
          (mapc
           (lambda (-x)
             (goto-char (point-min))
             (while
                 (search-forward (aref -x 0) nil t)
               (replace-match (aref -x 1) "FIXEDCASE" "LITERAL")))
           -strPairs))))))

;; move-text: move text or region up or down
(use-package move-text
  :config (move-text-default-bindings))

;; undo-tree: Treat undo history as a tree
(use-package undo-tree
  :bind (("s-/" . undo-tree-redo))
  :init (global-undo-tree-mode))

;; utf-8 everywhere
(set-language-environment 'utf-8)
(setq locale-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(unless (eq system-type 'windows-nt)
  (set-selection-coding-system 'utf-8))
(prefer-coding-system 'utf-8)

;; smart-dash: underscores without having to press shift modifier for dash key
(use-package smart-dash
  :config (require 'smart-dash))

;; cycle-quotes: cycle between single and double quotes
(use-package cycle-quotes
  :bind ("C-c o q" . cycle-quotes))

;;; Eval and replace last sexp
(defun eval-and-replace-last-sexp ()
  "Replace an emacs lisp expression (s-expression aka sexp) with its result.
   How to use: Put the cursor at the end of an expression like (+ 1 2) and call
   this command."
  (interactive)
  (let ((value (eval (preceding-sexp))))
    (kill-sexp -1)
    (insert (format "%s" value))))
(bind-key "C-x C-S-e" #'eval-and-replace-last-sexp)

(defadvice basic-save-buffer-2 (around fix-unwritable-save-with-sudo activate)
  "When we save a buffer which is write-protected, try to sudo-save it.

   When the buffer is write-protected it is usually opened in
   read-only mode.  Use \\[read-only-mode] to toggle
   `read-only-mode', make your changes and \\[save-buffer] to save.
   Emacs will warn you that the buffer is write-protected and asks
   you to confirm if you really want to save.  If you answer yes,
   Emacs will use sudo tramp method to save the file and then
   reverts it, making it read-only again.  The buffer stays
   associated with the original non-sudo filename."
           (condition-case err
               (progn
                 ad-do-it)
             (file-error
              (when (string-prefix-p
                     "Doing chmod: operation not permitted"
                     (error-message-string err))
                (let ((old-buffer-file-name buffer-file-name)
                      (success nil))
                  (unwind-protect
                      (progn
                        (setq buffer-file-name (concat "/sudo::" buffer-file-name))
                        (save-buffer)
                        (setq success t))
                    (setq buffer-file-name old-buffer-file-name)
                    (when success
                      (revert-buffer t t))))))))

(defun kill-back-to-indentation ()
  "Kill from point back to the first non-whitespace character on the line."
  (interactive)
  (let ((prev-pos (point)))
    (back-to-indentation)
    (kill-region (point) prev-pos)))
(bind-key "C-S-K" #'kill-back-to-indentation)

(provide 'init-editing)