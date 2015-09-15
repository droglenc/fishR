---
layout: post
title: Two New Cumulative Sum Functions
date: "Sunday, September 6, 2015"
tags: [R, FSA]
---







In fisheries analysis it is fairly common to compute the cumulative sum of values in a vector  -- i.e., all values before and including the current position in the vector.  For example, the third value in the cumulative sum would be the sum of the first, second, and third values in the original vector.  These types of cumulative sums are easily accomplished with `cumsum()` in base R.

{% highlight r %}
vec <- 1:10
( cum <- cumsum(vec) )
{% endhighlight %}



{% highlight text %}
##  [1]  1  3  6 10 15 21 28 36 45 55
{% endhighlight %}



{% highlight r %}
cum[3]
{% endhighlight %}



{% highlight text %}
## [1] 6
{% endhighlight %}

Some applications in fisheries science (e.g., depletion estimators) require the cumulative sum **NOT** including the current value in the vector.  For example, the third value in this case would be the sum of the first and second values in the original vector.  These values can be computed by subtracting the original vector from the vector returned by `cumsum()`.


{% highlight r %}
cum-vec
{% endhighlight %}



{% highlight text %}
##  [1]  0  1  3  6 10 15 21 28 36 45
{% endhighlight %}

For efficiency, this simple process has been coded in `pcumsum()` in **FSA**.


{% highlight r %}
( pcum <- pcumsum(vec) )
{% endhighlight %}



{% highlight text %}
##  [1]  0  1  3  6 10 15 21 28 36 45
{% endhighlight %}



{% highlight r %}
pcum[3]
{% endhighlight %}



{% highlight text %}
## [1] 3
{% endhighlight %}

In still other applications (e.g., proportional size distribution calculations) a cumulative sum from the **LEFT** rather than the right is required.  For example, the third value in this case would be the sum of the third, fourth, fifth, ..., last values in the original vector.  These values can be computed by reversing the order of the result from `cumsum()` that had been applied to the reverse order of the original vector.



{% highlight r %}
rev(cumsum(rev(vec)))
{% endhighlight %}



{% highlight text %}
##  [1] 55 54 52 49 45 40 34 27 19 10
{% endhighlight %}

For efficiency, this simple process has been coded in `rcumsum()` in **FSA**.


{% highlight r %}
( rcum <- rcumsum(vec) )
{% endhighlight %}



{% highlight text %}
##  [1] 55 54 52 49 45 40 34 27 19 10
{% endhighlight %}



{% highlight r %}
rcum[3]
{% endhighlight %}



{% highlight text %}
## [1] 52
{% endhighlight %}

The three types of cumulative sums are shown, along with the original vector, in the matrix below.

{% highlight r %}
cbind(vec,cum,pcum,rcum)
{% endhighlight %}



{% highlight text %}
##       vec cum pcum rcum
##  [1,]   1   1    0   55
##  [2,]   2   3    1   54
##  [3,]   3   6    3   52
##  [4,]   4  10    6   49
##  [5,]   5  15   10   45
##  [6,]   6  21   15   40
##  [7,]   7  28   21   34
##  [8,]   8  36   28   27
##  [9,]   9  45   36   19
## [10,]  10  55   45   10
{% endhighlight %}

These two new functions are unlikely to change the world as we know it; however, I wanted to document them in this blog so that others could find them if needed.
