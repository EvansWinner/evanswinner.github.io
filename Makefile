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

all : copy build/index.html build/status-log.html build/portfolio.html build/dc_spl.html build/vcard.vcf build/ResumeOfEvansWinner.docx images sets.html build/mobius.txt build/resume.html build/writing.html kNN.html

images : build/me.jpg build/ultradian.png build/bmi.png build/tally.png build/css-cartouche.png build/android-split.jpg build/sandbox.jpg build/kallychore.png build/mertens.png

build/mertens.png :
	$(CP) mertens.png build
build/me.jpg : 
	$(CP) -u me.jpg build
build/ultradian.png : 
	$(CP) -u ultradian.png build
build/css-cartouche.png : 
	$(CP) -u css-cartouche.png build
build/bmi.png :
	$(CP) -u bmi.png build
build/android-split.jpg :
	$(CP) -u android-split.jpg build
build/sandbox.jpg :
	$(CP) -u sandbox.jpg build
build/tally.png : 
	$(CP) -u tally.png build
build/kallychore.png : 
	$(CP) -u kallychore.png build

build/vcard.vcf :
	$(CP) vcard.vcf build/vcard.vcf

build/ResumeOfEvansWinner.docx :
	$(CP) -u ResumeOfEvansWinner.docx build

# Portfolio
portfolio.md :
portfolio.css :
	$(CP) -u portfolio.css build
build/portfolio.html : portfolio.md copy portfolio.css
	pandoc --from markdown+pipe_tables -t html5 -s --toc --include-in-header=portfolio.css -o build/portfolio.html portfolio.md

# Other writing
writing.md :
build/writing.html : writing.md copy portfolio.css
	pandoc --from markdown+pipe_tables -t html5 -s --toc --include-in-header=portfolio.css -o build/writing.html writing.md

# Resume
resume.md :
resume.css :
	$(CP) -u portfolio.css build
build/resume.html : portfolio.md copy portfolio.css
	pandoc --from markdown -t html5 -s --include-in-header=portfolio.css -o build/resume.html resume.md

# Index
index.md :
build/index.html : index.md portfolio.css
	pandoc -s -f markdown -t html5 --include-in-header=portfolio.css -o build/index.html index.md

# Status log for a week
status-log.Rmd :
	$(CP) -u status-log.Rmd build
status-log.csv :
	$(CP) -u status-log.csv build
build/status-log.html : status-log.csv status-log.Rmd
	${rscript} -e "rmarkdown::render('status-log.Rmd')"
	mv status-log.html build

# sets tutorial
sets.kc : 
sets.html : sets.kc
	kallychore -m sets.kc | \
          bash > sets.md     && \
          pandoc -s -f markdown+backtick_code_blocks \
            --highlight-style=tango -t html \
            --include-in-header=portfolio.css -o sets.html sets.md
	$(CP) sets.kc sets.html build

# k-Nearest Neighbor in bash
kNN.kc :
kNN.html :
	kallychore -m kNN.kc | \
	  bash > kNN.md && \
	  pandoc -s -f markdown+backtick_code_blocks \
	    --highlight-style=tango -t html \
	    --include-in-header=portfolio.css -o kNN.html kNN.md
	$(CP) kNN.kc kNN.html build

# mobius function
mobius.kc:
build/mobius.txt: mobius.kc
	kallychore mobius.kc | bash > mobius.txt
	$(CP) mobius.kc mobius.txt build

# SPL readings in a datacenter 
spl_dc.csv :
	$(CP) -u spl_dc.csv build
spl_at-workstation.csv :
	$(CP) -u spl_at-workstation.csv build
spl_tape-area.csv :
	$(CP) -u spl_tape-area.csv build
dc_spl.Rmd :
	$(CP) -u dc_spl.Rmd build
build/dc_spl.html: dc_spl.Rmd spl_tape-area.csv spl_at-workstation.csv spl_dc.csv
	$(rscript) -e "rmarkdown::render('dc_spl.Rmd')"
	mv dc_spl.html build

copy : 
	$(CP) -u $(staticfiles) $(build)
clean :
	rm -rf build/* A B C mobius.txt sets.md sets.html kNN.html

