# Original question and reply in https://www.ptt.cc/bbs/R_Language/M.1482381492.A.3F0.html
# level 1 is root, then downto nodes, spread the long format to wide format
# trick: a repeated level counter in rows needed to be defined as different groups

library(data.table)
library(magrittr)

dt <- fread('LV      Obj     Dep
0       A1      ""
1       A1      A1
2       B1      A1
1       A1      A1
2       B2      A1
3       C1      B2
1       A1      A1
2       B2      A1
3       C2      B2
4       D1      C2')

dt[,stx:=ifelse(LV<1,"Dep1",paste0("Dep",LV)),by=.(LV)] %>%
  .[,nL:=as.integer(stx=="Dep1")] %>%
  .[,ngp:=cumsum(nL)]

x1 <- dcast(dt, ngp ~ stx, value.var = "Obj")
#x1
#   ngp Dep1 Dep2 Dep3 Dep4
#1:   1   A1   NA   NA   NA
#2:   2   A1   B1   NA   NA
#3:   3   A1   B2   C1   NA
#4:   4   A1   B2   C2   D1
