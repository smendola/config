;;;; XEmacs backwards compatibility file
(set 'backup-directory-alist '(("." . "/c/Users/smendola/home/emacs-backups")))
(setq user-init-file
      (expand-file-name "init.el"
			(expand-file-name ".xemacs" "~")))
(setq custom-file
      (expand-file-name "custom.el"
			(expand-file-name ".xemacs" "~")))

(load-file user-init-file)
(load-file custom-file)

