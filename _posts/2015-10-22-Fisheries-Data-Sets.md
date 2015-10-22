---
layout: post
title: Fisheries Data Sets
date: "October 22, 2015"
tags: [R, FSA, FSAdata, fishR, Data, Teaching]
---




A large number of small data sets are available in the [**FSA**](https://github.com/droglenc/FSA) and [**FSAdata**](https://github.com/droglenc/FSAdata) packages.  These data sets may be useful for demonstrating typical fisheries science analyses in an undergraduate or early graduate fisheries science and management course or if one is self-teaching how to perform these analyses.  Indeed, several of these data sets are used in the forthcoming [*Introductory Fisheries Analyses for R*](http://derekogle.com/IFAR/) book.

There are at least two problems with delivering these data sets within an R package that limits their pedagogical utility.  I describe these problems below and explain my solutions so that these data sets will be available to instructors in a more useful format, while still being maintained in R packages.

# First Problem

## Finding the Right Data Set

Finding the "right" data set in a package, especially packages like **FSAdata** that contain many data sets, can be difficult.  This problem is ameliorated somewhat by the ability to search all data sets in a package with `help.search()` using `package=` and `keyword="datasets"` (note that the result will appear in the Help pane if using RStudio or a browser if using R).

{% highlight r %}
help.search("otoliths",package=c("FSA","FSAdata"),keyword="datasets")
{% endhighlight %}

The data sets in the **FSA** and **FSAdata** packages have been augmented with specific topics in the "concepts" field of the help documentation that allow for a more focused search.  However, one needs to know which specific topics have been used (and their spelling).  Fortunately, these can be found with `FSAdataTopics`.

{% highlight r %}
library(FSAdata)
FSAdataTopics
{% endhighlight %}



{% highlight text %}
##  [1] "Length Expansion"  "Length Conversion" "Age Comparison"   
##  [4] "Age-Length Key"    "Back-Calculation"  "Weight-Length"    
##  [7] "Length Frequency"  "Size Structure"    "Capture-Recapture"
## [10] "Depletion"         "Removal"           "Mortality"        
## [13] "Growth"            "Recruitment"       "Maturity"         
## [16] "Other"
{% endhighlight %}

Thus, for example, one can find all data sets in **FSA** and **FSAdata** that are tagged with the `Age Comparison` concept using `help.search()` with `package=` and `fields="concept"`.

{% highlight r %}
help.search("Age Comparison",package=c("FSA","FSAdata"),fields="concept")
{% endhighlight %}

This is an improvement, but still a bit of a nuisance.

## A Solution

I have developed a **Data** page on the **fishR** website that lists all data sets in these two packages in these three different ways:

* [Complete alphabetical list](http://derekogle.com/fishR/data/CompleteList)
* [Categorized by major fisheries topic](http://derekogle.com/fishR/data/byTopic)
* [Categorized by R package](http://derekogle.com/fishR/data/byPackage)

The second of these lists is most useful because it allows one to easily see the analytical topics and each data set that can be used for that type of analysis.

Additionally, for each data set shown in these lists, there are icons that link to the data displayed in a spreadsheet-like format ([![view](../img/view.png)](https://github.com/droglenc/FSAdata/blob/master/data-raw/AlewifeLH.csv)), to the data as a raw comma-separated values (CSV) text file ([![download](../img/download.png)](https://raw.githubusercontent.com/droglenc/FSAdata/master/data-raw/AlewifeLH.csv)), and to meta-data documentation ([![documentation](../img/details.png)](http://derekogle.com/fishR/data/data-html/AlewifeLH.html)).  Click the icons in the previous sentence for examples.

# Second Problem

## Not the Real World

Data sets distributed with packages are loaded into the R workspace by including the name of the data set within `data()`.  For example, the `AlewifeLH` data set distributed with the **FSAdata** package is loaded and its structure is examined below.

{% highlight r %}
library(FSAdata)
data(AlewifeLH)
str(AlewifeLH)
{% endhighlight %}



{% highlight text %}
## 'data.frame':	104 obs. of  2 variables:
##  $ otoliths: int  0 0 1 1 1 1 1 1 1 1 ...
##  $ scales  : int  0 0 0 1 1 1 1 1 1 1 ...
{% endhighlight %}

The problem here is that the only time a student will ever use `data()` is if the data set exists within an R package.  The student will not use `data()` when they analyze their own data.  Thus, the student gets no experience with the critical step of loading one's own data into R.


## A Solution

The raw CSV files that are linked to in the lists described in the first solution are particular useful here because a student can download this file to their computer and then use `read.csv()` (or any of the other functions that can be used to load CSV files) to load the data into their R workspace.  This more closely resembles a workflow that the student is likely to use with their own data.

It is also possible to read the CSV file directly from the webpage.

{% highlight r %}
df <- read.csv("https://raw.githubusercontent.com/droglenc/FSAdata/master/data-raw/AlewifeLH.csv")
str(df)
{% endhighlight %}



{% highlight text %}
## 'data.frame':	104 obs. of  2 variables:
##  $ otoliths: int  0 0 1 1 1 1 1 1 1 1 ...
##  $ scales  : int  0 0 0 1 1 1 1 1 1 1 ...
{% endhighlight %}

This may not be particularly useful because the address is so long (it can, however, be copied from the download icon in the lists) and the student is unlikely to have stored their own data at an internet site.

# The Future

My hope is that you and others will submit small data sets to me that I can include in the **FSAdata** package and on the **fishR** Data page so that others may use these data in their classes.  With this, perhaps a compendium of pedagogically useful fisheries-related data sets can be constructed.
