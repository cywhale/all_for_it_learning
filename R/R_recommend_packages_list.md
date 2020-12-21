The recommended packages, will be updated if I discuss with somebody else... 
#### 20171214 with Dr. David Zeleny, related blog: https://goo.gl/n9THmZ

1. For data IO and wrangling, if you care about speed and memory used, try **data.table** package. 
* To see the difference between **data.table** and **dplyr**, you can check https://goo.gl/ycQDQ3 

2. For visualization, **ggplot2** is great to use and easy to integrate with **tidyverse** packages. 
* Indeed, base plot and **lattice** can do most of the work ggplot can. But as the plots get more complicated, **ggplot2** still can keep its simplicity because its consistency in coding style. 
* You can easily treat it as an overall workflow for pipe (**magrittr**) operator, and also **tideverse**. There are also many wonderful packages or extensions for ggplot2, such as **ggrepel**, **ggplotly**, and so on. 
* Check **ggrepel** if you need many labels or annotations in your plot: https://cran.r-project.org/....../vignettes/ggrepel.html
* Check **ggplotly** graph library: https://plot.ly/ggplot2/

3. If you're interested in handling GIS data, **sf** package is a new version based on older **sp** package. 
* Check https://r-spatial.github.io/sf/articles/sf1.html

#### 20200511 Woth reading and re-thinking: TidyverseSkeptic by Dr. Norm Matloff

1. github: [TidyverseSkeptic](https://github.com/matloff/TidyverseSkeptic])

2. A benchmark about base-R, tidyverse/readr, data.table::fread, vroom, and serializing data by base-R(RDS), fst, feather package, please see [Speeding up Reading and Writing in R](https://www.danielecook.com/speeding-up-reading-and-writing-in-r/) by Daniel E. Cook 
