---
layout: post
title: Exploring the Half-Life Property of K
date: "June 12, 2016"
tags: [R, Growth, von_Bertalanffy]
---




----

A colleague recently questioned whether the loge(2)/K, where K is the Brody growth coefficient in the typical parameterization of the von Bertalanffy growth function, represents the "amount of time it takes for a fish to grow from any length to a length halfway between the initial length and the asymptotic mean length (Linf)".  This phenomenon is briefly illustrated below.

- Create an R function for the typical von Bertalanffy growth function.


{% highlight r %}
library(FSA)
vb <- vbFuns()
{% endhighlight %}

- Declare some parameter values.


{% highlight r %}
Linf <- 30
K <- 0.3
t0 <- -0.5
{% endhighlight %}

- Predict a mean length at the initial age.


{% highlight r %}
initA <- 1
( initL <- vb(initA,Linf,K,t0) )
{% endhighlight %}



{% highlight text %}
## [1] 10.87116
{% endhighlight %}

- Predict a mean length at the initial age plus loge(2)/K.


{% highlight r %}
nextA <- initA+log(2)/K
( nextL <- vb(nextA,Linf,K,t0) )
{% endhighlight %}



{% highlight text %}
## [1] 20.43558
{% endhighlight %}

- Find the length that is halfway between the initial length and Linf.


{% highlight r %}
mean(c(initL,Linf))
{% endhighlight %}



{% highlight text %}
## [1] 20.43558
{% endhighlight %}

Note that these last two values are equal, which illustrates the statement above about the "half-life" meaning of K.

----

This process is repeated below for several initial age values.  Note that the differences between the predicted mean length at the new age and the point halfway between the initial length and Linf are equal (within machine precision) for each initial age.  Again, illustrating the statement about K.


{% highlight r %}
initA <- 1:20
initL <- vb(initA,Linf,K,t0)
nextA <- initA+log(2)/K
nextL <- vb(nextA,Linf,K,t0)
testL <- rowMeans(cbind(initL,Linf))
cbind(nextL,testL,diff=nextL-testL)
{% endhighlight %}



{% highlight text %}
##          nextL    testL          diff
##  [1,] 20.43558 20.43558  0.000000e+00
##  [2,] 22.91450 22.91450  0.000000e+00
##  [3,] 24.75093 24.75093 -3.552714e-15
##  [4,] 26.11140 26.11140  0.000000e+00
##  [5,] 27.11925 27.11925  0.000000e+00
##  [6,] 27.86589 27.86589  0.000000e+00
##  [7,] 28.41901 28.41901  0.000000e+00
##  [8,] 28.82878 28.82878  0.000000e+00
##  [9,] 29.13234 29.13234  0.000000e+00
## [10,] 29.35722 29.35722  3.552714e-15
## [11,] 29.52382 29.52382  0.000000e+00
## [12,] 29.64723 29.64723 -3.552714e-15
## [13,] 29.73866 29.73866  0.000000e+00
## [14,] 29.80640 29.80640 -3.552714e-15
## [15,] 29.85658 29.85658 -3.552714e-15
## [16,] 29.89375 29.89375  0.000000e+00
## [17,] 29.92129 29.92129 -3.552714e-15
## [18,] 29.94169 29.94169  0.000000e+00
## [19,] 29.95680 29.95680  0.000000e+00
## [20,] 29.96800 29.96800  0.000000e+00
{% endhighlight %}

----

The code below illustrates the same phenomenon for a very different set of parameter values.


{% highlight r %}
Linf <- 300
K <- 0.9
t0 <- 1
initA <- 1:20
initL <- vb(initA,Linf,K,t0)
nextA <- initA+log(2)/K
nextL <- vb(nextA,Linf,K,t0)
testL <- rowMeans(cbind(initL,Linf))
cbind(nextL,testL,diff=nextL-testL)
{% endhighlight %}



{% highlight text %}
##          nextL    testL          diff
##  [1,] 150.0000 150.0000 -2.842171e-14
##  [2,] 239.0146 239.0146  0.000000e+00
##  [3,] 275.2052 275.2052  0.000000e+00
##  [4,] 289.9192 289.9192  0.000000e+00
##  [5,] 295.9014 295.9014  0.000000e+00
##  [6,] 298.3337 298.3337  0.000000e+00
##  [7,] 299.3225 299.3225  0.000000e+00
##  [8,] 299.7246 299.7246  5.684342e-14
##  [9,] 299.8880 299.8880  0.000000e+00
## [10,] 299.9545 299.9545  0.000000e+00
## [11,] 299.9815 299.9815  0.000000e+00
## [12,] 299.9925 299.9925  0.000000e+00
## [13,] 299.9969 299.9969  5.684342e-14
## [14,] 299.9988 299.9988  0.000000e+00
## [15,] 299.9995 299.9995  0.000000e+00
## [16,] 299.9998 299.9998  0.000000e+00
## [17,] 299.9999 299.9999  5.684342e-14
## [18,] 300.0000 300.0000  0.000000e+00
## [19,] 300.0000 300.0000  0.000000e+00
## [20,] 300.0000 300.0000  0.000000e+00
{% endhighlight %}


----
