;;; epub-mode.el --- Minor mode for Identica

;; Copyright (C) 2011 Jayson Williams

;; Author: Jayson Williams <williams.jayson@gmail.com>
;; Last update: 2013-05-17
;; Version: 0.2 (early development)
;; Keywords: epub
;; URL: https://sourceforge.net/projects/epubmode/
;; Contributors:
;; Nitin Anand <nitinjavakid@gmail.com>

;; epub-mode is a minor mode for viewing epub documents in Emacs

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth floor,
;; Boston, MA 02110-1301, USA.

;; Ener the path to the epub document, and epub mode will open a text
;; version of the document in Emacs

(provide 'epubmode)
(defun get_epub (epub_file)
  "Read epub files in emacs"
  (interactive "fname of epub: ")
  (message "%s" epub_file)
  (setq working_folder (concat epub_file "-working"))
  (setq mk_working_dir_cmd (concat "mkdir " (shell-quote-argument working_folder)))

  (if (file-directory-p working_folder)
      (message "working folder present")
    (progn
     (shell-command mk_working_dir_cmd)
     (setq unzip_epub_cmd (concat "unzip " (shell-quote-argument epub_file) " -d " (shell-quote-argument working_folder)))
     (shell-command unzip_epub_cmd)))

  (setq directories (directory-files working_folder nil "[^.]"))
  (setq directories (delete "META-INF" directories))
  (setq count (length directories))
  (setq index 0)
  ;;; create html_files & book_txt after storing existing directories
  (shell-command (concat "mkdir " (shell-quote-argument (concat working_folder "/htm_files"))))
  (shell-command (concat "mkdir " (shell-quote-argument (concat working_folder "/book_text"))))

  (while (/= index count)
    ;;;need to find the folders with html docs in it
    (setq folder (elt directories index))
    (setq index (1+ index)) ;;;for next iteration
    (setq inner_folder_path (concat working_folder "/" folder))

    (if (file-directory-p inner_folder_path)
        (progn
          (message inner_folder_path)
          (sleep-for 2)
          (shell-command (concat "cp " (shell-quote-argument inner_folder_path) "/*.htm* " (shell-quote-argument working_folder) "/htm_files")))
      (message "not a folder")))
  (shell-command (concat "touch " (shell-quote-argument working_folder) "/book.txt"))
 
  ;;;Get listing of htm-files , convert to txt, place in book.txt
  (setq index 0)
  (setq htm_files (directory-files (concat working_folder "/htm_files") nil "[^.]"))
  (setq htm_files_count (length htm_files))
  ;;;(message "%d files in htm_folder" htm_files_count)

  (while (/= index htm_files_count)
    (setq htm_file (elt htm_files index))
    (message "on htm_files %d: %s" index htm_file)
    (setq index (1+ index))
    (setq source (concat working_folder "/htm_files/" htm_file))
    (setq convert_to_txt (concat "html2text -style pretty -width 2000 -ascii -nobs " (shell-quote-argument source) ">>" (shell-quote-argument (concat working_folder "/book.txt"))))
    (shell-command convert_to_txt))
  (setq book-buffer (find-file-read-only (concat working_folder "/book.txt")))
)

(add-hook 'find-file-hook
   (lambda()
      (when (and (stringp buffer-file-name)
              (string-match "\\.epub\\'" buffer-file-name))
         (get_epub buffer-file-name)) ) )
