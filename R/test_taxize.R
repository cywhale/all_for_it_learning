#test rOpenSci/taxize
library(data.table)
library(magrittr)
library(taxize)
# Getting taxonomic synonyms -> synonyms
synonyms('Castanopsis carlesii', db='pow') %>% 
  .$`Castanopsis carlesii` %>% 
  as.data.table %>%.[]

# Getting taxonomic hierarchies -> classification()
test_sp <- c("Creseis conica", "Abudefduf saxatilis", 
             "Labidocera gallensis", "Metridia macrura", 
             "Metridia asymmetrica", "Acartia hongi")
taxt <- taxize::classification(test_sp, 
                               db=c("gbif"),
                               accepted = TRUE, row = 1L)
out <- setDT(cbind(taxt))

## comapre with taxizedb::classification, but why 'gbif' got no data??
library(taxizedb)
tax2 <- taxizedb::classification(test_sp, db=c("ncbi")) #first load is very slow
#db=c("itis") got Error (while 'gbif' no data)
#Error in curl::curl_download(db_url, db_path, quiet = TRUE) : 
#  transfer closed with 106031400 bytes remaining to read
# not work... but using default 'ncbi' is ok, lacks some species data

#taxize::cbind cannot handle no data, it must be manually handled
#$`Labidocera gallensis`
#[1] NA
#
#$`Metridia macrura`
#[1] NA





