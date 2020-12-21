# benchmark purrr, mcapply, data.table and future.lapply
# modified from https://scottishsnow.wordpress.com/2018/02/18/dplyr-lapply-for-loop/
# by Mike Spencer, also see his tweet https://twitter.com/MikeRSpencer/status/966435928444153858

# update for data.table dev 1.10.5 (News.md https://github.com/Rdatatable/data.table/blob/master/NEWS.md )
# install.packages("data.table", type = "source", repos = "http://Rdatatable.github.io/data.table")

# Not a critical example, because each file is small.

library(tidyverse)
library(parallel)
library(microbenchmark)
library(data.table)

# Dummy files to process #code by Mike Spencer
dir.create("./temp/raw", recursive=T)
dir.create("./temp/clean")

lapply(1950:2017, function(i){
  date = seq.Date(as.Date(paste0(i, "-01-01")),
                  as.Date(paste0(i, "-12-31")),
                  by=1)
  a = rnorm(length(date))
  a1 = rnorm(length(date))
  a2 = rnorm(length(date))
  b = rpois(length(date), 10)
  b1 = rpois(length(date), 10)
  b2 = rpois(length(date), 10)
  c = rexp(length(date), 5)
  c1 = rexp(length(date), 5)
  c2 = rexp(length(date), 5)
  
  write_csv(data.frame(date, a, a1, a2, b, b1, b2, c, c1, c2),
            paste0("./temp/raw/file_", i, ".csv"))
})


# Get a vector of file names
f = list.files("./temp/raw", pattern="file")

# Interactive dplyr #code by Mike Spencer
#system.time(
#  walk(f, ~ paste0("./temp/raw/", .x) %>%
#         read_csv() %>%
#         select(date, a, b, c) %>%
#         gather(variable, value, -date) %>%
#         write_csv(paste0("./temp/clean/", .x)))
#)

# As a function #modified
read_clean_write = function(i){
  paste0("./temp/raw/", i) %>%
    read_csv() %>%
    select(date, a, b, c) %>%
    gather(variable, value, -date) #%>%
    #write_csv(paste0("./temp/clean/", i))
}

# purrr function #modified
purrr_foo <- function(f) {
  map(f, read_clean_write) %>% bind_rows()
}


# data.table function #modified
fread_clean_fwrite = function(i){
  paste0("./temp/raw/", i) %>%
    fread(select=c("date", "a", "b", "c")) %>%
    melt.data.table(id.vars = "date") #%>%
    #fwrite(paste0("./temp/clean/", i))
}

# Loop
#loop_foo <- function(f) {
#  for (j in f){
#    read_clean_write(j)
#  }
#}

# lapply
# lapply(f, read_clean_write)

tt1 <- rbindlist(mclapply(f, mc.cores=4, fread_clean_fwrite))

library(future.apply) #modified
#plan("multicore")
plan(multiprocess) ## but seems not specify how many proccessors used?

tt2 <- rbindlist(future_lapply(f, fread_clean_fwrite))

all.equal(tt1,tt2)

tt3 <-purrr_foo(f)
all.equal(tt1,tt3 %>% data.table())

datatable_foo <- function(f) {
  rbindlist(lapply(
    paste0("./temp/raw/", f),
    fread, select=c("date", "a", "b", "c")
  )) %>% melt.data.table(id.vars = "date")
}

all.equal(tt1 %>% setorder(date) ,datatable_foo(f) %>% setorder(date))

# Benchmark
mtimes <- microbenchmark ( ## will crash
  #'forloop'= loop_foo(f),
  'purrr'= purrr_foo(f),
  'datatable'= datatable_foo(f),
  'lapply_future' = rbindlist(future_lapply(f, fread_clean_fwrite)),
  'mclapply' = rbindlist(mclapply(f, mc.cores=4, read_clean_write)),
  'mclapply_data.table'= rbindlist(mclapply(f, mc.cores=4, fread_clean_fwrite)),
  times = 50L
)
#Unit: milliseconds data.table version 1.10.5 use 32G RAM)
#expr       min        lq      mean    median        uq      max neval
#purrr 760.60659 790.45448 824.13510 805.96776 836.95366 965.1273    50
#datatable  99.35356 106.83779 116.64021 111.58510 121.26902 243.1460    50
#lapply_future 124.23986 141.22057 162.75011 152.70512 165.78870 309.2831    50
#mclapply 222.91257 233.16105 269.45015 258.72337 293.84481 522.2993    50
#mclapply_data.table  65.34642  78.46321  89.96808  82.80777  98.55239 226.5945    50

times = list(
  #forloop = system.time(loop_foo(f)),
  purrr= system.time(purrr_foo(f)),
  datatable= system.time(datatable_foo(f)),
  lapply_future = system.time(rbindlist(future_lapply(f, fread_clean_fwrite))),
  mclapply = system.time(rbindlist(mclapply(f, mc.cores=4, read_clean_write))),
  mclapply_data.table= system.time(rbindlist(mclapply(f, mc.cores=4, fread_clean_fwrite)))
)

x = sapply(times, function(i){i["elapsed"]}) #code by Mike Spencer
names(x) = substr(names(x), 1, nchar(names(x)) - 8)

par(mar=c(5, 8.5, 4, 2) + 0.1)
barplot(x, names.arg=names(x),
        main="Elapsed time on an Intel i7 7700 with 4 cores at 3.6GHz",
        xlab="Seconds", horiz=T, las=1)


