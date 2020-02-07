# https://stackoverflow.com/questions/50797833/why-do-my-second-level-futures-execute-serially
# Original question: Why do my second-level futures execute serially?
# and the author of future Henrik Bengtsson: Built-in protection against recursive parallelism
library(future)
library(ggplot2)
library(future.callr)
library(future.apply)
library(data.table)

plan(list(callr, callr))
#plan(list(multicore, multicore)) ## you can try differnt future method and
#plan(list(multiprocess, multiprocess)) #### see different results in ggplot

# Run for a random amount of time and return start and stop time
startStop <- function(i,j){
  start <- Sys.time()
  x <- runif(1, 1, 3)
  Sys.sleep(x)
  stop <- Sys.time()
  return(data.frame(iGrp=i, iCV=j, 
                    start = start, stop = stop))
}

nGrp <- 3
nCV <- 4

l <- rep(list(NULL), nGrp)

d <- rbindlist(future_lapply(seq_len(nGrp), function(x, l){
  m <- rep(list(NULL), nCV)
  l[[x]] <- rbindlist(future_lapply(seq_len(nCV), function(y, m, x) {
    m[[y]] <- startStop(x,y)
  }, m=m, x=x))
}, l=l))

############################## alternatively, use loop
###################### Original code in StackOverflow, provided by akraf
#for(i in seq_along(l)){
#  l[[i]] <- future({
#    m <- rep(list(NULL), nCV)
#    for(j in seq_along(m)){
#      m[[j]] <- future(startStop(i,j)) ## modified (by me) to append i,j 
#    }
#    m <- lapply(m, value)
#    m <- do.call(rbind, m)
#    m
#  })
#}
#l <- lapply(l, value)
#d <- do.call(rbind, l)
## d$iGrp <- rep(seq_len(nGrp), each = nCV)
## d$iCV <- rep(seq_len(nCV), times = nGrp)
################################################################

d$x <- paste(d$iGrp, d$iCV, sep = "_")
d$iGrp <- as.character(d$iGrp)
ggplot(d, aes(x = x, ymin = start, ymax = stop, color = iGrp)) + geom_linerange() + coord_flip()
