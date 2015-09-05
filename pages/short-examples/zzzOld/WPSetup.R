# Load RWordPress and knitr
library(RWordPress)
library(knitr)


# Set some knitr options
opts_knit$set(base.url = "http://dl.dropboxusercontent.com/u/65171428/fishr/figure/",
              base.dir = "C:/Users/dogle/Dropbox/Public/fishr/figure/")


# THIS DOES NOT WORK -- HOW COME
# opts_chunk$set(prompt=TRUE, comments=NA)

#knit_hooks$set(
#  input = function(x,options) paste('[sourcecode language="r"',x,'[/sourcecode]',sep='')
#  output = function(x,options) paste('<pre>\n',x,'</pre>\n',sep='')
#)

# Set some R options to use WordPress
options(WordpressLogin=c(dogle="Elgomik1"),
        WordpressURL="http://fishr.wordpress.com/xmlrpc.php")


