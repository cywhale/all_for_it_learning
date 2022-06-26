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
out <- data.table(cbind(taxt)) %>% .[]

