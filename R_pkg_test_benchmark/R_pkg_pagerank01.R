## Finding the essential R packages using the pagerank algorithm by Andrie de Vries
## source: https://blog.revolutionanalytics.com/2014/12/a-reproducible-r-example-finding-the-most-popular-packages-using-the-pagerank-algorithm.html
## https://twitter.com/opencpu/status/1259818138327224321/photo/1

## Analyze R packages for popularity, using pagerank algorithm

# Inspired by Antonio Piccolboni, http://piccolboni.info/2012/05/essential-r-packages.html

library(miniCRAN)
library(igraph)
library(magrittr)


# Download matrix of available packages at specific date ------------------
# https://mran.revolutionanalytics.com/snapshot/
#MRAN<- "http://mran.revolutionanalytics.com/snapshot/2014-11-01/"
MRAN <- "http://mran.revolutionanalytics.com/snapshot/2020-05-11/"

pdb <- MRAN %>%
  contrib.url(type = "source") %>%
  available.packages(type="source", filters = NULL)


# Use miniCRAN to build a graph of package dependencies -------------------

# Note that this step takes a while, expect ~15-30 seconds

g <- pdb[, "Package"] %>%
  makeDepGraph(availPkgs = pdb, suggests=FALSE, enhances=TRUE, includeBasePkgs = FALSE)


# Use the page.rank algorithm in igraph -----------------------------------

pr <- g %>%
  page.rank(directed = FALSE) %>%
  use_series("vector") %>%
  sort(decreasing = TRUE) %>%
  as.matrix %>%
  set_colnames("page.rank")


# Display results ---------------------------------------------------------

head(pr, 25)


# build dependency graph of top packages ----------------------------------

set.seed(42)
pr %>%
  head(25) %>%
  rownames %>%
  makeDepGraph(pdb) %>%
  plot(main="Top packages by page rank", cex=0.5)

