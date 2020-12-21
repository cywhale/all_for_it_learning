# https://www.ptt.cc/bbs/R_Language/M.1568173572.A.E8F.html
# CWB open API: https://opendata.cwb.gov.tw/dist/opendata-swagger.html
library(curl)
library(jsonlite)
library(magrittr)
library(data.table)
req <- curl("https://opendata.cwb.gov.tw/api/v1/rest/datastore/E-A0015-001?Authorization=YOUR_TOKEN_HERE") ##Replace with YOUR TOKEN!!
jt <- readLines(req, encoding = "latin1") %>% jsonlite::prettify() #%>% fromJSON()

dplyr::glimpse(fromJSON(jt, flatten=TRUE))

jx <- fromJSON(jt, flatten=TRUE)
xt <- jx$records$earthquake$intensity.shakingArea[[1]]$eqStation
dt <- rbindlist(xt)
dt
