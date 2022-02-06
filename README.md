# Overview

This repo is an analysis of vehicle speed observations made in the City of Toronto by mobile (temporary) speed display signage. The focuses of this paper was to determine whether speed limit compliance on residential streets in Toronto was high, and investigate overall trends in speeding behaviour in individual municipal wards. 

It is organised as follows:

`/scripts/` contains `.R` files for retrieving and organising the data for presenting within the report.

`/outputs/paper/` contains the main Rmarkdown file where the report is written, as well as the final knitted PDF using `bookdown::pdf_document2`. References are contained within `references.bib` in BibTEX format.

`/inputs/` contains the data as retrieved from `opendatatoronto` as well as the finalised R objects used within the Rmarkdown file, saved as `.Rds` files.

## Reproducing the report
To reproduce the final report:

1. Run `/scripts/01-data-download.R` then `/scripts/01-data-cleaning.R` in order.
2. Open `/outputs/paper/paper.Rmd` and install the required packages, then knit to `pdf_document2`.
