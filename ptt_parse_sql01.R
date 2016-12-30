## https://www.ptt.cc/bbs/R_Language/M.1483054339.A.CB6.html
library(data.table)
library(magrittr)
fcon <- file("D:/R/example/ptt_try_sql.txt", "r")
ftxt <- readLines(fcon)
close(fcon)

## directly copy from your question in ptt web, as input
print(ftxt)

## parse your input
trimx <- function(x) gsub('^\\s+|\\){0,}\\s{0,}\\"{0,}\\s+$','', x)
txt1 <- trimx(ftxt)

sqlcmd <- c("select","insert","join","delete","create")
sqlio <- c("from","into","table")

rstart <- c("insert","delete")
rstop  <- c("select","create")
rinter <- c("join")

s1 <- regexpr(paste(sqlcmd,collapse = "|"), txt1, ignore.case = TRUE)
t1 <- regexpr(paste(sqlio,collapse = "|"), txt1, ignore.case = TRUE)
sq
## First step, get a command - destination table

sqlt <- data.table(cmd=trimx(substr(x=txt1, start=s1, stop=s1+attributes(s1)$match.length-1)),
                   tbl=trimx(substr(x=txt1, start=t1+attributes(t1)$match.length, stop=ifelse(t1==-1,-1,nchar(txt1)))))

## Second step, one-by-one line to scan and handle if..else cases

gcnt <- 0L
ccnt <- 0L
clv  <- 0L
tmpo <- data.table(lv=0L, obj=NA_character_, dep=NA_character_, grp=0L, idcnt=0L)
out  <- data.table(lv=integer(), obj=character(), dep=character(), grp=integer(), idcnt=integer())
flag <- 0L
pend <- 0L
for (i in 1:nrow(sqlt)) {
  if (sqlt$cmd[i] %in% rstart) {
    if (flag==0L) {
      flag <- 1L
      ccnt <- ccnt+1L
    } else {
      ccnt <- 1L
      clv <- 0L
    }
    gcnt <- gcnt+1L
    cobj <- sqlt$tbl[i]
    tmpo[1,`:=`(lv=clv,obj=cobj,dep=NA_character_,grp=gcnt,idcnt=ccnt)]
    out <- rbind(out,tmpo)
    clv <- clv+1L
    pend<- 0L
    next
  } else if (sqlt$cmd[i] %in% rinter) {
    if (flag==0L) {
      flag <- 1L
      ccnt <- out[nrow(out)]$idcnt
      gcnt <- out[nrow(out)]$grp
      clv  <- out[nrow(out)]$lv + pend
      cobj <- out[nrow(out)]$obj
    } else {
      ccnt <- ccnt+1L
    }
    if (pend==0L) {
      tmpo[1,`:=`(lv=clv,obj=cobj,dep=NA_character_,grp=gcnt,idcnt=ccnt)]
      out <- rbind(out,tmpo)
    }
    pend<- 0L
    next
  } else if (sqlt$cmd[i] %in% rstop) {
    if (!is.na(sqlt$tbl[i]) & sqlt$tbl[i]!="") {
      ccnt <- ccnt+1L
      cobj <- sqlt$tbl[i]
      if (gcnt==0 | flag==0L) {gcnt<- gcnt+1}
      tmpo[1,`:=`(lv=clv,obj=cobj,dep=NA_character_,grp=gcnt,idcnt=ccnt)]
      out <- rbind(out,tmpo)
      ccnt <- 0L
      clv  <-0L
      cobj <-NA_character_
      flag <-0L
    } else {
      pend <- 1L
    }
    next
  } else {
    if (!is.na(sqlt$tbl[i]) & sqlt$tbl[i]!="") {
      cobj <- sqlt$tbl[i]
      if (pend==1L) {
        tmpo[1,`:=`(lv=clv,obj=cobj,dep=NA_character_,grp=gcnt,idcnt=ccnt+1)]
        out <- rbind(out,tmpo)
        ccnt <- 0L
        clv  <- 0L
        cobj <- NA_character_
        flag <- 0L
      }
    } else {
      if (is.na(sqlt$cmd[i]) | sqlt$cmd[i]=="") {
        ccnt <- ccnt+1L
        tmpo[1,`:=`(lv=clv,obj=cobj,dep=NA_character_,grp=gcnt,idcnt=ccnt)]
        out <- rbind(out,tmpo)
        ccnt <- 0L
        clv <-0L
        cobj<-NA_character_
        flag<-0L
      }
    }
    next
  }
}

## 3rd step: Addtional step to handle LV, DEP...

out[,lv:=max(lv)-lv, by=.(grp)] %>%
  .[,dep:=ifelse(lv==0,NA_character_,shift(obj,type="lead")),by=.(grp)]
