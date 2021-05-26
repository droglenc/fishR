---
title: "Replace filterD()"
layout: post
date: "May 26, 2021"
output:
  html_document
tags:
- R
- FSA

---




----

We are deprecating `filterD()` from the next version of FSA (v0.9.0). It will likely be removed by the start of 2022. `filterD()` was an attempt to streamline the process of using `filter()` (from `dplyr`) followed by `droplevels()` to remove levels of a factor variable that no longer existed in the filtered data frame.

For example, consider the very simple data frame below.


{% highlight r %}
d <- data.frame(tl=runif(6,min=100,max=200),
                spec=factor(c("LMB","LMB","SMB","BG","BG","BG")))
d
{% endhighlight %}



{% highlight text %}
##         tl spec
## 1 120.8437  LMB
## 2 112.9690  LMB
## 3 126.4658  SMB
## 4 118.9474   BG
## 5 140.0974   BG
## 6 135.2961   BG
{% endhighlight %}

Now suppose that this data frame is reduced to just Bluegill.


{% highlight r %}
dbg <- dplyr::filter(d,spec=="BG")
{% endhighlight %}

A quick frequency table of species caught shows that levels for species that no longer exist in the data frame are maintained.


{% highlight r %}
xtabs(~spec,data=dbg)
{% endhighlight %}



{% highlight text %}
## spec
##  BG LMB SMB 
##   3   0   0
{% endhighlight %}

This same "problem" occurs when using `subset()` from base R.


{% highlight r %}
dbg <- subset(d,spec=="BG")
xtabs(~spec,data=dbg)
{% endhighlight %}



{% highlight text %}
## spec
##  BG LMB SMB 
##   3   0   0
{% endhighlight %}

These "problems" can be eliminated by submitting the new data frame to `drop.levels()`.


{% highlight r %}
dbg2 <- droplevels(dbg)
xtabs(~spec,data=dbg2)
{% endhighlight %}



{% highlight text %}
## spec
## BG 
##  3
{% endhighlight %}

`filterD()` was a simple work-around that eliminated this second step and was useful for helping students who were just getting started with R.


{% highlight r %}
dbg3 <- FSA::filterD(d,spec=="BG")
xtabs(~spec,data=dbg3)
{% endhighlight %}



{% highlight text %}
## spec
## BG 
##  3
{% endhighlight %}

However, this is a hacky solution to a simple problem. Thus, we are deprecating `filterD()` from `FSA` with plans to remove it by the beginning of next year. Thus, please use `droplevels()` (or `fct_drop()` from `forcats`) after using `filter()` to accomplish the same task of the soon to be defunct `filterD()`.
