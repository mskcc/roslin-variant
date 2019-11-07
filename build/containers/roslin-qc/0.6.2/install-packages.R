#!/usr/bin/Rscript

# install required R libraries
pkgs = c("ggplot2","gplots","scales","reshape","plyr","RColorBrewer","optparse")
install.packages("corrplot", repos='http://cran.wustl.edu')
install.packages(pkgs, repos='http://cran.us.r-project.org')
