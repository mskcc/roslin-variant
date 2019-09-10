#!/usr/bin/Rscript

# install required R libraries
pkgs = c("ggplot2","Cairo","argparse","data.table","gtable","gridExtra","bit64","plyr","formatR")

install.packages(pkgs, repos='http://cran.us.r-project.org')

#install bioconductor packages
source("https://bioconductor.org/biocLite.R")
biocLite("rtracklayer")
