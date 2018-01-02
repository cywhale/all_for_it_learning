#LTN #自由時報 #新聞 #爬蟲 #WebCrawling #時間軸

library(rvest)
library(magrittr)
library(data.table)

url  <- "http://news.ltn.com.tw/search/?keyword=保育&conditions=and&SYear=2017&SMonth=11&SDay=1&EYear=2017&EMonth=12&EDay=31"

list <- read_html(url) %>%  html_nodes('.tit') 

link <- list %>% html_attr('href') 
title<- list %>% html_attr('data-desc') %>% gsub("^T:(?:[0-9]{1,}):|<\\/{0,}(.*?)>","",.)

data <- 
  rbindlist(
    lapply(seq_along(link), function(x, link, title) {
      ctentx<- read_html(paste0("http://news.ltn.com.tw/",link[x])) %>% 
        html_nodes(".articlebody") 
      
      if (length(ctentx)==0) {
        ctentx<- read_html(paste0("http://news.ltn.com.tw/",link[x])) %>% 
          html_nodes(".cont")
        
        if (length(ctentx)==0) {
          return(
            list(title=title[x], link=paste0("http://news.ltn.com.tw/",link[x]),
                 content="Warning: Cannot read content!")
          )
        }
      }
      
  
      ctentx %<>% html_text() %>%
        gsub("(\\$|return|googletag.cmd.push|function|\\)\\;)(.*?)(?:\\)\\;|return(.*?)\\)\\;)\n{1,}","\n",.) %>% gsub("\n(?:\t{1,}|\t{0,}return(.*?)\\)\\;)|\\}\\);","\n",.) %>%
        gsub("\n{2,}","\n",.)
  
      Sys.sleep(runif(1,1.5,5))
      
      list(title=title[x], link=paste0("http://news.ltn.com.tw/",link[x]),
           content=ctentx)
      
    }, link=link, title=title)
  )

data[1,]
#title
#1: 今年第8起！西濱公路後龍段公石虎疑遭路殺
#link
#1: http://news.ltn.com.tw/news/life/breakingnews/2298777
#content
#1: \n今年第8起！西濱公路後龍段公石虎疑遭路殺\n苗栗縣西濱公路後龍段，發現石虎疑被路殺，將解剖進一步確認。（圖擷取臉書竹南大小事）\n2017-12-31 13:01\n〔記者張勳騰／苗栗報導〕苗栗縣楊姓騎士今天在西濱快速道路後龍鎮中和段，發現一隻保育類石虎疑似被路殺，苗栗縣政農業處人員隨即到場處理，發現是公石虎，這是苗栗縣今年第8起石虎被路殺，全國則是第13起。由於最近後龍地區發生多起山林火警，台灣石虎保育協會理事長陳美汀認為，應有間接關係。苗栗縣農業處自然生態保育科人員在上午10點多會同苗栗縣特有生物保育協會等單位人員前往處理，發現這隻重4.2公斤的公石虎，無明顯外傷，但肛門有出血情形，為路殺的症狀。苗栗縣農業處自然生態保育科人員說，這隻石虎遺體，將送國立屏東科技大學採樣，確定是否是路殺，然後再送往台中科學博物館製成標本。由於後龍地區最近發現多起山林火警，地方人士懷疑這起路殺與山林火警有關。台灣石虎保育協會理事長陳美汀說，這起石虎死亡案，仍須進一步解剖確認死因。一般而言，山林火警及山林開發，因石虎原有棲地被破壞，獵物及躲避的空間減少，石虎被迫暫時須穿越馬路到另一區塊覓食，可能因此造成石虎被路殺。\n相關關鍵字：\n山林火警\n石虎\n路殺\n
