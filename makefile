check: document
	Rscript -e "devtools::check()"

document: 
	Rscript -e "devtools::document()"

install: check
	Rscript -e "devtools::install()"

dev:
	Rscript test.R

