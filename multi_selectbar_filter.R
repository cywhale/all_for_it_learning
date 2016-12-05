# Original post in Ptt: https://www.ptt.cc/bbs/R_Language/M.1480061698.A.D11.html
# Multiple SelectBar (such as in Shiny) to filter a given data by its columns
# Allow multple selection or null selection of values in column variables

library(data.table)
library(magrittr)

selx <- function(...,data,varname=c("A","B","C")) {
  x <- list(...)
  names(x) <- varname[1:length(x)]
  dt <- do.call(cbind, x) %>% data.table() %>%
    .[,which(unlist(lapply(., function(x)!all(is.na(x))))),with=F] %>%
    setkeyv(colnames(.))

  return(dt %>%
          .[data %>% setkeyv(colnames(dt)), nomatch=0L] %>%
          .[,colnames(data),with=F]
  )

}

data = fread('"食性"  "生育方式" "生活地區"
"肉食"   "胎生" "水生"
"草食" "胎生" "陸生"
"肉食"  "卵生" "水生"
"雜食" "胎生" "兩棲"
"草食" "胎生" "兩棲"')

## you can use
## selx(input$sela, input$selb, input$selc,..., data=data, varname=c(...))

selx(c(NA_character_), c(NA_character_), c("水生"), data=data,
varname=colnames(data))
#食性 生育方式 生活地區
#1: 肉食     卵生     水生
#2: 肉食     胎生     水生
selx(c(NA_character_), c("胎生","卵生"), c("水生"), data=data,
varname=colnames(data))
#食性 生育方式 生活地區
#1: 肉食     卵生     水生
#2: 肉食     胎生     水生

selx(c("雜食","草食"), c("卵生"), c("水生"), data=data,
varname=colnames(data))
#Empty data.table (0 rows)

selx(c("雜食","草食"), c("胎生"), c("兩棲"), data=data,
varname=colnames(data))
#食性 生育方式 生活地區
#1: 草食     胎生     兩棲
#2: 雜食     胎生     兩棲

selx(c("肉食"), c("胎生"), c(NA_character_), data=data,
varname=colnames(data))
#食性 生育方式 生活地區
#1: 肉食     胎生     水生
