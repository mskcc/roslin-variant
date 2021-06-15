#!/usr/bin/Rscript

# install required R libraries
pkgs = c("mgcv","BiocManager","ggplot2","Cairo","argparse","data.table","gtable","gridExtra","bit64","plyr","formatR","dplyr","tidyr","stringr","reshape2","rlang")

install.packages(pkgs, repos='http://cran.us.r-project.org')

BiocManager::install("rtracklayer")
