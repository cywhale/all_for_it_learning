# original post in Ptt: https://www.ptt.cc/bbs/R_Language/M.1480607402.A.8BD.html
# make duration in (year, season) in long format
# minor alternatives: use %between% (data.table::between) and tstrsplit to  replace substr

library(data.table)
library(magrittr)
dt <- fread('id start_y start_s end_y end_s
1       100     1     102    2
2       101     2     103    1
3       101     2     101    2') %>%
  .[,{.(id=id,
        start=as.numeric(paste(start_y,start_s,sep=".")),
        end = as.numeric(paste(end_y,end_s,sep=".")))}] %>% setkey(start,end)

gt <- CJ(start_y=100:103, s=1:2) %>%
  .[,{.(start=as.numeric(paste(start_y,s,sep=".")))}] %>% unique() %>%
  .[,end:=start]

gx <- foverlaps(gt, dt, type="within", which=TRUE) %>%
  .[which(!is.na(yid)),]

cbind(dt[gx$yid,.(id)], gt[gx$xid,.(start)]) %>% .[order(id),] %>%
  .[,{.(id=id,
        year=substr(start,1,nchar(start)-2),
        s=substr(start,nchar(start),nchar(start))
  )}]

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
