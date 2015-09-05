#' This R script will process a R mardown files in the current working directory to a markdown file to be placed in the '_posts' directory and figures to be placed in the 'figures' directory.
#' @param file A base filename without an extension (assumed to be '.Rmd').
#' @param path_site Path to the local root storing the site files.
#' @return nothing.
#' @author Jason Bryer <jason@bryer.org> edited by Andy South and by Derek Ogle
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
  ## Set the directory for the figures ... BEWARE ... don't set
  ## base.dir!! it caused problems because "base.dir is never
  ## used when composing the URL of the figures; it is only
  ## used to save the figures to a different directory.  The
  ## URL of an image is always base.url + fig.path.
  ## See https://groups.google.com/forum/#!topic/knitr/18aXpOmsumQ
#  opts_knit$set(base.url = "/")
  opts_chunk$set(fig.path = "../figures/")
  ## Actually knit the RMD file
  knit(text=content, output=outFile)
  invisible()
}
