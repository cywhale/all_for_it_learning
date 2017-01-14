# original post in Ptt: https://www.ptt.cc/bbs/R_Language/M.1480607402.A.8BD.html
# make duration in (year, season) in long format
# minor alternatives: use %between% (data.table::between) and tstrsplit to  replace substr

library(data.table)
library(magrittr)
# original data, dt in wide format, only start and end year; 2 seasons in one year. Need to expand to long format.
dt <- fread('id start_y start_s end_y end_s
1       100     1     102    2
2       101     2     103    1
3       101     2     101    2') %>%
  .[,{.(id=id,
        start=as.numeric(paste(start_y,start_s,sep=".")),
        end = as.numeric(paste(end_y,end_s,sep=".")))}] %>% setkey(start,end)
#   id start   end
#1:  1 100.1 102.2
#2:  3 101.2 101.2
#3:  2 101.2 103.1

# intermediate full-list durations to do interval join
gt <- CJ(start_y=100:103, s=1:2) %>%
  .[,{.(start=as.numeric(paste(start_y,s,sep=".")))}] %>% unique() %>%
  .[,end:=start]

#   start   end
#1: 100.1 100.1
#2: 100.2 100.2
#3: 101.1 101.1
#4: 101.2 101.2
#5: 102.1 102.1
#6: 102.2 102.2
#7: 103.1 103.1
#8: 103.2 103.2

gx <- foverlaps(gt, dt, type="within", which=TRUE) %>%
  .[which(!is.na(yid)),]

out <- cbind(dt[gx$yid,.(id)], gt[gx$xid,.(start)]) %>% .[order(id),] %>%
  .[,c("year","s"):=tstrsplit(start,".",fixed=T)] %>% .[,start:=NULL]

#    id year s
# 1:  1  100 1
# 2:  1  100 2
# 3:  1  101 1
# 4:  1  101 2
# 5:  1  102 1
# 6:  1  102 2
# 7:  2  101 2
# 8:  2  102 1
# 9:  2  102 2
#10:  2  103 1
#11:  3  101 2
