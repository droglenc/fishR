---
title: "Collapsing Categories or Values"
layout: post
date: "March 30, 2018"
output:
  html_document
tags:
- R
- data_wrangling

---




----

## Introduction

I have received a few queries recently that can be categorized as "How do I collapse a list of categories or values into a shorter list of category or values?" For example, one user wanted to collapse species of fish into their respective families. Another user wanted to collapse years into decades. Data munging such as this is common in fisheries. Thus, I provide a quick demonstration here of one way to accomplish these tasks using tools from the [tidyverse](https://www.tidyverse.org/).

This post requires the `dplyr`, `magrittr`, and `plyr` packages. Note, however, that `plyr` is not loaded below because I am only going to use one specific function from `plyr` (i.e., `mapvalues()`) and I have found that `plyr` and `dplyr` don't always "play well" together.[^1]


{% highlight r %}
library(dplyr)    # for mutate(), %>%
library(magrittr) # for %<>%
{% endhighlight %}

Because I am creating random example data below, I set the random number seed to make the results reproducible.

{% highlight r %}
set.seed(678394)
{% endhighlight %}

<br>

## Create A Sample of Data
The following creates a very simple sample of 250 individuals on which the species (as a short abbreviation) and year of capture were recorded.


{% highlight r %}
n <- 250
dat <- data.frame(species=sample(c("BLG","LMB","PKS","WAE","YEP","CRP"),
                                 n,replace=TRUE),
                  year=sample(1980:2017,n,replace=TRUE))
head(dat)
{% endhighlight %}



{% highlight text %}
##   species year
## 1     PKS 1981
## 2     CRP 1998
## 3     YEP 1983
## 4     YEP 2003
## 5     LMB 2009
## 6     CRP 1994
{% endhighlight %}

<br>

## Example 1 -- Recode and Collapse Categories

The `mutate()` function may be used to add a new variable to a data.frame. The `mapvalues()` function (from `plyr`) may be use to efficiently recode character (or factor) values *in a vector*. Because `mapvalues()` operates on a vector, it must be used within `mutate()` to add a new variable with the recoded values to a data.frame. When used within `mutate()`, the first argument to `mapvalues()` is the vector that contains the original data to be recoded. A vector of categories for these original data are then given in `from=` and a vector of **new** categories for these data are given in `to=`.

I find it most simple to first create vectors of categories for `from=` and `to=` and then use them in `mapvalues()`. For example, the use of `levels()` below extracts (and saves into `short`) the vector of species abbreviations found in the `species` variable of the example data.

{% highlight r %}
( short <- levels(dat$species) )
{% endhighlight %}



{% highlight text %}
## [1] "BLG" "CRP" "LMB" "PKS" "WAE" "YEP"
{% endhighlight %}

"New categories" that correspond to each of the original categories may then be entered into a vector. For example, the `long` vector below contains the long-form names for each species (in the same order as the abbreviations in `short`) and `family` contains the corresponding family names.

{% highlight r %}
long <- c("Bluegill","Carp","Largemouth Bass",
          "Pumpkinseed","Walleye","Yellow Perch")
fam <- c("Centrarchidae","Cyprinidae","Centrarchidae",
         "Centrarchidae","Percidae","Percidae")
{% endhighlight %}

"Column bind" these vectors together to make sure that the categories are correctly matched across the vectors.

{% highlight r %}
cbind(short,long,fam)
{% endhighlight %}



{% highlight text %}
##      short long              fam            
## [1,] "BLG" "Bluegill"        "Centrarchidae"
## [2,] "CRP" "Carp"            "Cyprinidae"   
## [3,] "LMB" "Largemouth Bass" "Centrarchidae"
## [4,] "PKS" "Pumpkinseed"     "Centrarchidae"
## [5,] "WAE" "Walleye"         "Percidae"     
## [6,] "YEP" "Yellow Perch"    "Percidae"
{% endhighlight %}

The combined use of `mutate()` and `mapvalues()` below demonstrates how these vectors may be used to change the original abbreviated names to long-form names or family names. In addition, the last use of `mapvalues()` shows how to change the long-form names to family names. This last example is, of course, repetitive, but it is used here to demonstrate how `mutate()` allows a variable that was "just created" to be immediately used.

{% highlight r %}
dat %<>%
  mutate(speciesL=plyr::mapvalues(species,from=short,to=long),
         family=plyr::mapvalues(species,from=short,to=fam),
         family2=plyr::mapvalues(speciesL,from=long,to=fam))
head(dat)
{% endhighlight %}



{% highlight text %}
##   species year        speciesL        family       family2
## 1     PKS 1981     Pumpkinseed Centrarchidae Centrarchidae
## 2     CRP 1998            Carp    Cyprinidae    Cyprinidae
## 3     YEP 1983    Yellow Perch      Percidae      Percidae
## 4     YEP 2003    Yellow Perch      Percidae      Percidae
## 5     LMB 2009 Largemouth Bass Centrarchidae Centrarchidae
## 6     CRP 1994            Carp    Cyprinidae    Cyprinidae
{% endhighlight %}

Note in the code above that the use of `plyr::` in front of `mapvalues()` allows the user to use the `mapvalues()` function from `plyr` without loading the entire `plyr` package.[^2] As noted previously, this idiom is used here to avoid potential conflicts between `plyr` and `dplyr`.

Note that this use of `mapvalues()` and `mutate()` is described in Section 2.2.7 of my book [Introductory Fisheries Analyses with R](http://derekogle.com/IFAR/).

<br>

## Example 2 -- Collapse Values into Categories

The `case_when()` function (from `dplyr`) may be used to efficiently collapse discrete values into categories.[^3] This function also operates on vectors and, thus, must be used with `mutate()` to add a variable to a data.frame. The arguments to `case_when()` are a series of two-sided formulae where the left-side is a conditioning statement based on the original data and the right-side is the value that should appear in the new variable when that condition is `TRUE`. For example, the first line in `case_when()` below asks "if the year variable is in the values from 1980 to 1989 then the new category should be '1980s'."[^4] For example, the code below creates a new variable called `decade` that identifies the decade that corresponds to the year-of-capture variable.

{% highlight r %}
dat %<>%
  mutate(decade=case_when(
    year %in% 1980:1989 ~ "1980s",
    year %in% 1990:1999 ~ "1990s",
    year %in% 2000:2009 ~ "2000s",
    year %in% 2010:2019 ~ "2010s"
  ))
head(dat)
{% endhighlight %}



{% highlight text %}
##   species year        speciesL        family       family2 decade
## 1     PKS 1981     Pumpkinseed Centrarchidae Centrarchidae  1980s
## 2     CRP 1998            Carp    Cyprinidae    Cyprinidae  1990s
## 3     YEP 1983    Yellow Perch      Percidae      Percidae  1980s
## 4     YEP 2003    Yellow Perch      Percidae      Percidae  2000s
## 5     LMB 2009 Largemouth Bass Centrarchidae Centrarchidae  2000s
## 6     CRP 1994            Carp    Cyprinidae    Cyprinidae  1990s
{% endhighlight %}

The lines in `case_when()` operate sequentially (like a series of "if" statements) such that the above operation can be more succinctly coded as below. Also note in this example the resulting variable is numeric rather than categorical (simply as an example).

{% highlight r %}
dat %<>%
  mutate(decade2=case_when(
    year <= 1989 ~ 1980,
    year <= 1999 ~ 1990,
    year <= 2009 ~ 2000,
    year <= 2019 ~ 2010,
  ))
head(dat)
{% endhighlight %}



{% highlight text %}
##   species year        speciesL        family       family2 decade decade2
## 1     PKS 1981     Pumpkinseed Centrarchidae Centrarchidae  1980s    1980
## 2     CRP 1998            Carp    Cyprinidae    Cyprinidae  1990s    1990
## 3     YEP 1983    Yellow Perch      Percidae      Percidae  1980s    1980
## 4     YEP 2003    Yellow Perch      Percidae      Percidae  2000s    2000
## 5     LMB 2009 Largemouth Bass Centrarchidae Centrarchidae  2000s    2000
## 6     CRP 1994            Carp    Cyprinidae    Cyprinidae  1990s    1990
{% endhighlight %}



{% highlight r %}
str(dat)
{% endhighlight %}



{% highlight text %}
## 'data.frame':	250 obs. of  7 variables:
##  $ species : Factor w/ 6 levels "BLG","CRP","LMB",..: 4 2 6 6 3 2 4 4 1 6 ...
##  $ year    : int  1981 1998 1983 2003 2009 1994 2001 2006 1994 1991 ...
##  $ speciesL: Factor w/ 6 levels "Bluegill","Carp",..: 4 2 6 6 3 2 4 4 1 6 ...
##  $ family  : Factor w/ 3 levels "Centrarchidae",..: 1 2 3 3 1 2 1 1 1 3 ...
##  $ family2 : Factor w/ 3 levels "Centrarchidae",..: 1 2 3 3 1 2 1 1 1 3 ...
##  $ decade  : chr  "1980s" "1990s" "1980s" "2000s" ...
##  $ decade2 : num  1980 1990 1980 2000 2000 1990 2000 2000 1990 1990 ...
{% endhighlight %}

<br>

----

## Footnotes

[^1]: This may not be a concern with recent versions of `plyr` and `dplyr`. However, I have been bitten by enough problems when I have both of these packages loaded that I prefer to use the cautionary approach that I take in this post.

[^2]: The `FSA` package imports `mapvalues` from `plyr` and then exports it. Thus, if you have loaded the `FSA` package then you will not need to use the `plyr::` idiom.

[^3]: You may also want to consider `cut()` for this purpose or, for collapsing continuous data into categories, `lencat()` from the `FSA` package.

[^4]: The colon operator creates a sequence of all integers between the two numbers separated by the colon. The `%in%` is used on conditional statements to determine if a value is contained with a vector, returning `TRUE` if it is and `FALSE` if it is not.
