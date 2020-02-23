# http://chingchuan-chen.github.io/posts/201607/2016-07-10-pipe-operators-in-R.html
# magrittr: https://github.com/tidyverse/magrittr
# pipeR: https://github.com/renkun-ken/pipeR
# nakedpipe: https://github.com/moodymudskipper/nakedpipe

# code from chingchuan-chen
library(magrittr)
library(pipeR)
library(nakedpipe)
library(microbenchmark)
eq_f <- `==`
microbenchmark(magrittr = {
  lapply(1:10000, function(i) {
    sample(letters, 6, replace = T) %>% paste(collapse = "") %>% eq_f("rstats")
  })
}, pipeR = {
  lapply(1:10000, function(i) {
    sample(letters, 6, replace = T) %>>% paste(collapse = "") %>>% eq_f("rstats")
  })
},nakedpipe = {
  lapply(1:10000, function(i) {
    sample(letters, 6, replace = T) %.% paste(collapse = "") %.% eq_f("rstats")
  })
}, times = 20L)

## Unit: milliseconds
## expr       min        lq      mean    median        uq       max neval cld
## magrittr 1234.8965 1295.2809 1338.8197 1333.0450 1379.6316 1491.7386    20   c
## pipeR     390.3592  406.1511  428.6364  411.8193  442.7911  595.9935    20 a  
## nakedpipe 983.2897 1029.2518 1056.6712 1045.0260 1072.7164 1211.6641    20  b 

## code from nakedpipe's author test
microbenchmark(
            `%>%` = cars %>% 
              identity %>%
              identity() %>%
              identity(.) %>%
              {identity(.)},
            `%>>%` = cars %>>% {
              identity(.)
              identity(.)
              identity(.)
              {identity(.)}
            },
            `%.%` = cars %.% {
              identity
              identity()
              identity(.)
              {identity(.)}
            },
            `%..%` = cars %..% {
              identity(.)
              identity(.)
              identity(.)
              {identity(.)}
            },
            `base` = {
              . <- cars
              . <- identity(.)
              . <- identity(.)
              . <- identity(.)
              . <- identity(.)
            }, times = 10000
)

## Unit: microseconds
## expr     min      lq       mean  median       uq       max neval   cld
## %>%  114.401 126.102 143.805319 130.901 139.7005 14569.600 10000     e
## %>>%   9.500  12.702  16.228995  15.401  16.8000  5578.001 10000  b   
## %.%   53.201  59.601  68.767718  63.501  67.6010  5880.801 10000    d 
## %..%  17.001  20.501  24.545096  22.200  23.7010  5779.901 10000   c  
## base   1.500   2.101   2.618424   2.501   2.8010    45.502 10000 a  
