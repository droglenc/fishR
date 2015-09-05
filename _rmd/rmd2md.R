#' This R script will process a R mardown files in the current working directory to a markdown file to be placed in the '_posts' directory and figures to be placed in the 'figures' directory.
#' @param file A base filename without an extension (assumed to be '.Rmd').
#' @param path_site Path to the local root storing the site files.
#' @return nothing.
#' @author I heavily modified the code provided by Andy South (http://andysouth.github.io/blog-setup/) who modified the code of Jason Bryer
#' @example
#' rmd2md("2015-09-05-Age-Comparison-Results-for-Individual-Fish")
#'
rmd2md <- function(file,path_site="C:/aaaWork/Web/GitHub/fishR") {
  ## Get knitr
  require(knitr, quietly=TRUE, warn.conflicts=FALSE)
  ## Read in the rmd file
  content <- readLines(file.path(path_site,"_rmd",paste0(file,".Rmd")))
  ## Create output file name
  outFile <- file.path(path_site,"_posts",paste0(file,".md"))
  ## Set the rendering engine
  render_jekyll(highlight = "pygments")
  ## Set the output format to markdown
  opts_knit$set(out.format='markdown')
  ## Set the directory for the figures
  opts_knit$set(base.url = "../",base.dir=path_site)
  opts_chunk$set(fig.path = "figures/")
  ## Actually knit the RMD file
  knit(text=content, output=outFile)
  invisible()
}
