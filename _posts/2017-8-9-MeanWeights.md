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

\begin{table}[ht]
\centering
\begin{tabular}{rrrrrr}
  \hline
age & n & mnlen & true.mnwt & pred.mnwt & diff.mnwt \\ 
  \hline
3 & 100 & 305 & 127 & 122 & -3.47 \\ 
  4 & 80 & 450 & 433 & 424 & -2.17 \\ 
  5 & 50 & 533 & 739 & 729 & -1.24 \\ 
  6 & 30 & 568 & 904 & 893 & -1.22 \\ 
  7 & 15 & 574 & 929 & 924 & -0.48 \\ 
  8 & 5 & 579 & 954 & 949 & -0.52 \\ 
   \hline
\end{tabular}
\end{table}


Of course, weight-length relationships are not perfect, so the weights with a small amount of random error were used to determine if the pattern of a negative bias when predicting mean weights from mean lengths persists with more realistic data. [Note that only a small error was added because the relationship between weight and length is very strong for most fishes. The $r^2$ for this relationship was a realistic 0.988.] Similar results with these more realistic data showed a similar, though not as consistent, degree of negative bias when predicting mean weights from mean lengths (Table  2).

Table  2: Summary table using weights with a small amount of error.

\begin{table}[ht]
\centering
\begin{tabular}{rrrrrr}
  \hline
age & n & mnlen & true.mnwt & pred.mnwt & diff.mnwt \\ 
  \hline
3 & 100 & 305 & 128 & 122 & -4.37 \\ 
  4 & 80 & 450 & 437 & 424 & -3.09 \\ 
  5 & 50 & 533 & 737 & 729 & -1.03 \\ 
  6 & 30 & 568 & 924 & 893 & -3.36 \\ 
  7 & 15 & 574 & 933 & 924 & -0.95 \\ 
  8 & 5 & 579 & 924 & 949 & 2.67 \\ 
   \hline
\end{tabular}
\end{table}

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

\begin{table}[ht]
\centering
\begin{tabular}{rrrrrr}
  \hline
age & n & mnlen & true.mnwt & pred.mnwt & diff.mnwt \\ 
  \hline
3 & 100 & 302 & 2.2 & 2.2 & -1.54 \\ 
  4 & 80 & 453 & 6.0 & 6.0 & -0.88 \\ 
  5 & 50 & 523 & 8.7 & 8.6 & -1.34 \\ 
  6 & 30 & 555 & 10.0 & 9.9 & -0.29 \\ 
  7 & 15 & 586 & 11.3 & 11.4 & 0.76 \\ 
  8 & 5 & 620 & 13.2 & 13.1 & -0.43 \\ 
   \hline
\end{tabular}
\end{table}

Table  4: Summary table using weights without any error, but using b=3.0.

\begin{table}[ht]
\centering
\begin{tabular}{rrrrrr}
  \hline
age & n & mnlen & true.mnwt & pred.mnwt & diff.mnwt \\ 
  \hline
3 & 100 & 295 & 36 & 35 & -2.55 \\ 
  4 & 80 & 450 & 127 & 125 & -1.48 \\ 
  5 & 50 & 523 & 198 & 196 & -0.73 \\ 
  6 & 30 & 561 & 244 & 241 & -0.94 \\ 
  7 & 15 & 580 & 271 & 268 & -1.16 \\ 
  8 & 5 & 565 & 248 & 248 & -0.35 \\ 
   \hline
\end{tabular}
\end{table}

Table  5: Summary table using weights without any error, but using b=3.5.

\begin{table}[ht]
\centering
\begin{tabular}{rrrrrr}
  \hline
age & n & mnlen & true.mnwt & pred.mnwt & diff.mnwt \\ 
  \hline
3 & 100 & 299 & 674 & 635 & -5.78 \\ 
  4 & 80 & 447 & 2634 & 2583 & -1.95 \\ 
  5 & 50 & 522 & 4501 & 4444 & -1.28 \\ 
  6 & 30 & 547 & 5302 & 5239 & -1.20 \\ 
  7 & 15 & 576 & 6386 & 6301 & -1.33 \\ 
  8 & 5 & 583 & 6625 & 6544 & -1.22 \\ 
   \hline
\end{tabular}
\end{table}
