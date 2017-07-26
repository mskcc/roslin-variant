#!/usr/bin/Rscript

# install required R libraries
pkgs = c("devtools", "stringr", "data.table", "xlsx", "RJSONIO", "Rcpp")

install.packages(pkgs, repos='http://cran.us.r-project.org')


# install R datasets of GC percentages for human and mouse genomes
devtools::install_github("mskcc/pctGCdata")


# install necessary BioConductor packages
source('https://bioconductor.org/biocLite.R')

biocLite(c('IRanges', 'DNAcopy', 'Rsamtools'))
