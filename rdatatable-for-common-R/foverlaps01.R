# Original post in Ptt: https://www.ptt.cc/bbs/R_Language/M.1476228440.A.4B2.html
# Find data matrix (gyro) fall in Fixation_duration (start, end) and get fixation_x * mean(gyro)

library(data.table)
library(magrittr)

gt <- fread('gyro    start
6.9     0
4.7     50.69
1.5     55.77
-2.3    63.44
-4.3    90
NA      100.11
NA      124.1
-1.3    150.22
1.5     160') %>%

  .[,end:=start+0.01]
#because you only permit gt$start < ft$end (Not <=), so I add 0.01

ft <- fread('start   end     fixation_x      fixation_y
50.69   100.11  1020            590
124.1   160     1123            690
200     275     1700            300
500     551.25  850             475
700     890.2   697             785') %>%

  setkey(start,end)

gx <- gt[,fid:=foverlaps(gt, ft, type="within", which=TRUE)$yid] %>%
  .[-which(is.na(fid)), mean(gyro,na.rm=T), by=.(fid)]

ft[,fid:=.I] %>% setkey(fid) %>% .[gx, fixation_x*V1]
#   fid fixation.x_gyro
#1:   1          -102.0
#2:   2         -1459.9
