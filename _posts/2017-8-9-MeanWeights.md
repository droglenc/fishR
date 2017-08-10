---
title: "Mean Weights at Ages From Lengths"
layout: post
date: "August 9, 2017"
output:
  html_document
tags:
- Weight_Length
- Mean_Weight
---




----

Recently I was tasked with estimating mean weights at age for data that contained no weights, but did contain lengths and ages (ages were from applying an age-length key). A weight-length relationship was available (derived from a smaller sample from the same population). A question arose about whether the weight-length relationship should be used to predict weights for individual fish and then summarized to estimate mean weights at age or whether the weight-length relationship should be applied to summarized mean lengths at age to estimate mean weights at age. I explore these two methods for estimating mean weights at age in this post.

This post requires the `FSA`, `dplyr`, and `magrittr` packages.


{% highlight r %}
library(FSA)
library(dplyr)
library(magrittr)
{% endhighlight %}

I also set the random number seed to make the results reproducible.

{% highlight r %}
set.seed(678394)
{% endhighlight %}


## Create A Sample of Data
I used the following code to create a very simple population that consisted of lengths, weights, and ages of fish. Lengths were modeled as normal distributions within each age-class. Weights were predicted directly from a known weight-length relationship without any error (in `wt1`) and with a small amount of error (in `wt2`). Modeling data in this way is simple, but at least somewhat realistic (Figure  1).


{% highlight r %}
# Generate some lengths
ages <- 3:8
ns <- c(100,80,50,30,15,5)
mns <- c(300,450,525,560,575,590)
sds <- rep(30,length(mns))
lens <- NULL
for (i in 1:length(ages)) lens <- c(lens,rnorm(ns[i],mean=mns[i],sd=sds[i]))

# Parameters of a weight-length relationship
loga <- -13.5
b <- 3.2

# Compute weights from the W-L relationship, w/ & w/o error
df <- data.frame(age=rep(ages,ns),len=round(lens,0)) %>%
  mutate(wt1=round(exp(loga+b*log(len)),0),
         wt2=round(exp(loga+b*log(len)+rnorm(length(lens),mean=0,sd=0.1)),0))
headtail(df)
{% endhighlight %}



{% highlight text %}
##     age len  wt1  wt2
## 1     3 289  103  110
## 2     3 315  135  131
## 3     3 284   97   93
## 278   8 583  971 1006
## 279   8 612 1134  848
## 280   8 582  966 1032
{% endhighlight %}

![plot of chunk Explore1](http://derekogle.com/fishR/figures/Explore1-1.png)![plot of chunk Explore1](http://derekogle.com/fishR/figures/Explore1-2.png)![plot of chunk Explore1](http://derekogle.com/fishR/figures/Explore1-3.png)![plot of chunk Explore1](http://derekogle.com/fishR/figures/Explore1-4.png)

Figure  1: Histograms of lengths (upper left) and weights (upper right) and scatterplots of weight versus length (lower left) and length versus age (lower right). The line in the weight versus length scatterplot is the weights modeled without random error.


## Compare Mean Weights at Age from Different Methods
The first two lines below (using `group_by()` and `summarize()`) compute the sample size (`n`), mean length (`mnlen`), and the true mean weight (i.e., the weight for individual modeled above; `true.mnwt`) for the weights without any error for each age. The next line (using `mutate()`) computes the predicted mean weight at each age using the weight-length regression coefficients and the mean lengths just computed. The fourth line computes the percentage difference between the predicted and true mean weights for each age.


{% highlight r %}
sum1 <- group_by(df,age) %>%
  summarize(n=n(),mnlen=mean(len),true.mnwt=mean(wt1)) %>%
  mutate(pred.mnwt=exp(loga+b*log(mnlen)),
         diff.mnwt=(pred.mnwt-true.mnwt)/true.mnwt*100) %>%
  as.data.frame()
{% endhighlight %}

The results for the weights without any error show that the mean weight predicted from the mean length is lower than the mean weight computed from individual weights predicted from individual lengths (Table  1).

Table  1: Summary table using weights without any error.

<table border=1>
<tr> <th> age </th> <th> n </th> <th> mnlen </th> <th> true.mnwt </th> <th> pred.mnwt </th> <th> diff.mnwt </th>  </tr>
  <tr> <td align="right"> 3 </td> <td align="right"> 100 </td> <td align="right"> 305 </td> <td align="right"> 127 </td> <td align="right"> 122 </td> <td align="right"> -3.47 </td> </tr>
  <tr> <td align="right"> 4 </td> <td align="right"> 80 </td> <td align="right"> 450 </td> <td align="right"> 433 </td> <td align="right"> 424 </td> <td align="right"> -2.17 </td> </tr>
  <tr> <td align="right"> 5 </td> <td align="right"> 50 </td> <td align="right"> 533 </td> <td align="right"> 739 </td> <td align="right"> 729 </td> <td align="right"> -1.24 </td> </tr>
  <tr> <td align="right"> 6 </td> <td align="right"> 30 </td> <td align="right"> 568 </td> <td align="right"> 904 </td> <td align="right"> 893 </td> <td align="right"> -1.22 </td> </tr>
  <tr> <td align="right"> 7 </td> <td align="right"> 15 </td> <td align="right"> 574 </td> <td align="right"> 929 </td> <td align="right"> 924 </td> <td align="right"> -0.48 </td> </tr>
  <tr> <td align="right"> 8 </td> <td align="right"> 5 </td> <td align="right"> 579 </td> <td align="right"> 954 </td> <td align="right"> 949 </td> <td align="right"> -0.52 </td> </tr>
   </table>


Of course, weight-length relationships are not perfect, so the weights with a small amount of random error were used to determine if the pattern of a negative bias when predicting mean weights from mean lengths persists with more realistic data. [Note that only a small error was added because the relationship between weight and length is very strong for most fishes. The $r^2$ for this relationship was a realistic 0.988.] Similar results with these more realistic data showed a similar, though not as consistent, degree of negative bias when predicting mean weights from mean lengths (Table  2).

Table  2: Summary table using weights with a small amount of error.

<table border=1>
<tr> <th> age </th> <th> n </th> <th> mnlen </th> <th> true.mnwt </th> <th> pred.mnwt </th> <th> diff.mnwt </th>  </tr>
  <tr> <td align="right"> 3 </td> <td align="right"> 100 </td> <td align="right"> 305 </td> <td align="right"> 128 </td> <td align="right"> 122 </td> <td align="right"> -4.37 </td> </tr>
  <tr> <td align="right"> 4 </td> <td align="right"> 80 </td> <td align="right"> 450 </td> <td align="right"> 437 </td> <td align="right"> 424 </td> <td align="right"> -3.09 </td> </tr>
  <tr> <td align="right"> 5 </td> <td align="right"> 50 </td> <td align="right"> 533 </td> <td align="right"> 737 </td> <td align="right"> 729 </td> <td align="right"> -1.03 </td> </tr>
  <tr> <td align="right"> 6 </td> <td align="right"> 30 </td> <td align="right"> 568 </td> <td align="right"> 924 </td> <td align="right"> 893 </td> <td align="right"> -3.36 </td> </tr>
  <tr> <td align="right"> 7 </td> <td align="right"> 15 </td> <td align="right"> 574 </td> <td align="right"> 933 </td> <td align="right"> 924 </td> <td align="right"> -0.95 </td> </tr>
  <tr> <td align="right"> 8 </td> <td align="right"> 5 </td> <td align="right"> 579 </td> <td align="right"> 924 </td> <td align="right"> 949 </td> <td align="right"> 2.67 </td> </tr>
   </table>

Similar patterns were found using different values of the weight-length relationship b parameter (see Appendix).

## Some Thoughts on Why
The relationship between weight and length of most fishes follows an exponential model with an exponent parameter near 3 (usually between 2.5 and 3.5). One can think of this exponential function as a function that transforms length to weight. Applying the transformation function to the mean of the x variable will only result in the mean of the y variable if the transformation function is linear, because the linear transformation preserves the shape of the original distribution. The exponential function, in contrast, tends to compress differences between "small" values and spread out differences between "large" values (i.e., opposite of what a log transformation does). Thus, the shape of hte distribution of weights will be different then the shape of the distribution of lengths. For example, if lengths are normally distributed, then weights will tend to be right-skewed (i.e., a longer tail to the right because of the compressing of "smaller" values and the "spreading" of larger values; Figure  2).

![plot of chunk NormEx](http://derekogle.com/fishR/figures/NormEx-1.png)![plot of chunk NormEx](http://derekogle.com/fishR/figures/NormEx-2.png)

Figure  2: Histograms of 1000 lengths simulated from a normal distribution (left) and weigths predicted from those lengths with a weight-length regression (right) demonstrating how the normally distributed lengths will become right-skewed weights.

## Summary
Mean weights at age appear to be estimated with bias when a weight-length relationship is applied to mean lengths at age. While this systematic bias may be negligible for an individual fish, it may become substantial if mean weights are multipled by the total number of fish to estimate total biomass. Additionally, the systematic bias may not be detectable in the face of natural variability and systematic measurement error.

----

## Appendix: Summaries Using Different Values of b

Table  3: Summary table using weights without any error, but using b=2.5.

<table border=1>
<tr> <th> age </th> <th> n </th> <th> mnlen </th> <th> true.mnwt </th> <th> pred.mnwt </th> <th> diff.mnwt </th>  </tr>
  <tr> <td align="right"> 3 </td> <td align="right"> 100 </td> <td align="right"> 302 </td> <td align="right"> 2.2 </td> <td align="right"> 2.2 </td> <td align="right"> -1.54 </td> </tr>
  <tr> <td align="right"> 4 </td> <td align="right"> 80 </td> <td align="right"> 453 </td> <td align="right"> 6.0 </td> <td align="right"> 6.0 </td> <td align="right"> -0.88 </td> </tr>
  <tr> <td align="right"> 5 </td> <td align="right"> 50 </td> <td align="right"> 523 </td> <td align="right"> 8.7 </td> <td align="right"> 8.6 </td> <td align="right"> -1.34 </td> </tr>
  <tr> <td align="right"> 6 </td> <td align="right"> 30 </td> <td align="right"> 555 </td> <td align="right"> 10.0 </td> <td align="right"> 9.9 </td> <td align="right"> -0.29 </td> </tr>
  <tr> <td align="right"> 7 </td> <td align="right"> 15 </td> <td align="right"> 586 </td> <td align="right"> 11.3 </td> <td align="right"> 11.4 </td> <td align="right"> 0.76 </td> </tr>
  <tr> <td align="right"> 8 </td> <td align="right"> 5 </td> <td align="right"> 620 </td> <td align="right"> 13.2 </td> <td align="right"> 13.1 </td> <td align="right"> -0.43 </td> </tr>
   </table>

Table  4: Summary table using weights without any error, but using b=3.0.

<table border=1>
<tr> <th> age </th> <th> n </th> <th> mnlen </th> <th> true.mnwt </th> <th> pred.mnwt </th> <th> diff.mnwt </th>  </tr>
  <tr> <td align="right"> 3 </td> <td align="right"> 100 </td> <td align="right"> 295 </td> <td align="right"> 36 </td> <td align="right"> 35 </td> <td align="right"> -2.55 </td> </tr>
  <tr> <td align="right"> 4 </td> <td align="right"> 80 </td> <td align="right"> 450 </td> <td align="right"> 127 </td> <td align="right"> 125 </td> <td align="right"> -1.48 </td> </tr>
  <tr> <td align="right"> 5 </td> <td align="right"> 50 </td> <td align="right"> 523 </td> <td align="right"> 198 </td> <td align="right"> 196 </td> <td align="right"> -0.73 </td> </tr>
  <tr> <td align="right"> 6 </td> <td align="right"> 30 </td> <td align="right"> 561 </td> <td align="right"> 244 </td> <td align="right"> 241 </td> <td align="right"> -0.94 </td> </tr>
  <tr> <td align="right"> 7 </td> <td align="right"> 15 </td> <td align="right"> 580 </td> <td align="right"> 271 </td> <td align="right"> 268 </td> <td align="right"> -1.16 </td> </tr>
  <tr> <td align="right"> 8 </td> <td align="right"> 5 </td> <td align="right"> 565 </td> <td align="right"> 248 </td> <td align="right"> 248 </td> <td align="right"> -0.35 </td> </tr>
   </table>

Table  5: Summary table using weights without any error, but using b=3.5.

<table border=1>
<tr> <th> age </th> <th> n </th> <th> mnlen </th> <th> true.mnwt </th> <th> pred.mnwt </th> <th> diff.mnwt </th>  </tr>
  <tr> <td align="right"> 3 </td> <td align="right"> 100 </td> <td align="right"> 299 </td> <td align="right"> 674 </td> <td align="right"> 635 </td> <td align="right"> -5.78 </td> </tr>
  <tr> <td align="right"> 4 </td> <td align="right"> 80 </td> <td align="right"> 447 </td> <td align="right"> 2634 </td> <td align="right"> 2583 </td> <td align="right"> -1.95 </td> </tr>
  <tr> <td align="right"> 5 </td> <td align="right"> 50 </td> <td align="right"> 522 </td> <td align="right"> 4501 </td> <td align="right"> 4444 </td> <td align="right"> -1.28 </td> </tr>
  <tr> <td align="right"> 6 </td> <td align="right"> 30 </td> <td align="right"> 547 </td> <td align="right"> 5302 </td> <td align="right"> 5239 </td> <td align="right"> -1.20 </td> </tr>
  <tr> <td align="right"> 7 </td> <td align="right"> 15 </td> <td align="right"> 576 </td> <td align="right"> 6386 </td> <td align="right"> 6301 </td> <td align="right"> -1.33 </td> </tr>
  <tr> <td align="right"> 8 </td> <td align="right"> 5 </td> <td align="right"> 583 </td> <td align="right"> 6625 </td> <td align="right"> 6544 </td> <td align="right"> -1.22 </td> </tr>
   </table>
