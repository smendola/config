(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(backup-directory-alist (quote (("." . "~/.emacs.d/backups"))))
 '(column-number-mode t)
 '(custom-enabled-themes (quote (zenburn)))
 '(custom-safe-themes
   (quote
	("ba86d681a1619773dbdfdeb70424a1bc0091b53c86bd2239ad0a9bf9f10beb78" default)))
 '(font-use-system-font t)
 '(modeline-3d-p nil)
 '(show-paren-mode t)
 '(tool-bar-mode nil)
 '(tool-bar-position (quote left))
 '(toolbar-visible-p nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Consolas" :foundry "microsoft" :slant normal :weight normal :height 100 :width normal)))))

;;; uncomment this line to disable loading of "default.el" at startup
;; (setq inhibit-default-init t)

;; turn on font-lock mode
(when (fboundp 'global-font-lock-mode)
  (global-font-lock-mode t))

;; TODO: make this conditional; only for tty mode
(menu-bar-mode nil)

;; enable visual feedback on selections
(setq transient-mark-mode t)

;; default to better frame titles
(setq frame-title-format
      (concat  "%b - emacs@" (system-name)))

;; default to unified diffs
(setq diff-switches "-u")

;; always end a file with a newline
(setq require-final-newline 'nil)


(global-set-key "" 'undo)
(setq allow-remote-paths nil)
(line-number-mode 1)
(column-number-mode 1)
(load-library "font-lock")
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
;(load-library "~/.emacs.d/themes/zenburn.el")
(setq default-tab-width 4)
(setq nxml-child-indent 4)
(put 'narrow-to-region 'disabled nil)
(xterm-mouse-mode)
(load-theme 'zenburn)

(require 'package)
(add-to-list 'package-archives
             '("melpa-stable" . "http://stable.melpa.org/packages/") t)
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
;;(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(package-initialize)

