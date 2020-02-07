The general problems in R which I had ever responsed... 
#### 20171221 HOW to avoid write private information in your code? Asked in ptt: https://goo.gl/AMjDWi
keyword: **shiny** 
1. 有一些方式可以避掉在code中明碼寫password, key, or other private information
* 最簡單一種寫在.Rprofile 一開始就會load進去 你在code 裡面就只要寫assign password的變數名即可
* 詳細做法可參考: <a href=https://goo.gl/AFZjRB>How to store and use webservice keys and authentication details with R</a>

2. 自己在做應用時，另外發現包在 sysdata.rda 這一招不錯. Write your private information into sysdata.rda, included in a self-used, small package.
* 參考 Hadley http://r-pkgs.had.co.nz/data.html then, your private data will be used internally, and in binary format.


