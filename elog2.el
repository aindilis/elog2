(global-set-key "\C-cvlr" 'event-log-push-recently-interacted-with-files-onto-stack)

(defun event-log-push-recently-interacted-with-files-onto-stack ()
 ""
 (interactive)
 (see
  (uea-query-agent-raw nil "ELog"
   (freekbs2-util-data-dumper
    (list
     (cons "Command" "list-recent")
     (cons "Condensed" 1)
     (cons "_DoNotLog" 1))))))

(defvar elog2-agent-name "ELog2-Agent1")

(global-set-key "\C-c\C-k\C-vEL" 'elog2-quick-start)

;; (global-unset-key "\C-cel")

(global-set-key "\C-cele" 'elog2-edit-elog2-file)
(global-set-key "\C-celgl" 'elog2-action-get-line)
(global-set-key "\C-celws" 'elog2-set-windows)
(global-set-key "\C-cels" 'elog2-quick-start)
(global-set-key "\C-celr" 'elog2-restart)
(global-set-key "\C-celk" 'elog2-kill)
(global-set-key "\C-celc" 'elog2-clear-context)
(global-set-key "\C-celm" 'elog2-reload-all-modified-source-files)

(global-set-key "\C-celop" 'elog2-open-source-file)
(global-set-key "\C-celoP" 'elog2-open-source-file-reload)

(defvar elog2-default-context "Org::FRDCSA::ELog2")
(defvar elog2-source-files nil)

(defun elog2-issue-command (query)
 ""
 (interactive)
 (uea-query-agent-raw nil elog2-agent-name
  (freekbs2-util-data-dumper
   (list
    (cons "_DoNotLog" 1)
    (cons "Eval" query)))))

(defun elog2-action-get-line ()
 ""
 (interactive)
 (see (elog2-issue-command
  (list "_prolog_list"
   (list "_prolog_list" 'var-Result)
   (list "emacsCommand"
    (list "_prolog_list" "kmax-get-line")
    'var-Result)))))

(defun elog2-quick-start ()
 ""
 (interactive)
 
 (elog2)
 (elog2-fix-windows)
 (elog2-select-windows))

(defun elog2 (&optional load-command)
 ""
 (interactive)
 (if (elog2-running-p)
  (error "ERROR: ELog2 Already running.")
  (progn
   (run-in-shell "cd /var/lib/myfrdcsa/codebases/minor/elog2/scripts" "*ELog2-Formalog*")
   (sit-for 3.0)
   (ushell)
   (sit-for 1.0)
   (pop-to-buffer "*ELog2-Formalog*")
   (insert (or load-command "./elog2-start -u"))
   (comint-send-input)
   (sit-for 3.0)
   (run-in-shell "cd /var/lib/myfrdcsa/codebases/minor/elog2/scripts && ./elog2-start-repl" "*ELog2-Formalog-REPL*" nil 'shell-mode)
   (sit-for 1.0))))

(defun elog2-set-windows ()
 ""
 (interactive)
 (elog2-fix-windows)
 (elog2-select-windows))

(defun elog2-fix-windows ()
 ""
 (interactive)
 (delete-other-windows)
 (split-window-vertically)
 (split-window-horizontally)
 (other-window 2)
 (split-window-horizontally)
 (other-window -2))

(defun elog2-select-windows ()
 ""
 (interactive)
 (switch-to-buffer "*ELog2-Formalog*")
 (other-window 1)
 (switch-to-buffer "*ushell*")
 (other-window 1)
 (switch-to-buffer "*ELog2-Formalog-REPL*")
 (other-window 1)
 (ffap "/var/lib/myfrdcsa/codebases/minor/elog2/elog2.pl"))

(defun elog2-restart ()
 ""
 (interactive)
 (if (yes-or-no-p "Restart ELog2? ")
  (progn
   (elog2-kill)
   (elog2-quick-start))))

(defun elog2-kill ()
 ""
 (interactive)
 (flp-kill-processes)
 (shell-command "killall -9 \"elog2-start\"")
 (shell-command "killall -9 \"elog2-start-repl\"")
 (shell-command "killall-grep ELog2-Agent1")
 (kmax-kill-buffer-no-ask (get-buffer "*ELog2-Formalog*"))
 (kmax-kill-buffer-no-ask (get-buffer "*ELog2-Formalog-REPL*"))
 ;; (kmax-kill-buffer-no-ask (get-buffer "*ushell*"))
 (elog2-running-p))

(defun elog2-running-p ()
 (interactive)
 (setq elog2-running-tmp t)
 (let* ((matches nil)
	(processes (split-string (shell-command-to-string "ps auxwww") "\n"))
	(failed nil))
  (mapcar 
   (lambda (process)
    (if (not (kmax-util-non-empty-list-p (kmax-grep-v-list-regexp (kmax-grep-list-regexp processes process) "grep")))
     (progn
      (see process 0.0)
      (setq elog2-running-tmp nil)
      (push process failed))))
   elog2-process-patterns)
  (setq elog2-running elog2-running-tmp)
  (if (kmax-util-non-empty-list-p failed)
   (see failed 0.1))
  elog2-running))

(defun elog2-clear-context (&optional context-arg)
 (interactive)
 (let* ((context (or context-arg elog2-default-context)))
  (if (yes-or-no-p (concat "Clear Context <" context ">?: "))
   (freekbs2-clear-context context))))

(defvar elog2-process-patterns
 (list
  "elog2-start"
  "elog2-start-repl"
  "/var/lib/myfrdcsa/codebases/internal/unilang/unilang-client"
  "/var/lib/myfrdcsa/codebases/internal/freekbs2/kbs2-server"
  "/var/lib/myfrdcsa/codebases/internal/freekbs2/data/theorem-provers/vampire/Vampire1/Bin/server.pl"
  ))

(defun elog2-eval-function-and-map-to-integer (expression)
 ""
 (interactive)
 (elog2-serpro-map-object-to-integer
  (funcall (car expression) (cdr expression))))

(defun elog2-serpro-map-object-to-integer (object)
 ""
 (interactive)
 (see object)
 (see (formalog-query (list 'var-integer) (list "prolog2TermAlgebra" object 'var-integer) nil "ELog2-Agent1")))

(defun elog2-serpro-map-integer-to-object (integer)
 ""
 (interactive)
 (see integer)
 (see (formalog-query (list 'var-integer) (list "termAlgebra2prolog" object 'var-integer) nil "ELog2-Agent1")))

(defun elog2-edit-elog2-file ()
 ""
 (interactive)
 (ffap "/var/lib/myfrdcsa/codebases/minor/elog2/elog2.el"))

(defun elog2-reload-all-modified-source-files ()
 ""
 (interactive)
 (kmax-move-buffer-to-end-of-buffer (get-buffer "*ELog2-Formalog*"))
 (formalog-query
  nil
  (list "make")
  nil "ELog2-Agent1"))

;; emacsCommand(['kmax-get-line'],Result). 
;; (see (freekbs2-importexport-convert (list (list 'var-Result) (list "emacsCommand" (list "kmax-get-line") 'var-Result)) "Interlingua" "Perl String"))

;; "Eval" => {
;;           "_prolog_list" => {
;;                             "_prolog_list" => [
;;                                               \*{'::?Result'}
;;                                             ],
;;                             "emacsCommand" => [
;;                                               [
;;                                                 "_prolog_list",
;;                                                 "kmax-get-line"
;;                                               ],
;;                                               \*{'::?Result'}
;;                                             ]
;;                           }
;;         },

;; "Eval" => [
;;           [
;;             "_prolog_list",
;;             [
;;               "_prolog_list",
;;               \*{'::?Result'}
;;             ],
;;             [
;;               "emacsCommand",
;;               [
;;                 "_prolog_list",
;; 	        "kmax-get-line",
;;               ],
;;               \*{'::?Result'}
;;             ]
;;           ]
;;         ],


;; <message>
;;   <id>1</id>
;;   <sender>ELog2-Agent1</sender>
;;   <receiver>Emacs-Client</receiver>
;;   <date>Sat Apr  1 10:16:28 CDT 2017</date>
;;   <contents>eval (run-in-shell \"ls\")</contents>
;;   <data>$VAR1 = {
;;           '_DoNotLog' => 1,
;;           '_TransactionSequence' => 0,
;;           '_TransactionID' => '0.667300679865178'
;;         };
;;   </data>
;; </message>

;; (see (eval (read "(run-in-shell \"ls\")")))
;; (see (cons "Result" nil ))

;; (see (freekbs2-util-data-dumper
;;      (list
;;       (cons "_DoNotLog" 1)
;;       (cons "Result" nil)
;;       )
;;       ))

;; ;; (see '(("_DoNotLog" . 1) ("Result")))
;; ;; (see '(("Result"))

;; (freekbs2-util-convert-from-emacs-to-perl-data-structures '(("_DoNotLog" . 1) ("Result")))
;; (mapcar 'freekbs2-util-convert-from-emacs-to-perl-data-structures '(("_DoNotLog" . 1) ("Result")))

;; (mapcar 'freekbs2-util-convert-from-emacs-to-perl-data-structures '(("_DoNotLog" . 1) ("Result")))

;; (see '(("_DoNotLog" . 1) ("Result")))
;; (see '(("Result")))
;; (see '(("_DoNotLog" . 1)))

;; (join ", " (mapcar 'freekbs2-util-convert-from-emacs-to-perl-data-structures '("Result")))


;; (elog2-eval-function-and-map-to-integer (list 'buffer-name))




;;;;;;;;;;;;;;;; FIX Academician to use ELog2
;; see /var/lib/myfrdcsa/codebases/minor/academician/academician-elog2.el

(defun elog2-retrieve-file-id (file)
 (let* ((chased-original-file (kmax-chase file))
	(results
	 (formalog-query
	  (list 'var-FileIDs)
	  (list "retrieveFileIDs" chased-original-file 'var-FileIDs)
	  nil "ELog2-Agent1")))
  (see (car (cdadar results)))))

;; (defun academician-get-title-of-publication (&optional overwrite)
;;  ""
;;  (interactive "P")
;;  (let* ((current-cache-dir (doc-view--current-cache-dir))
;; 	(current-document-hash (gethash current-cache-dir academician-parscit-hash))
;; 	(title0 (gethash current-cache-dir academician-title-override-hash)))
;;   (if (non-nil title0)
;;    title0
;;    (progn
;;     (academician-process-with-parscit overwrite)
;;     (let* ((title1
;; 	    (progn
;; 	     ;; (see current-document-hash)
;; 	     (cdr (assoc "content" 
;; 		   (cdr (assoc "title" 
;; 			 (cdr (assoc "variant" 
;; 			       (cdr (assoc "ParsHed" 
;; 				     (cdr (assoc "algorithm" current-document-hash))))))))))))
;; 	   (title2
;; 	    (cdr (assoc "content" 
;; 		  (cdr (assoc "title" 
;; 			(cdr (assoc "variant" 
;; 			      (cdr (assoc "SectLabel" 
;; 				    (cdr (assoc "algorithm" current-document-hash)))))))))))
;; 	   (title 
;; 	    (chomp (or title1 title2))))
;;      (if (not (equal title "nil"))
;;       title
;;       (academician-override-title)))))))

;; (defun academician-process-with-parscit (&optional overwrite)
;;  "Take the document in the current buffer, process the text of it
;;  and return the citations, allowing the user to add the citations
;;  to the list of papers to at-least-skim"
;;  (interactive "P")
;;  (if (derived-mode-p 'doc-view-mode)
;;   (if doc-view--current-converter-processes
;;    (message "Academician: DocView: please wait till conversion finished.")
;;    (let ((academician-current-buffer (current-buffer)))
;;     (academician-doc-view-open-text-without-switch-to-buffer)
;;     (while (not academician-converted-to-text)
;;      (sit-for 0.1))
;;     (let* ((filename (buffer-file-name))
;; 	   (current-cache-dir (doc-view--current-cache-dir))
;; 	   (txt (expand-file-name "doc.txt" current-cache-dir)))
;;      (if (equal "fail" (gethash current-cache-dir academician-parscit-hash "fail"))
;;       (progn
;;        ;; check to see if there is a cached version of the parscit data
;;        (if (file-readable-p txt)
;; 	(let* ((command
;; 		(concat 
;; 		 "/var/lib/myfrdcsa/codebases/minor/academician/scripts/process-parscit-results.pl -f "
;; 		 (shell-quote-argument filename)
;; 		 (if overwrite " -o " "")
;; 		 " -t "
;; 		 (shell-quote-argument txt)
;; 		 " | grep -vE \"^(File is |Processing with ParsCit: )\""
;; 		 ))
;; 	       (debug-1 (if academician-debug (see (list "command: " command))))
;; 	       (result (progn
;; 			(message (concat "Processing with ParsCit: " txt " ..."))
;; 			(shell-command-to-string command)
;; 			)))
;; 	 (if academician-debug (see (list "result: " result)))
;; 	 (ignore-errors
;; 	  (puthash current-cache-dir (eval (read result)) academician-parscit-hash))
;; 	 )
;; 	(message (concat "File not readable: " txt)))
;;        ;; (freekbs2-assert-formula (list "has-title") academician-default-context)
;;        )))))))


;; (global-set-key "\C-ctt" )

;; (defun elog2-roll ()
;;  ""
;;  (interactive)
;;  )


(add-to-list 'load-path "/var/lib/myfrdcsa/codebases/minor/elog2/frdcsa/emacs")

(defun elog2-open-source-file-reload ()
 (interactive)
 (setq elog2-source-files nil)
 (elog2-open-source-file)
 (elog2-get-actual-source-files))

(defun elog2-open-source-file ()
 (interactive)
 (elog2-load-source-files)
 (let ((file (ido-completing-read "Source File: " (elog2-get-actual-source-files))))
  (ffap file)
  (end-of-buffer)
  (elog2-complete-from-predicates-in-current-buffer)))

(defun elog2-get-actual-source-files ()
 ""
 (mapcar 'shell-quote-argument
  (kmax-grep-list elog2-source-files
   (lambda (value)
    (and (stringp value) (file-exists-p value))))))

(defun elog2-complete-from-predicates-in-current-buffer ()
 ""
 (interactive)
 (if elog2-complete-from-predicates
  (let ((predicates (elog2-util-get-approximately-all-predicates-in-current-file buffer-file-name)))
   (insert (concat (ido-completing-read "Predicate: " predicates) "()."))
   (backward-char 2))))

(defun elog2-load-source-files ()
 ""
 (if (not (non-nil elog2-source-files))
  (progn
   (setq elog2-source-files
    (cdr
     (nth 1
      (nth 0
       (formalog-query (list 'var-X) (list "listFiles" 'var-X) nil "ELog2-Agent1")))))
   (setq elog2-source-files-chase-alist (kmax-file-list-chase-alist elog2-source-files)))))

