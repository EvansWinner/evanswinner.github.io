host := $(shell hostname)
build := build
staticfiles := status-log.Rmd status-log.csv portfolio.css intro_data_prob_project.html
OS := $(shell uname -s | tr A-Z a-z)

rscript := "Rscript"

ifeq ($(OS),netbsd)
  CP := "gcp"
endif
ifeq ($(OS),linux)
  CP := "cp"
endif
ifeq ($(OS),darwin)
  CP := "/opt/local/libexec/gnubin/cp""
endif

all : portfolio writing index resume status-log sets kNN dc_spl

portfolio : portfolio.html
portfolio.html : portfolio.md portfolio.css
	pandoc --from markdown+pipe_tables -t html5 -s --toc --include-in-header=portfolio.css -o portfolio.html portfolio.md

writing : writing.html
writing.html : writing.md portfolio.css
	pandoc --from markdown+pipe_tables -t html5 -s --toc --include-in-header=portfolio.css -o writing.html writing.md

resume : resume.html
resume.html : portfolio.md portfolio.css
	pandoc --from markdown -t html5 -s --include-in-header=portfolio.css -o resume.html resume.md

index : index.html
index.html : index.md portfolio.css
	pandoc -s -f markdown -t html5 --include-in-header=portfolio.css -o index.html index.md

status-log : status-log.html
status-log.html : status-log.csv status-log.Rmd
	${rscript} -e "rmarkdown::render('status-log.Rmd')"

sets : sets.html
sets.html : sets.kc
	kallychore -m sets.kc | \
          bash > sets.md     && \
          pandoc -s -f markdown+backtick_code_blocks \
            --highlight-style=tango -t html \
            --include-in-header=portfolio.css -o sets.html sets.md

kNN : kNN.html
kNN.html : kNN.kc
	kallychore -m kNN.kc | \
	  bash > kNN.md && \
	  pandoc -s -f markdown+backtick_code_blocks \
	    --highlight-style=tango -t html \
	    --include-in-header=portfolio.css -o kNN.html kNN.md

mobius : mobius.txt
mobius.txt: mobius.kc
	kallychore mobius.kc | bash > mobius.txt

dc_spl : dc_spl.html
dc_spl.html: dc_spl.Rmd spl_tape-area.csv spl_at-workstation.csv spl_dc.csv
	$(rscript) -e "rmarkdown::render('dc_spl.Rmd')"

clean :
	rm -rf A B C E mobius.txt kNN.md sets.md *.html 

