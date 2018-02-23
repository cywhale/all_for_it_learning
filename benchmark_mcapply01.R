# benchmark purrr, mcapply, data.table and future.lapply
# modified from https://scottishsnow.wordpress.com/2018/02/18/dplyr-lapply-for-loop/
# by Mike Spencer, also see his tweet https://twitter.com/MikeRSpencer/status/966435928444153858
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

# Benchmark
mtimes <- microbenchmark ( ## will crash
  #'forloop'= loop_foo(f),
  'purrr'= purrr_foo(f),
  'lapply_future' = rbindlist(future_lapply(f, fread_clean_fwrite)),
  'mclapply' = rbindlist(mclapply(f, mc.cores=4, read_clean_write)),
  'mclapply_data.table'= rbindlist(mclapply(f, mc.cores=4, fread_clean_fwrite)),
  times = 50L
)
#Unit: milliseconds
#expr       min        lq      mean    median       uq      max neval
#purrr 726.75689 765.00129 803.02083 786.82449 832.1882 907.0319    50
#lapply_future 115.70859 126.45762 157.86677 141.08902 166.0428 457.2523    50
#mclapply 211.09944 224.22713 275.19899 242.54487 309.0524 479.8111    50
#mclapply_data.table  58.77066  68.60537  94.84471  77.21572  91.4194 369.0396    50

times = list(
  #forloop = system.time(loop_foo(f)),
  purrr= system.time(purrr_foo(f)),
  lapply_future = system.time(rbindlist(future_lapply(f, fread_clean_fwrite))),
  mclapply = system.time(rbindlist(mclapply(f, mc.cores=4, read_clean_write))),
  mclapply_data.table= system.time(rbindlist(mclapply(f, mc.cores=4, fread_clean_fwrite)))
)

x = sapply(times, function(i){i["elapsed"]}) #code by Mike Spencer
names(x) = substr(names(x), 1, nchar(names(x)) - 8)

par(mar=c(5, 8.5, 4, 2) + 0.1)
barplot(x, names.arg=names(x),
        main="Elapsed time on an Intel i5 4460 with 4 cores at 3.2GHz",
        xlab="Seconds", horiz=T, las=1)
#par(mar=c(5, 4, 4, 2) + 0.1)

