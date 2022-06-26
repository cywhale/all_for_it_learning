#cast R function as API
library(plumber)
library(magrittr)
# 'test_plumber.R' is the location of the file shown above
pr("test_plumber.R") %>%
  pr_run(port=8000)

