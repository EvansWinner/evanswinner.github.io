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
  CP := "/opt/local/libexec/gnubin/cp"
endif


all:
	# Don't do it. Use one of these instead:
	#     'web' for the static pages
	#     'analytics' for oddball stuff
	#     'writing' for local writing stuff that's not in the blog

web : header footer portfolio writing index resume colophon etceteras about skills

analytics : status-log sets kNN dc_spl mobius todostack

writing : oneSpaceOrTwo toypiano feltsman steal garfield twoconductors ouray hpo snorkel

header : header.html
header.html : header.md
	pandoc -fmarkdown -thtml5 -o header.html header.md

footer : footer.html
footer.html : footer.md
	pandoc -fmarkdown -thtml5 -o footer.html footer.md

portfolio : portfolio.html
portfolio.html : portfolio.md portfolio.css header.html footer.html
	pandoc -fmarkdown+pipe_tables -thtml5 -Bheader.html -Afooter.html --include-in-header=portfolio.css -o portfolio.html portfolio.md

etceteras : etceteras.html
etceteras.html : etceteras.md portfolio.css header.html footer.html
	pandoc -fmarkdown+pipe_tables -thtml5 -Bheader.html -Afooter.html --include-in-header=portfolio.css -o etceteras.html etceteras.md

colophon : colophon.html
colophon.html : colophon.md portfolio.css header.html footer.html
	pandoc -fmarkdown+pipe_tables -thtml5 -Bheader.html -Afooter.html --include-in-header=portfolio.css -o colophon.html colophon.md

writing : writing.html
writing.html : writing.md portfolio.css header.html footer.html
	pandoc -fmarkdown+pipe_tables -thtml5 -Bheader.html -Afooter.html --toc --include-in-header=portfolio.css -o writing.html writing.md

skills : skills.html
skills.html : skills.md portfolio.css header.html footer.html
	pandoc -fmarkdown+pipe_tables -thtml5 -Bheader.html -Afooter.html --include-in-header=portfolio.css -o skills.html skills.md

resume : resume.html
resume.html : resume.md portfolio.css header.html footer.html
	pandoc -fmarkdown+pipe_tables -thtml5 -Bheader.html -Afooter.html --include-in-header=portfolio.css -o resume.html resume.md

about : about.html
about.html : about.md portfolio.css header.html footer.html
	pandoc -fmarkdown+pipe_tables -thtml5 -Bheader.html -Afooter.html --include-in-header=portfolio.css -o about.html about.md

index : index.html
index.html : index.md portfolio.css header.html footer.html
	pandoc -fmarkdown+pipe_tables -thtml5 -Bheader.html -Afooter.html --include-in-header=portfolio.css --variable document-css=false -o index.html index.md

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

oneSpaceOrTwo : oneSpaceOrTwo.html oneSpaceOrTwo.txt
oneSpaceOrTwo.txt : oneSpaceOrTwo.md
	./md2txt oneSpaceOrTwo.md > oneSpaceOrTwo.txt
oneSpaceOrTwo.html : oneSpaceOrTwo.md
	pandoc -fmarkdown -thtml5 --include-in-header=portfolio.css -o oneSpaceOrTwo.html oneSpaceOrTwo.md

todostack : todostack.html todostack.txt
todostack.txt : todostack.md
	./md2txt todostack.md > todostack.txt
todostack.html : todostack.md
	pandoc -fmarkdown -thtml5 --include-in-header=portfolio.css -o todostack.html todostack.md

toypiano : toypiano.html toypiano.txt
toypiano.txt : toypiano.md
	./md2txt toypiano.md > toypiano.txt
toypiano.html : toypiano.md
	pandoc -fmarkdown -thtml5 --include-in-header=portfolio.css -o toypiano.html toypiano.md

feltsman : feltsman.html feltsman.txt
feltsman.txt : feltsman.md
	./md2txt feltsman.md > feltsman.txt
feltsman.html : feltsman.md
	pandoc -fmarkdown -thtml5 --include-in-header=portfolio.css -o feltsman.html feltsman.md

steal : steal.html steal.txt
steal.txt : steal.md
	./md2txt steal.md > steal.txt
steal.html : steal.md
	pandoc -fmarkdown -thtml5 --include-in-header=portfolio.css -o steal.html steal.md

garfield : garfield.html garfield.txt
garfield.txt : garfield.md
	./md2txt garfield.md > garfield.txt
garfield.html : garfield.md
	pandoc -fmarkdown -thtml5 --include-in-header=portfolio.css -o garfield.html garfield.md

twoconductors : twoconductors.html twoconductors.txt
twoconductors.txt : twoconductors.md
	./md2txt twoconductors.md > twoconductors.txt
twoconductors.html : twoconductors.md
	pandoc -fmarkdown -thtml5 --include-in-header=portfolio.css -o twoconductors.html twoconductors.md

ouray : ouray.html ouray.txt
ouray.txt : ouray.md
	pandoc -fmarkdown -tplain -o ouray.txt ouray.md
ouray.html : ouray.md
	pandoc -fmarkdown -thtml5 --include-in-header=portfolio.css -o ouray.html ouray.md

hpo : hpo.html hpo.txt
hpo.txt : hpo.md
	./md2txt hpo.md > hpo.txt
hpo.html : hpo.md
	pandoc -fmarkdown -thtml5 --include-in-header=portfolio.css -o hpo.html hpo.md

snorkel : snorkel.html snorkel.txt
snorkel.txt : snorkel.md
	./md2txt snorkel.md > snorkel.txt
snorkel.html : snorkel.md
	pandoc -fmarkdown -thtml5 --include-in-header=portfolio.css -o snorkel.html snorkel.md


clean :
	rm -rf A B C E mobius.txt kNN.md sets.md resume.html index.html dc_spl.html kNN.html kNN.md sets.html portfolio.html writing.html iris* tmp*

