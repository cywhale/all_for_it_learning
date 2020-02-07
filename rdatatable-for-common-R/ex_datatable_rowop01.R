## Efficient rowwise operations in #rdatatable #rollapply
library(data.table)
library(magrittr)
library(zoo)

#interval=6
species.number=30
size.breakpoints = c(0,10,19,29,39,50,100,200,500,1000,2000,5000)

#################### Test Data Generation ##############################
set.seed(123L)
dt <- data.table(id=1:1000, sp=sample(1:species.number, 1000, replace=T),
                 v1=sample(1:1000,1000, replace=T)) %>% .[,v2:= v1* (1+runif(1000,min=0, max=0.5))] %>%
  .[,v3:= v2* (1+runif(1000,min=0, max=0.5))] %>%
  .[,v4:= v3* (1+runif(1000,min=0, max=0.5))] %>%
  .[,v5:= v4* (1+runif(1000,min=0, max=0.5))] %>%
  .[,v6:= v5* (1+runif(1000,min=0, max=0.5))]

########################################################################
logdif <- function(x, c1=0.2) {
  x[is.na(x) | x<=0] <- NA
  return (c1*diff(log(x)))
}

rvalx <- function(x, width=2, c1=0.2) {
  as.list(rollapply(x, width=width, FUN=logdif, c1=c1, by.column=FALSE))
}

grp_sz<- dt[, lapply(.SD, cut, breaks= size.breakpoints, labels=FALSE), .SDcols=grep("^v",colnames(dt)[1:(ncol(dt)-1)]), by=.(id,sp)] %>%
  melt(id.vars=c("id","sp"),measure = patterns("^v")) %>% setnames(3:4, c("interval","category"))

rvals <- dt[, rvalx(unlist(.SD)), .SDcols=grep("^v",colnames(dt)), by=id] %>% setnames(2:ncol(.), paste0("v",1:(ncol(.)-1))) %>%
  melt(measure = patterns("^v")) %>% setnames(2:3, c("interval","rvals")) %>%
  merge(grp_sz, by=c("id","interval"), all=T) %>%
  .[,`:=`(cmeans=mean(rvals), csd=sd(rvals)), by=.(sp,category)] %>%
  .[, stdrval:= (rvals-cmeans)/csd]


