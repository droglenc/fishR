---
title: "Adding Zero Catches"
layout: post
date: "April 19, 2018"
output:
  html_document
tags:
- R
- data_wrangling

---




----

## Introduction

Much of my work is with undergraduates who are first learning to analyze fisheries data. A common "learning opportunity" occurs when students are asked to compute the mean catch (or CPE), along with a standard deviation (SD), across multiple gear sets for each species. The learning opportunity occurs because some species will invariably not be caught in some gear sets. When the students summarize the number of fish caught for each species in each gear set those species not caught in a particular gear set will not "appear" in their data. Thus, when calculating the mean, the student will get the correct numerator (sum of catch across all gear sets) but not denominator (they use number of catches summed rather than total number of gear sets), which inflates (over-estimates) the mean catch and (usually) deflates (under-estimates) the SD of catches. Once confronted with this issue, they easily realize how to correct the mean calculation, but calculating the standard deviation is still an issue. These problems are exacerbated when using software to compute these summary statistics across many individual gear sets.

In software, the "trick" is to add a zero for each species not caught in a specific gear set that was caught in at least one of all of the gear sets. For example, if Bluegill were caught in at least one gear set but not in the third gear set, then a zero must be added as the catch of Bluegill in the third gear set. The `addZeroCatch()` function in the `FSA` package was an attempt to efficiently add these zeroes. This function has proven useful over the years, but I have become dissatisfied with its clunkiness. Additionally, I recently became aware of the `complete()` function in the `tidyr` package which holds promise for handling the same task. In this post, I explore the use of `complete()` for handling this issue.

This post requires the `dplyr` and `tidyr` packages. It also uses `FSA` behind the scenes.


{% highlight r %}
library(FSA)      # for mapvalues()
library(dplyr)    # for %>%, group_by(), summarize(), mutate(), right_join()
library(tidyr)    # for complete(), nesting()
{% endhighlight %}


\  

----

## Example 1 - Very Simple Data
In this first example, the data consists of `species` and `length` recorded for each captured fish organized by the gear set identification number (`ID`) and held in the `fishdat` data.frame.


{% highlight r %}
head(fishdat)
{% endhighlight %}



{% highlight text %}
##   ID species  tl
## 1  1     BLG 148
## 2  1     BLG 153
## 3  1     BLG 147
## 4  1     BLG 149
## 5  1     BLG 144
## 6  1     BLG 145
{% endhighlight %}

The catch of each species in each gear set may be found using `group_by()` and `summarize()` with `n()`. Note that `as.data.frame()` is used simply to remove the `tibble` structure returned by `group_by()`.[^tibbleannoyance]

{% highlight r %}
catch <- fishdat %>%
  group_by(ID,species) %>%
  summarize(num=n()) %>%
  as.data.frame()
catch
{% endhighlight %}



{% highlight text %}
##    ID species num
## 1   1     BLG  10
## 2   1     LMB   5
## 3   1     YEP   5
## 4   2     LMB   9
## 5   2     YEP   7
## 6   3     BLG  12
## 7   3     YEP   7
## 8   4     BLG   1
## 9   4     LMB  11
## 10  4     YEP  11
## 11  5     BLG   9
{% endhighlight %}

From this it is seen that three species ("BLG", "LMB", and "YEP") were captured in all nets, but that "BLG" were not captured in "ID=2", "LMB" were not captured in "ID=3", and "LMB" and "YEP" were not captured in "ID=5". The sample size, mean, and SD of catches per species from these data may be found by again using `group_by()` and `summarize()`. However, note that these calculations are **INCORRECT** because they do not include the zero catches of "BLG" in "ID=2", "LMB" in "ID=3", and "LMB" and "YEP" in "ID=5". The problem is most evident in the sample sizes, which should be five (gear sets) for each species.

{% highlight r %}
## Example of INCORRECT summaries because not using zeroes
catch %>% group_by(species) %>%
  summarize(n=n(),mn=mean(num),sd=sd(num)) %>%
  as.data.frame()
{% endhighlight %}



{% highlight text %}
##   species n       mn       sd
## 1     BLG 4 8.000000 4.830459
## 2     LMB 3 8.333333 3.055050
## 3     YEP 4 7.500000 2.516611
{% endhighlight %}

The `complete()` function can be used to add rows to a data.frame for variables (or combinations of variables) that should be present in the data.frame (relative to other values that are present) but are not. The `complete()` function takes a data.frame as its first argument (but will be "piped" in below with `%>%`) and the variable or variables that will be used to identify which items are missing. For example, with these data, a zero should be added to `num` for missing combinations defined by `ID` and `species`.

{% highlight r %}
## Example of default complete ... see below to add zeroes, not NAs
catch %>% complete(ID,species) %>%
  as.data.frame()
{% endhighlight %}



{% highlight text %}
##    ID species num
## 1   1     BLG  10
## 2   1     LMB   5
## 3   1     YEP   5
## 4   2     BLG  NA
## 5   2     LMB   9
## 6   2     YEP   7
## 7   3     BLG  12
## 8   3     LMB  NA
## 9   3     YEP   7
## 10  4     BLG   1
## 11  4     LMB  11
## 12  4     YEP  11
## 13  5     BLG   9
## 14  5     LMB  NA
## 15  5     YEP  NA
{% endhighlight %}

From this result, it is seen that `complete()` added a row for "BLG" in "ID=2", "LMB" in "ID=3", and "LMB" and "YEP" in "ID=5", as we had hoped. However, `complete()` adds `NA`s by default. The value to add can be changed with `fill=`, which takes a list that includes the name of the variable to which the `NA`s were added (`num` in this case) set equal to the value to be added (`0` in this case).

{% highlight r %}
catch <- catch %>%
  complete(ID,species,fill=list(num=0)) %>%
  as.data.frame()
catch
{% endhighlight %}



{% highlight text %}
##    ID species num
## 1   1     BLG  10
## 2   1     LMB   5
## 3   1     YEP   5
## 4   2     BLG   0
## 5   2     LMB   9
## 6   2     YEP   7
## 7   3     BLG  12
## 8   3     LMB   0
## 9   3     YEP   7
## 10  4     BLG   1
## 11  4     LMB  11
## 12  4     YEP  11
## 13  5     BLG   9
## 14  5     LMB   0
## 15  5     YEP   0
{% endhighlight %}

These correct catch data can then be summarized as above to show the correct sample size, mean, and SD of catches per species.

{% highlight r %}
catch %>% group_by(species) %>%
  summarize(n=n(),mn=mean(num),sd=sd(num)) %>%
  as.data.frame()
{% endhighlight %}



{% highlight text %}
##   species n  mn       sd
## 1     BLG 5 6.4 5.504544
## 2     LMB 5 5.0 5.049752
## 3     YEP 5 6.0 4.000000
{% endhighlight %}

\  

\  

----

## Example 2 - Multiple Values to Receive Zeroes
Suppose that the fish data included a column that indicates whether the fish was marked and returned to the waterbody or not.


{% highlight r %}
head(fishdat2)
{% endhighlight %}



{% highlight text %}
##   ID species  tl marked
## 1  1     BLG 148    YES
## 2  1     BLG 153    YES
## 3  1     BLG 147     no
## 4  1     BLG 149     no
## 5  1     BLG 144     no
## 6  1     BLG 145     no
{% endhighlight %}

The catch and number of fish marked and returned per gear set ID and species may again be computed with `group_by()` and `summarize()`. Note, however, the use of `ifelse()` to use a `1` if the fish was marked and a `0` if it was not. Summing these values returns the number of fish that were marked. Giving this data.frame to `complete()` as before will add zeroes for both the `num` and `nmarked` variables as long as both are included in the list given to `fill=`.

{% highlight r %}
catch2 <- fishdat2 %>%
  group_by(ID,species) %>%
  summarize(num=n(),
            nmarked=sum(ifelse(marked=="YES",1,0))) %>%
  complete(ID,species,fill=list(num=0,nmarked=0)) %>%
  as.data.frame()
catch2
{% endhighlight %}



{% highlight text %}
##    ID species num nmarked
## 1   1     BLG  10       2
## 2   1     LMB   5       2
## 3   1     YEP   5       3
## 4   2     BLG   0       0
## 5   2     LMB   9       6
## 6   2     YEP   7       2
## 7   3     BLG  12       4
## 8   3     LMB   0       0
## 9   3     YEP   7       6
## 10  4     BLG   1       0
## 11  4     LMB  11       5
## 12  4     YEP  11       8
## 13  5     BLG   9       4
## 14  5     LMB   0       0
## 15  5     YEP   0       0
{% endhighlight %}

\  

\  

----

## Example 3 - More Information that Does Not Get Zeroes
Suppose that a data.frame called `geardat` contains information specific to each gear set.


{% highlight r %}
geardat
{% endhighlight %}



{% highlight text %}
##   ID mon year  lake run effort
## 1  1 May 2018 round   1   1.34
## 2  2 May 2018 round   2   1.87
## 3  3 May 2018 round   3   1.56
## 4  4 May 2018  twin   1   0.92
## 5  5 May 2018  twin   2   0.67
{% endhighlight %}

And, for the purposes of this example, let's suppose that we have summarized catch data WITHOUT the zeroes having been added.

{% highlight r %}
catch3 <- fishdat2 %>%
  group_by(ID,species) %>%
  summarize(num=n(),
            nmarked=sum(ifelse(marked=="YES",1,0))) %>%
  as.data.frame()
catch3
{% endhighlight %}



{% highlight text %}
##    ID species num nmarked
## 1   1     BLG  10       2
## 2   1     LMB   5       2
## 3   1     YEP   5       3
## 4   2     LMB   9       6
## 5   2     YEP   7       2
## 6   3     BLG  12       4
## 7   3     YEP   7       6
## 8   4     BLG   1       0
## 9   4     LMB  11       5
## 10  4     YEP  11       8
## 11  5     BLG   9       4
{% endhighlight %}

Finally, suppose that these summarized catch data are joined with the gear data such that the gear set specific information is shown with each catch.

{% highlight r %}
catch3 <- right_join(geardat,catch3,by="ID")
catch3
{% endhighlight %}



{% highlight text %}
##    ID mon year  lake run effort species num nmarked
## 1   1 May 2018 round   1   1.34     BLG  10       2
## 2   1 May 2018 round   1   1.34     LMB   5       2
## 3   1 May 2018 round   1   1.34     YEP   5       3
## 4   2 May 2018 round   2   1.87     LMB   9       6
## 5   2 May 2018 round   2   1.87     YEP   7       2
## 6   3 May 2018 round   3   1.56     BLG  12       4
## 7   3 May 2018 round   3   1.56     YEP   7       6
## 8   4 May 2018  twin   1   0.92     BLG   1       0
## 9   4 May 2018  twin   1   0.92     LMB  11       5
## 10  4 May 2018  twin   1   0.92     YEP  11       8
## 11  5 May 2018  twin   2   0.67     BLG   9       4
{% endhighlight %}

These data simulate what might be seen from a flat database.

With these data, zeroes still need to be added as defined by missing combinations of `ID` and `species`. However, if only these two variables are included in `complete()` then `NA`s, zeroes, or something else (if we define that) will be added `mon`, `year`, `lake`, `run`, and `effort`, which is not desired. These five variables are "nested" with the `ID` variable (i.e., if you know `ID` then you know these variables) and should be treated as a group. Nesting of variables can be handled in `complete()` by including these variables within `nesting()`.

{% highlight r %}
catch3 %>% complete(nesting(ID,mon,year,lake,run,effort),species,
                    fill=list(num=0,nmarked=0)) %>%
  as.data.frame()
{% endhighlight %}



{% highlight text %}
##    ID mon year  lake run effort species num nmarked
## 1   1 May 2018 round   1   1.34     BLG  10       2
## 2   1 May 2018 round   1   1.34     LMB   5       2
## 3   1 May 2018 round   1   1.34     YEP   5       3
## 4   2 May 2018 round   2   1.87     BLG   0       0
## 5   2 May 2018 round   2   1.87     LMB   9       6
## 6   2 May 2018 round   2   1.87     YEP   7       2
## 7   3 May 2018 round   3   1.56     BLG  12       4
## 8   3 May 2018 round   3   1.56     LMB   0       0
## 9   3 May 2018 round   3   1.56     YEP   7       6
## 10  4 May 2018  twin   1   0.92     BLG   1       0
## 11  4 May 2018  twin   1   0.92     LMB  11       5
## 12  4 May 2018  twin   1   0.92     YEP  11       8
## 13  5 May 2018  twin   2   0.67     BLG   9       4
## 14  5 May 2018  twin   2   0.67     LMB   0       0
## 15  5 May 2018  twin   2   0.67     YEP   0       0
{% endhighlight %}

It is possible to have nesting with `species` as well. Suppose, for example, that the scientific name for the species was included in the original `fishdata2` that was summarized (using a combination of the examples from above, but not shown here) to `catch4`.


{% highlight r %}
catch4
{% endhighlight %}



{% highlight text %}
##    ID mon year  lake run effort species                spsci num nmarked
## 1   1 May 2018 round   1   1.34     BLG  Lepomis macrochirus  10       2
## 2   1 May 2018 round   1   1.34     LMB Micropterus dolomieu   5       2
## 3   1 May 2018 round   1   1.34     YEP     Perca flavescens   5       3
## 4   2 May 2018 round   2   1.87     LMB Micropterus dolomieu   9       6
## 5   2 May 2018 round   2   1.87     YEP     Perca flavescens   7       2
## 6   3 May 2018 round   3   1.56     BLG  Lepomis macrochirus  12       4
## 7   3 May 2018 round   3   1.56     YEP     Perca flavescens   7       6
## 8   4 May 2018  twin   1   0.92     BLG  Lepomis macrochirus   1       0
## 9   4 May 2018  twin   1   0.92     LMB Micropterus dolomieu  11       5
## 10  4 May 2018  twin   1   0.92     YEP     Perca flavescens  11       8
## 11  5 May 2018  twin   2   0.67     BLG  Lepomis macrochirus   9       4
{% endhighlight %}

The zeroes are then added to this data.frame making sure to note the nesting of `species` and `spsci`.

{% highlight r %}
catch4 %>% complete(nesting(ID,mon,year,lake,run,effort),
                    nesting(species,spsci),
                    fill=list(num=0,nmarked=0)) %>%
  as.data.frame()
{% endhighlight %}



{% highlight text %}
##    ID mon year  lake run effort species                spsci num nmarked
## 1   1 May 2018 round   1   1.34     BLG  Lepomis macrochirus  10       2
## 2   1 May 2018 round   1   1.34     LMB Micropterus dolomieu   5       2
## 3   1 May 2018 round   1   1.34     YEP     Perca flavescens   5       3
## 4   2 May 2018 round   2   1.87     BLG  Lepomis macrochirus   0       0
## 5   2 May 2018 round   2   1.87     LMB Micropterus dolomieu   9       6
## 6   2 May 2018 round   2   1.87     YEP     Perca flavescens   7       2
## 7   3 May 2018 round   3   1.56     BLG  Lepomis macrochirus  12       4
## 8   3 May 2018 round   3   1.56     LMB Micropterus dolomieu   0       0
## 9   3 May 2018 round   3   1.56     YEP     Perca flavescens   7       6
## 10  4 May 2018  twin   1   0.92     BLG  Lepomis macrochirus   1       0
## 11  4 May 2018  twin   1   0.92     LMB Micropterus dolomieu  11       5
## 12  4 May 2018  twin   1   0.92     YEP     Perca flavescens  11       8
## 13  5 May 2018  twin   2   0.67     BLG  Lepomis macrochirus   9       4
## 14  5 May 2018  twin   2   0.67     LMB Micropterus dolomieu   0       0
## 15  5 May 2018  twin   2   0.67     YEP     Perca flavescens   0       0
{% endhighlight %}

\  

\  

----

## Comments

This is my first explorations with `complete()` and it looks promising for this task of adding zeroes to data frames of catch by gear set for gear sets in which a species was not caught. I will be curious to hear what others think of this function and how it might fit in their workflow.

\  

\  

----

## Footnotes

[^tibbleannoyance]: I find the tibble structure to be annoying with simple data.frames like this. Thus, I usually use `as.data.frame()` to remove it.
