# Original question in Ptt: https://www.ptt.cc/bbs/R_Language/M.1480922765.A.008.html
# compare and benchmark here https://www.ptt.cc/bbs/R_Language/M.1480931811.A.FB5.html
# comparison of web versions: http://pastebin.com/Msib1dEh
# rollapply for previous 7 days moving average.
# minor bugs should be modified: detect if length(x)=1 makes length(x[-length(x)])<0

library(data.table)
library(magrittr)
library(zoo)

dt <- fread('ID Day X
  1   1    0.5
  1   3    0.1
  1   4    0.3
  1   7    0.5
  1   9    0.5
  1   11   0.2
  1   14   0.5
  2   1    0.1
  2   2    0.4
  2   5    0.8
  2   9    0.7
  2   11   0.1
  2   13   0.2', header=T) %>%
  setkey(ID, Day)

dt[CJ(unique(ID), seq(min(Day), max(Day)))][,{.(
  Day=rollapply(Day,8,max),
  Mx=rollapply(X, 8, function(x) mean(x[-length(x)],na.rm=T)))}, by = .(ID)]
               
## Alternative ways provided by celestialgod
## https://www.ptt.cc/bbs/R_Language/M.1481106994.A.8CD.html
## DT[ , x_mean := sapply(Day, function(s) mean(X[Day >= s-7 & Day < s])), by = .(ID)]
               
#    ID Day        Mx
# 1:  1   8 0.3500000
# 2:  1   9 0.3000000
# 3:  1  10 0.3500000
# 4:  1  11 0.4333333
# 5:  1  12 0.4000000
# 6:  1  13 0.4000000
# 7:  1  14 0.4000000
# 8:  2   8 0.4333333
# 9:  2   9 0.6000000
#10:  2  10 0.7500000
#11:  2  11 0.7500000
#12:  2  12 0.5333333
#13:  2  13 0.4000000
#14:  2  14 0.3333333
