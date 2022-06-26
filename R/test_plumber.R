# test plumber to cast taxize function as API
library(plumber)
library(data.table)
library(magrittr)
library(taxize)

#* synonyms
#* @param q Query scientific name
#* @param db Query database
#* @get /sp
function(q, db='pow') {
  synonyms(q, db=db) %>% 
  .[q] %>% 
  as.data.table 
}