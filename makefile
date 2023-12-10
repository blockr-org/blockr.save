check: document
	Rscript -e "devtools::check()"

install: check
	Rscript -e "devtools::install()"

document: 
	Rscript -e "devtools::document()"

dev:
	Rscript test.R

