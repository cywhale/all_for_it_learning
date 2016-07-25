# Simple test for bigmemory packages, comapred to database usage

library(data.table)
library(magrittr)
library(bigmemory)
library(RPostgreSQL)
library(microbenchmark)

# ========================== Test data preparation
# ========================== some arguments just for future trials/usage..

tstL <- 1e6
wr.first <- TRUE
bigmf<- file("bigm_sample01.csv", open = "w")

DT <- data.table(lat=numeric(), lng=numeric(), date=as.Date(character()),
                 grp=numeric(), pick=numeric())

idxf <- function(x, idx) {
  x[-idx] <- 0; x[idx] <- 1; return(x)
}

pconn <- dbConnect(dbDriver("PostgreSQL"), # change to your configuration
                   user="xx", password="xx", dbname="xxx", host="localhost")

print("write big.mat start")
print(format(Sys.time(), "%Y%m%d %H:%M:%S"))

# randomly prepare data, can arbitrarily chang loop iteration
# loop 20 times create a file near 1 Gb
for (i in 1:20) {
  dt <- data.table(lat = runif(tstL,0,90),lng = runif(tstL,0,180),
                   yr = as.integer(runif(tstL,2000,2015)),
                   mo = as.integer(runif(tstL,1,12)),
                   day = as.integer(runif(tstL,1,28))) %>%
    .[,date:=as.Date(paste(yr,mo,day,sep=" "),"%Y %m %d")] %>%
    .[,c("yr","mo","day","grp"):=list(NULL,NULL,NULL,i)] %>% setkey(date) %>%
    .[,pick:=idxf(seq_along(lat),sample(seq_along(lat),1)), by=.(date)]

  print(format(Sys.time(), "%Y%m%d %H:%M:%S"))
  print("combine DT")

  DT <- rbindlist(list(DT, dt))

  print(format(Sys.time(), "%Y%m%d %H:%M:%S"))
  print("write to PostgreSQL")

  dbWriteTable(pconn, value=dt, name= "bigmdb", append=!wr.first, row.names=F)

  print(format(Sys.time(), "%Y%m%d %H:%M:%S"))
  print("write.table")

# Big.matrix cannot have mixed-type data, change charater 'date' to int 'datei'
  write.table(dt[,datei:=as.integer(gsub("-","",date))] %>% .[,date:=NULL],
              file = bigmf, sep = ",", row.names = FALSE, col.names = wr.first)

  print(i)
  wr.first <- FALSE
}

close(bigmf)

#========================== ? read.big.matrix
system.time(db <- read.big.matrix("bigm_sample01.csv", header = TRUE,
                      type = "double",
                      backingfile = "bigm_sample01.bin",
                      descriptorfile = "bigm_sample01.des"))
#   user  system elapsed
#  69.21    3.21   72.54
#========================== ? attach.big.matrix
system.time(db <- dget("bigm_sample01.des") %>% attach.big.matrix())
# user  system elapsed
# 0.01    0.00    0.01

nrow(db) ## 2e+07 rows
nrow(DT)
#========================== Indexing PostgreSQL data

dbSendQuery(pconn, "CREATE INDEX date_index ON bigmdb USING btree (date)")

#========================== simple benchmark

microbenchmark(
  'DT' = DT[date>='2003-01-01' & date <='2014-12-01' & pick==1,],
  'Bigm' = db[mwhich(db,c(5,5,4),list(c(20030101,20141201,1)),
                     list(c('ge','le','eq')),'AND'),],
  'SQL'= dbGetQuery(pconn, statement=paste0("SELECT * FROM bigmdb WHERE date >= '2003-01-01' AND date <= '20141201' AND pick = 1;")),
  times=10
) ######## Note: SQL statement should be in single line ######################

#Unit: milliseconds
#expr       min        lq      mean    median        uq       max neval
#  DT  325.0868  347.0721  367.5553  360.3873  389.9555  440.2354    10
#Bigm  404.6935  416.9812  452.5594  441.7622  462.6059  591.9303    10
# SQL 3221.8961 3226.8496 3303.9357 3274.3635 3377.8906 3521.6359    10

format(object.size(DT),"Mb")
#[1] "762.9 Mb"

format(object.size(out2),"Mb") ### actually data size loading into memory, if 'mwhich' filtering first..
#[1] "2.7 Mb"

lapply(dbListConnections(PostgreSQL()), dbDisconnect)

