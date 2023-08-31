;;; rust-playground.el --- Local Rust playground for short code snippets.

;; Copyright (C) 2016-2017  Alexander I.Grafov (axel)

;; Author: Alexander I.Grafov <grafov@gmail.com> + all the contributors (see git log)
;; URL: https://github.com/grafov/rust-playground
;; Version: 0.2.1
;; Keywords: tools, rust
;; Package-Requires: ((emacs "24.3"))

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

;; Local playground for the Rust programs similar to play.rust-lang.org.
;; `M-x rust-playground` and type you rust code then make&run it with `C-c C-c`.
;; Toggle between Cargo.toml and main.rs with `C-c b`
;; Delete the current playground and close all buffers with `C-c k`

;; Playground requires preconfigured environment for Rust language.

;; It is port of github.com/grafov/go-playground for Go language.

;;; Code:

(require 'compile)

(defgroup rust-playground nil
  "Options specific to Rust Playground.")

(defcustom rust-playground-basedir (locate-user-emacs-file "rust-playground")
  "Base directory for playground snippets."
  :type 'file
  :group 'rust-playground)

(defcustom rust-playground-cargo-toml-template
  (format "[package]
name = \"project\"
version = \"0.1.0\"
authors = [\"%s <%s>\"]
edition = \"2021\"

[dependencies]
" (or user-full-name "Rust Example") (or user-mail-address "rust@example.com"))
  "When creating a new playground, this will be used as the Cargo.toml file")

(defcustom rust-playground-main-rs-template
  "fn main() {\n    \n}"
  "When creating a new playground, this will be used as the body of the main.rs file")

(defcustom rust-playground-dir-format
  "%Y-%m-%d_%H-%M-%S"
  "Directory name pattern for the playground project")

(defun rust-playground-dir-name ()
  (file-name-as-directory
   (concat (file-name-as-directory rust-playground-basedir)
           (format-time-string rust-playground-dir-format))))

(defun rust-playground-snippet-main-file-name (basedir)
  "Get the snippet main.rs file from BASEDIR."
  (concat basedir (file-name-as-directory "src") "main.rs"))

(defun rust-playground-toml-file-name (basedir)
  "Get the cargo.toml filename from BASEDIR."
  (concat basedir "Cargo.toml"))

(defun rust-playground-new-template (filename template &optional open)
  (with-temp-buffer
    (insert template)
    (set-visited-file-name filename t)
    (save-buffer))
  (if open
      (find-file filename)))

(defun rust-playground-set-point ()
  (when (or (derived-mode-p 'rust-mode)
            (derived-mode-p 'rust-ts-mode))
    (goto-char (point-max))
    (re-search-backward "}")
    (backward-char 1)))

;;;###autoload
(defun rust-playground ()
  (interactive)
  (let* ((basedir (rust-playground-dir-name))
         (toml-filename (rust-playground-toml-file-name basedir))
         (main-filename (rust-playground-snippet-main-file-name basedir)))
    (make-directory (expand-file-name "src" basedir) 'parents)
    (rust-playground-new-template toml-filename rust-playground-cargo-toml-template)
    (rust-playground-new-template main-filename rust-playground-main-rs-template 'open)
    (rust-playground-set-point)))

(provide 'rust-playground)

;;; rust-playground.el ends here
