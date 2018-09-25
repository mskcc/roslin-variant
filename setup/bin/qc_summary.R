#!/usr/bin/env Rscript

## Usage: /opt/common/CentOS_6/R-3.2.0/bin/Rscript qc_images.R "pre='$PRE'" "bin='$BIN'" "path='$PATH_TO_METRICS'" "logfile='$LOGFILE'"

#options(echo = FALSE)
library("optparse")


option_list = list(
  make_option(c("--pre", type="character", default=NULL, help="project prefix")),
  make_option(c("--path", type="character", default=".", help="Path containing metrics data")),
  make_option(c("--logfile", type="character", default="qcPDF.log", help="log file of qcPDF run")),
  make_option(c("--cov_warn_threshold", type="int")),
  make_option(c("--cov_fail_threshold", type="int")),
  make_option(c("--dup_rate_threshold", type="int")),
  make_option(c("--minor_contam_threshold", type="float")),
  make_option(c("--major_contam_threshold", type="float")),
  make_option(c('--output_dir', type="character")),
  make_option(c("--bin", type="character", help="location of R scripts"))
)


type = "exome"

#args=(commandArgs(TRUE))
#for(i in 1:length(args)){
#    eval(parse(text=args[i]))
#}


opt_parser = OptionParser(option_list=option_list)
args = parse_args(opt_parser)
pre=args$pre
logfile=args$logfile
cov_warn_threshold=args$cov_warn_threshold
cov_fail_threshold=args$cov_fail_threshold
dup_rate_threshold=args$dup_rate_threshold
minor_contam_threshold=args$minor_contam_threshold
major_contam_threshold=args$major_contam_threshold
bin=args$bin

path = as.character(args$path)

source(paste(bin, "/get_metrics_from_files.R", sep=""))
source(paste(bin,"/plot_qc.R", sep=""))

print.image <- function(dat,metricType,sortOrder,plot.function,extras,square=FALSE){
    units = "in"
    width = 11
    height = 7
    res = 600
    type = "cairo"
    if(square == TRUE){
        width = 5
        height = 5
    }

    if(!is.null(dat)){
        tryCatch({
                    #png(filename=paste(path,"/images/",pre,"_",sortOrder,"_",metricType,".png",sep=""),type=type,units=units,width=width,height=height,res=res)
                    pdf(file=paste(args$output_dir, pre,"_",sortOrder,"_",metricType,".pdf",sep=""),width=width,height=height)
                    print(plot.function(dat, extras))
                    #plot.function(dat)
                    dev.off()
                 },
          error = function(e){
            cat(paste("ERROR: could not write ",metricType," image\n",sep=""), file=logfile, append=TRUE)
            cat(paste(e,"\n"),file=logfile,append=TRUE)
            no.fails = FALSE
          }
        )
    } else {
        cat(paste("ERROR: could not get ",metricType," metrics\n",sep=""),file=logfile, append=TRUE)
        no.fails = FALSE
    }
}

cat(paste(date(),"\n"),file=logfile, append=TRUE)
cat(paste(args,"\n"),file=logfile, append=TRUE)
no.fails = TRUE

dir.create(paste(path,"/images",sep=""),showWarnings=FALSE)

## read in all metrics from text files in path
cat(c(path,"\n"))
is = get.is.metrics(path,type)
hs = get.hs.metrics(path,type)
bq = get.base.qualities(path,type)
dp = get.duplication(path,type)
ls = get.library.size(path,type)
al = get.alignment(path,type)
tr = get.trimmed.reads(path,type)
cs = get.capture.specificity(path,type)
cv = get.coverage(path,type)
da = get.fpc.sum(path,type)
mjc = get.major.contamination(path,type)
mnc = get.minor.contamination(path,type)
#cc = get.cdna.contamination(path,type)
gc = get.gc.bias(path,type)

is.summary = NULL
dp.summary = NULL
al.summary = NULL
cs.summary = NULL
cv.summary = NULL
mjc.summary = NULL
mnc.summary = NULL

## get summary values (averages, etc)
if(!is.null(is)){ is.summary = get.mean.is.peak(type,dat=get.is.peaks(path,type)) } 
if(!is.null(dp)){ dp.summary = get.mean.duplication(type,dat=dp)*100 }
if(!is.null(ls)){ ls.summary = get.mean.library.size(type,dat=ls) }
if(!is.null(al)){ al.summary = get.alignment.totals(type,dat=al) }
if(!is.null(cs) && !is.null(hs)){ cs.summary = get.capture.specificity.summary(type,cs=cs,hs=hs) }
if(!is.null(cv)){ cv.summary = get.mean.coverage(type,cv)$All }
if(!is.null(mjc)){ mjc.summary = get.mean.frac.het.pos(type,dat=mjc) }
if(!is.null(mnc)){ mnc.summary = get.mean.minor.allele.freq(type,dat=mnc) }

## print images
extras = list(major_contam_fail=as.numeric(major_contam_threshold),
              minor_contam_fail=as.numeric(minor_contam_threshold),
              minor_contam_warn=as.numeric(minor_contam_threshold)/2,
              cov_warn=as.numeric(cov_warn_threshold),
              cov_fail=as.numeric(cov_fail_threshold),
              #i guess the calculation uses "50" to mean 50% but the plot thinks i mean 5000 percent unless i do this
              #who knows
              #ccharris 10-26-2017
              dup_warn=as.numeric(dup_rate_threshold)/100)
print.image(al,"alignment","01",plot.alignment,extras)
print.image(al,"alignment_percentage","02",plot.alignment.percentage,extras)
print.image(cs,"capture_specificity","03",plot.capture.specificity,extras)
print.image(cs,"capture_specificity_percentage","04",plot.capture.specificity.percentage,extras)
print.image(is,"insert_size","05",plot.insert.size.distribution,extras)
print.image(is,"insert_size_peaks","06",plot.insert.peaks,extras)
print.image(da,"fingerprint","07",plot.fpc.sum,extras) #,square=TRUE, }
print.image(mjc,"major_contamination","08",plot.major.contamination,extras) 
print.image(mnc,"minor_contamination","09",plot.minor.contamination,extras) 
#print.image(cc,"cdna_contamination","10",plot.cdna.contamination,extras) 
print.image(dp,"duplication","11",plot.duplication,extras) 
print.image(ls,"library_size","12",plot.library.size,extras) 
print.image(cv,"coverage","13",plot.coverage,extras) 
print.image(tr,"trimmed_reads","14",plot.trimmed.reads,extras) 
print.image(bq,"base_qualities","15",plot.base.qualities,extras) 
print.image(gc,"gc_bias","16",plot.gc.bias,extras) #,square=TRUE)

## write sample level summary table
tryCatch({
    #args come from command line ##charris
    #FIXME
    #TERRIBLE!
    detail = as.matrix(get.detail.table(path,type,dup_rate_threshold,cov_warn_threshold,cov_fail_threshold,minor_contam_threshold,major_contam_threshold))
    colnames(detail)[1] = "Auto-status"
    detail[which(detail[,1]=='0FAIL'),1] = 'FAIL'
    detail[which(detail[,1]=='1WARN'),1] = 'WARN'
    detail[which(detail[,1]=='2PASS'),1] = 'PASS'

    summary.row = rep("",ncol(detail))
    summary.row[which(colnames(detail)=="Sample")] = "Project Average"
    if(!is.null(mjc.summary)){ summary.row[which(colnames(detail)=="Major Contamination")] = mjc.summary }
    if(!is.null(mnc.summary)){ summary.row[which(colnames(detail)=="Minor Contamination")] = mnc.summary }
    if(!is.null(cv.summary)){ summary.row[which(colnames(detail)=="Coverage")] = round(cv.summary) }
    if(!is.null(dp.summary)){ summary.row[which(colnames(detail)=="Duplication")] = dp.summary }
    if(!is.null(ls.summary)){ summary.row[which(colnames(detail)=="Library Size (millions)")] = ls.summary }
    if(!is.null(is.summary)){ summary.row[which(colnames(detail)=="Insert Size Peak")] = round(is.summary) }
    if(!is.null(cs.summary)){ summary.row[which(colnames(detail)=="On Bait Bases (millions)")] = round(cs.summary$meanOnBait/1000000) }
    if(!is.null(al.summary)){ summary.row[which(colnames(detail)=="Aligned Reads (millions)")] = round((al.summary$totalClusters/nrow(detail))/1000000) }
    summary.row[which(colnames(detail)=="Percentage Trimmed Reads")] = round(mean(as.numeric(detail[,which(colnames(detail)=="Percentage Trimmed Reads")])),digits=2) 

    detail = rbind(summary.row,detail)
    write.table(detail,file=file.path(path,paste(pre,"_SampleSummary.txt",sep="")),sep="\t",quote=F,row.names=F,col.names=T)
}, error = function(e){
        cat(paste("ERROR: could not write ",paste(path,"/",pre,"_SampleSummary.txt",sep=""),"\n",sep=""), file=logfile,append=TRUE)
        cat(paste(e,"\n"),file=logfile,append=TRUE)
        no.fails = FALSE
})


## write project level summary table
tryCatch({
    write.table(get.project.summary(type,path),file=file.path(path,paste(pre,"_ProjectSummary.txt",sep="")),sep="\t",quote=F,row.names=F,col.names=T)
}, error = function(e){
        cat(paste("ERROR: could not write ",paste(path,"/",pre,"_ProjectSummary.txt",sep=""),"\n",sep=""), file=logfile,append=TRUE)
        cat(paste(e,"\n"),file=logfile,append=TRUE)
        no.fails = FALSE
})

if (no.fails == FALSE){
    quit(save="no",status=15,runLast=TRUE)
}
