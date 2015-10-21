## Make the data set manuals in FSA and FSAdata into HTML pages
source("data/data-html/aaaMakeDataManHTML.R")

## Knit the listings files
library(knitr)
render_jekyll(highlight = "pygments")
opts_knit$set(out.format='markdown')
source("data/Rmd/zzzListScriptInit.R")
knit(text=readLines("data/Rmd/CompleteList.Rmd"), output="data/CompleteList.md")
knit(text=readLines("data/Rmd/byTopic.Rmd"), output="data/byTopic.md")
knit(text=readLines("data/Rmd/byPackage.Rmd"), output="data/byPackage.md")
