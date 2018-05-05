# Easy use rbindlist and transpose to convert list into data.table
# PTT Question: https://www.ptt.cc/bbs/R_Language/M.1525430643.A.691.html
# data source (xml): https://ideone.com/jqS8fo
# my reply also posted on: https://www.ptt.cc/bbs/R_Language/M.1525446714.A.268.html
library(XML)
library(data.table)
library(magrittr)
#library(purrr)

#Read in PDF file
## regular ex
# PDF <- xmlTreeParse("ideone_jqS8fo.xml", useInternalNodes=TRUE)
## irregular ## arbitrary add a TEXT section 
PDF <- xmlTreeParse("ideone_jqS8fo1.xml", useInternalNodes=TRUE)

#Get the page/text/location information

pages <- getNodeSet(PDF, "//Page[@number]")
words <- sapply(seq_along(pages), function(x, pages) {
  wx<- getNodeSet(PDF, paste0("//Page[@number='",x,"']/Content/Para/Box/Word"))
  length(wx)
}, simplify = TRUE)



out <- rbindlist(list(#rep(xpathApply(PDF, path="//Page", fun= xmlGetAttr, 'number'), each=2)
                      #purrr::flatten(mapply(rep, times=words, x=seq_along(pages), USE.NAMES = F)),
                      as.list(do.call(function(x,times) {rep(x,times)}, args=list(x=seq_along(pages), times=words))),
                      xpathApply(PDF, path="//Page/Content/Para/Box/Word/Text", fun= xmlValue),
                      xpathApply(PDF, path="//Page/Content/Para/Box/Word/Box[@*]", fun= xmlAttrs)     
                    )) %>% data.table::transpose() 

## regular ex  
out
#V1    V2     V3     V4     V5     V6
#1:  1  D1.2  70.87  43.56  94.53  31.56
#2:  1  Date 109.17 156.75 131.80 144.75
#3:  2 Forms  70.87  43.56  94.53  31.56
#4:  2  only 264.74  43.56 286.73  31.56

## irregular ## arbitrary add a TEXT section 
#> out
#V1    V2     V3     V4     V5     V6
#1:  1  D1.2  70.87  43.56  94.53  31.56
#2:  1  Date 109.17 156.75 131.80 144.75
#3:  1 MyTry  10.17  15.75  13.80  14.75
#4:  2 Forms  70.87  43.56  94.53  31.56
#5:  2  only 264.74  43.56 286.73  31.56
