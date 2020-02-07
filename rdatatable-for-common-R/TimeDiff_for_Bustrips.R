# Original post in Ptt: https://www.ptt.cc/bbs/R_Language/M.1480658003.A.539.html
# .I[which(Leave==TRUE)][1L] to select by group (BusID) and get the first index of entry of bus leaving

library(data.table)
library(magrittr)

dt <- fread('Goback,  NameZh,     Leave,  Time,  UniqueBusID
0,       大興一街,   TRUE,   2015/1/1 13:10:32,  大興一街->屯區藝文中心162
0,       大興五街,   FALSE,  2015/1/1 13:10:39,  大興一街->屯區藝文中心162
0,       大興五街,   TRUE,   2015/1/1 13:10:51,  大興一街->屯區藝文中心162
0,     屯區藝文中心, FALSE,  2015/1/1 13:11:20,  大興一街->屯區藝文中心162
0,     屯區藝文中心, TRUE,  2015/1/1 13:12:32,  大興一街->屯區藝文中心162
1,     屯區藝文中心, FALSE,  2015/1/1 13:36:50,  屯區藝文中心->莒光新城163
1,     屯區藝文中心, TRUE,  2015/1/1 13:36:56,  屯區藝文中心->莒光新城163
1,       大興五街,   FALSE,  2015/1/1 13:37:28,  屯區藝文中心->莒光新城163
1,       大興五街,   TRUE,   2015/1/1 13:37:38,  屯區藝文中心->莒光新城163
1,       大興一街,   FALSE,  2015/1/1 13:37:43,  屯區藝文中心->莒光新城163',
sep=",", header=T)

dt[,Time:=as.POSIXct(strptime(Time,"%Y/%m/%d %H:%M:%S"))] %>%
  .[,c("rid","qid") := list(.I, .I[which(Leave==TRUE)][1L]),by=.(UniqueBusID)]

out <- dt[qid==rid | (rid>qid & Leave==FALSE),
   {.(qid=qid,
      rid=rid,
      dif= Time-Time[rid==qid])}, by=.(UniqueBusID)] %>%
  .[qid!=rid, .(UniqueBusID, dif)]

#                 UniqueBusID     dif
#1: 大興一街->屯區藝文中心162  7 secs
#2: 大興一街->屯區藝文中心162 48 secs
#3: 屯區藝文中心->莒光新城163 32 secs
#4: 屯區藝文中心->莒光新城163 47 secs
