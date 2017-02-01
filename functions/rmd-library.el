;; Function rmd-pandoc-custom to use knitr::pandoc with options in
;; .pandoc/config.pandoc
;; Inspiration borrowed from ess-swv-run-in-R (ess-swv.el)
(defun rmd-pandoc-custom ()
  "Run Pandoc on the associated .md file."
  (interactive)
  (let* ((rmd-buf (current-buffer)))
    (update-ess-process-name-list)
    (cond ((= 0 (length ess-process-name-list))
           (message "No ESS processes running; starting R")
           (sit-for 1); so the user notices before the next msgs/prompt
           (R)
           (set-buffer rmd-buf)
           )
          ((not (string= "R" (ess-make-buffer-current))); e.g. Splus, need R
           (ess-force-buffer-current "R process to load into: "))
          )
    (setq-local ess-dialect "R")
    (ess-force-buffer-current)

    (save-excursion
      (let* ((sprocess (ess-get-process ess-current-process-name))
             (sbuffer (process-buffer sprocess))
             (md-filename (file-name-sans-extension (buffer-file-name)))
             (pandoc-cmd
	      (format "require(knitr); pandoc(\"%s.md\", format =
	      \"html\", config =
	      \"/home/mathieu/.pandoc/config.pandoc\", encoding =
	      \"UTF-8\")" md-filename)))
	(message "Running pandoc on %s.md" md-filename)
        (ess-execute pandoc-cmd 'buffer nil nil)
        (switch-to-buffer rmd-buf)
        (ess-show-buffer (buffer-name sbuffer) nil)))))

;; Function rmd-bookdown to use bookdown::render on index.Rmd
;; Inspiration borrowed from ess-swv-run-in-R (ess-swv.el)
(defun rmd-bookdown ()
  "Run Bookdown on index.Rmd."
  (interactive)
  (let* ((rmd-buf (current-buffer)))
    (update-ess-process-name-list)
    (cond ((= 0 (length ess-process-name-list))
           (message "No ESS processes running; starting R")
           (sit-for 1); so the user notices before the next msgs/prompt
           (R)
           (set-buffer rmd-buf)
           )
          ((not (string= "R" (ess-make-buffer-current))); e.g. Splus, need R
           (ess-force-buffer-current "R process to load into: "))
          )
    (setq-local ess-dialect "R")
    (ess-force-buffer-current)
      
    (save-excursion
      (save-some-buffers)
      (let* ((output-format-table (make-hash-table :test 'equal)))
          (puthash "HTML" "bookdown::gitbook" output-format-table)
          (puthash "PDF" "bookdown::pdf_book" output-format-table)
          (puthash "All" "all" output-format-table)
          (let* ((sprocess (ess-get-process ess-current-process-name))
                 (sbuffer (process-buffer sprocess))
                 (output-format-user (completing-read "Output format: " '("HTML" "PDF" "All")))
                 (output-format (gethash output-format-user output-format-table))
                 (bkdwn-cmd (concat "bookdown::render_book(\"index.Rmd\", output_format =\"" output-format "\")")))
            (message "Running Bookdown on index.Rmd")
            (ess-execute bkdwn-cmd 'buffer nil nil)
            (switch-to-buffer rmd-buf)
            (ess-show-buffer (buffer-name sbuffer) nil))))))

;; Functions rmd-fenced-r-code-block and rmd-inline-r-code to insert R
;; code in a Rmd file.
(defun rmd-fenced-r-code-block ()
  "Adds a fenced block for R code in Markdown"
  (interactive)
  (insert "\n```{r}\n\n```\n")
  (previous-line)
  (previous-line))
(defun rmd-inline-r-code ()
  "Insert inline R code in Markdown"
  (interactive)
  (insert "`r `")
  (backward-char))