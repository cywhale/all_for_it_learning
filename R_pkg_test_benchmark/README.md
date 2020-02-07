# simple-test-bigmemory
Simple tests for bigmemory package, compared to data.table, RPostgreSQL, also som trials for future usage

Orignally shared at 20160722:  
https://www.ptt.cc/bbs/R_Language/M.1469160184.A.266.html

The description was written mainly in Chinese. You can just try the code in [simple_test_bigmemory01.R] (https://github.com/cywhale/simple-test-bigmemory/blob/master/simple_test_bigmemory01.R)

1. 套件名稱：

bigmemory 4.5.19

2. 套件主要用途：

處理較吃記憶體的資料，尤其當資料大小逼近或超過實體記憶體，使load資料很慢時..
但資料限定為單一資料型態，不能同時混雜character, numeric
它這種資料結構 big.matrix 其實只是一個 R object但實際指向 C++資料結構的指標
可以memory或檔案形式 share (shared.big.matrix, filebacked.big.matrix)，實現
在 multiple processes or cluster共用的機制

可以做簡單的資料操作，如取符合條件的子集合資料出來
配合其他 big 系列的套件如 biganalytics, bigtabulate等做其他處理、modeling

3. 套件主要函數列表：

a. read.big.matrix: 讀取一份.csv 並創建成file-backing形式的big.matrix
                    格式比如
   read.big.matrix("test.csv", header = TRUE,
                      type = "double",
                      backingfile = "test.bin",
                      descriptorfile = "test.des"))
   你提供test.csv, 執行後會多兩個供bigmemory使用的descriptorfile .bin, .des

b. attach.big.matrix: 讀取一份 file-backing big.matrix的descriptor file，
                      提供套件可以抓到這個 big.matrix object所需的資訊

c. mwhich: 如同base所提供的which，可以對各欄位做篩選

d. write.big.matrix: 將 big.matrix object寫入 file


4. 分享內容：

之前看一些朋友發問有較大容量資料要吃進來，而絕大部分都可以由data.table套件的
fread解決。

bigmemory處理資料當然沒有data.table又快又方便，但它有個好處，就是一開始只放
資料的記憶體指標，不會把所有資料都放進記憶體。
所以我把它應用在網路server上需要供人查詢的較大筆資料（如shiny建構的查詢介面）
資料本身較少更動，而供公眾使用的linux server資源不多（有時VM只開4GB）
當我把資料備妥(.csv），先建好file-backing方式所需要的descriptor file，
之後只要attach上去，資料就可以在web-based application中讀取到。
使用者以介面查詢、篩選資料範圍，透過 mwhich 方式縮小真正載入記憶體的資料大小，
再轉換到data.table做其他運算。

所以我用bigmemory的方式、函數超簡單：attach %>% mwhich (%>% data.table())

這也能用資料庫完成，但上述流程可能比 (connect Database -> SQL query -> return
query)來得快一點（後有簡單測試）

但如果資料本身常常更新，或資料各欄位型態複雜，資料庫有它難以取代的優勢。
bigmemory也可以 write, flush，但我本身很少用它，我主要應用在一份很大的歷史資料
(數值資料，少更動)，這當然僅只是個人選擇。

bigmemory另一個不錯的優點也在於它和Rcpp(, RcppArmadillo..)等的配合，比如這個
簡單清楚的例子
http://www.r-bloggers.com/using-rcpparmadillo-with-bigmemory/

其他應用或參考資料 可在R-blogger上搜尋 bigmemory
另外google 這份文件也頗有參考價值，雖然已是2010年...
Taking R to the Limit, Part II: Working with Large Datasets

5. 備註

沒有特別分享到什麼bigmemory套件高深功能，只是拋磚引玉，自己也有困惑~~ 
也許data欄位不能mixed-type 某方面侷限了它的發展，bigmemory
在網路的討論度很低，但套件作者默默在維持、不時小更新，只是未來的發展走向不明。
不知道它在愈來愈多更快、更方便的資料處理套件選擇下，未來性如何??~~

bigmemory只是R資料處理中的其一選擇，小小心得供參，也請多多指教，更希望引來
有趣的其他應用或使用方式~
