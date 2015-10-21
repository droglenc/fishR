##############################################################
##                                                          ##
## Use this to convert the data file related Rd files from  ##
##   the FSA and FSAdata packages into html files in the    ##
##   data-html directory.  This must be run to update the   ##
##   html files if anything is changed in FSA or FSAdata.   ##
##                                                          ##
## Some inspiration for this code came from                 ##
##    https://gist.github.com/richfitz/2656053              ##
##                                                          ##
##############################################################

library(tools)
library(stringr)

########### A little helper function #########################
## Clean up the definitions list for the variables
iClnHTMLDefns <- function(hf) {
  h <- readLines(hf)
  ## make some simple replacements in definitions list
  h <- str_replace(h,"<dl>","<ul>")
  h <- str_replace(h,"</dl>","</ul>")
  h <- str_replace(h,"<dt>","<li>")
  h <- str_replace(h,"</dt><dd><p>",": ")
  ## find the </dd> tags (on one line)
  tmp <- which(h=="</dd>")
  # replace the </p> with </li> on the lines before the </dd>
  h[tmp-1] <- str_replace(h[tmp-1],"</p>","</li>")
  # remove the </dd> tags
  h <- h[-tmp]
  ## write out the new html file
  writeLines(h,hf)
}

##############  FSAdata First ################################
## Get all .csv files in the data-raw directory of FSAdata
##   This should be all data-related files (i.e., will
##   ultimately not include things like the FSAdata.Rd file).
raw <- file_path_sans_ext(list.files(path="C:/aaaWork/Programs/GitHub/FSAdata/data-raw",pattern="*.csv"))

## Cycle through each Rd file to make html file
for (f in raw) {
  print(f)
  ## convert
  hf <- paste0("C:/aaaWork/Web/GitHub/fishR/data//data-html/",f,".html")
  Rd2HTML(paste0("C:/aaaWork/Programs/GitHub/FSAdata/man/",f,".Rd"),
          out=hf,package="FSAdata",stylesheet="aaaStyleSheet.css")
  iClnHTMLDefns(hf)
}

#################  FSA SECOND ################################
## Get all .csv files in the data-raw directory of FSA
##   This should be all data-related files (i.e., will
##   ultimately not include things like the FSA.Rd file).
raw <- file_path_sans_ext(list.files(path="C:/aaaWork/Programs/GitHub/FSA/data-raw",pattern="*.csv"))
## Exclude the two Lit files
raw <- raw[!grepl("lit",raw)]

## Cycle through each Rd file to make html file
for (f in raw) {
  print(f)
  ## convert
  hf <- paste0("C:/aaaWork/Web/GitHub/fishR/data/data-html/",f,".html")
  Rd2HTML(paste0("C:/aaaWork/Programs/GitHub/FSA/man/",f,".Rd"),
          out=hf,package="FSA",stylesheet="aaaStyleSheet.css")
  iClnHTMLDefns(hf)
}
