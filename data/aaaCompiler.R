## Make the data set manuals in FSA and FSAdata into HTML pages
source("data/data-html/aaaMakeDataManHTML.R")

## Knit the listings files
library(rmarkdown)
render("data/CompleteList.Rmd")
render("data/byTopic.Rmd")
render("data/byPackage.Rmd")
