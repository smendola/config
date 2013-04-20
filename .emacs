(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(backup-directory-alist (quote (("." . "~/.emacs.d/backups"))))
 '(menu-bar-mode nil)
 '(modeline-3d-p nil)
 '(toolbar-visible-p nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(button ((t (:inherit link :background "white"))))
 '(fringe ((t (:background "green"))))
 '(lazy-highlight ((t (:background "turquoise3" :foreground "black"))))
 '(link ((t (:foreground "blue" :underline t :weight bold))))
 '(minibuffer-prompt ((t (:foreground "yellow"))))
 '(mode-line ((t (:background "white" :foreground "blue" :inverse-video t)))))

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

;; GNU-emacs specific
(when (fboundp 'set-face-inverse-video-p)
  (set-face-inverse-video-p 'mode-line nil)
  (set-face-background 'mode-line "blue")
  (set-face-foreground 'mode-line "white")

  (set-face-inverse-video-p 'menu nil)
  (set-face-background 'menu "blue")
  (set-face-foreground 'menu "yellow")
  (set-face-foreground 'minibuffer-prompt "yellow"))

(global-set-key "" 'undo)
(setq allow-remote-paths nil)
(line-number-mode 1)
(column-number-mode 1)
(load-library "font-lock")
(setq default-tab-width 4)
(setq nxml-child-indent 4)
(put 'narrow-to-region 'disabled nil)
(xterm-mouse-mode)
