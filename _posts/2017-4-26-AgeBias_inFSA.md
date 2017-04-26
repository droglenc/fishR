---
layout: post
title: Age Bias Plot Changes in FSA
date: "April 26, 2017"
tags: [R, FSA, Age]
---




----

In the last two weeks, I have posted twice about modifying [age bias plots](http://derekogle.com/fishR/2017-04-14-Modified_AgeBiasPlot) and [Bland-Altman-like plots](http://derekogle.com/fishR/2017-04-20-Modified_BlandAltmanPlot) for comparing age estimates. From those posts, I have decided that I prefer to 

* plot differences between the ages on the y-axis (as compared to the nonreference ages),
* plot overlapping points with a transparent color that becomes darker as more points overlap,
* when individual points are shown, plot a generalized additive model (GAM) that describes the relationship between the difference in ages and the reference ages or the mean of the two ages (if a reference age is not declared), and
* when individual data points are not shown, show the mean and range (rather than confidence intervals) of differences in ages at each reference age with open points representing means where a significant difference between the estimates is evident.

I recently updated the **FSA** package so that these preferences are the defaults, while still allowing users some flexibility in creating plots that fit their preferences. Here I explain this new functionality.

The functionality described here is available in the current development version of **FSA** and will eventually (during summer) be on CRAN as version 0.8.13. I welcome any comments or suggestions.

The data used here will again be ages of Lake Whitefish (*Coregonus clupeaformis*) from Lake Champlain that are available in the `WhitefishLC` data.frame in **FSA**. These analyses will compare consensus (between two readers) otolith (`otolithC`) and scale (`scaleC`) age estimates and otolith ages between two readers (`otolith1` and `otolith2`). The consensus otolith age estimates and otolith age estimates from the first reader will be considered as "reference" ages when such a distinction is needed.

{% highlight r %}
library(FSA)
data(WhitefishLC)
head(WhitefishLC)
{% endhighlight %}



{% highlight text %}
##   fishID  tl scale1 scale2 scaleC finray1 finray2 finrayC otolith1
## 1      1 345      3      3      3       3       3       3        3
## 2      2 334      4      3      4       3       3       3        3
## 3      3 348      7      5      6       3       3       3        3
## 4      4 300      4      3      4       3       2       3        3
## 5      5 330      3      3      3       4       3       4        3
## 6      6 316      4      4      4       2       3       3        6
##   otolith2 otolithC
## 1        3        3
## 2        3        3
## 3        3        3
## 4        3        3
## 5        3        3
## 6        5        6
{% endhighlight %}



{% highlight r %}
abSO <- ageBias(scaleC~otolithC,data=WhitefishLC,
                nref.lab="Scale Age",ref.lab="Otolith Age")
abOO <- ageBias(otolith2~otolith1,data=WhitefishLC,
                nref.lab="Reader 2",ref.lab="Reader 1")
{% endhighlight %}

----

# Age comparisons with summary statistics
The default plot of an `ageBias()` object is a modified age bias plot with the difference in age estimates on the y-axis, the reference age estimates on the x-axis, a reference line at a difference in age estimates of zero, the mean and the range of differences in age estimates shown for each reference age estimate, open points representing age estimates where the mean difference in age estimates is significantly different from zero, solid points representing age estimates where the mean difference in age estimates is not significantly different from zero, a marginal histogram at the top that shows the distribution (and sample sizes) of the reference age estimates, and a marginal histogram on the right that shows the distribution of the difference in age estimates. Confidence intervals for the mean differences in age estimates at each reference age estimate may be added with `show.CI=TRUE` and individual points can be added with `show.pts=TRUE`. Other options are described in the `ageBias()` documentation, which includes a number of examples. 

The example in Figure  1 shows that age estimates from scales are less than age estimates from otoliths for otolith age estimates greater than about age-6 or 8, though the statistical evidence is less clear at older ages due to low sample sizes and increased variability. The example in Figure  2 illustrates no systematic difference in age estimates from otoliths between two readers. [*Note that the y-axis limits here were widened from the defaults so that the bars in the marginal histogram were not cut off.*]


{% highlight r %}
plot(abSO)
{% endhighlight %}

![plot of chunk RefSO1](http://derekogle.com/fishR/figures/RefSO1-1.png)

Figure  1: Mean (points) and range (intervals) of differences in scale and otolith age estimates at each otolith age estimate for Lake Champlain Lake Whitefish. Open points represent mean differences in scale and otolith age estimates that are significantly different from zero (dashed gray horizontal line). Marginal histograms are for otolith age estimates (top) and differences in scale and otolith age estimates (right).


{% highlight r %}
plot(abOO,ylim=c(-2.4,2.4))
{% endhighlight %}

![plot of chunk RefOO1](http://derekogle.com/fishR/figures/RefOO1-1.png)

Figure  2: Mean (points) and range (intervals) of differences in otolith age estimates between two readers at the estimates for the first reader for Lake Champlain Lake Whitefish. Open points represent mean differences in age estimates that are significantly different from zero (dashed gray horizontal line). Marginal histograms are for age estimates of the first reader (top) and differences in age estimates between readers (right).


----

# Individual points with a GAM smoother
As discussed in [this post](http://derekogle.com/fishR/2017-04-20-Modified_BlandAltmanPlot), differences between two sets of age estimates can be revealed by plotting individual points with a summary for the relationship between the differences in age estimates and the reference or mean age estimates (whichever is used on the x-axis). These examples show how to create a base plot to which a summary can be added. These examples use the mean of the two age estimates on the x-axis, but the plot from the previous section with the reference age estimates on the x-axis could be used (but with `show.pts=TRUE` to show the individual points and `show.range=FALSE` to remove the mean and range intervals).

Before making the first example plot, a GAM will be fit to the differences and mean age estimates data. These data are contained in the `diff` and `mean` variables in the `data` object returned in the `ageBias()` object.

{% highlight r %}
head(abSO$data)
{% endhighlight %}



{% highlight text %}
##   scaleC otolithC diff mean
## 1      3        3    0  3.0
## 2      4        3    1  3.5
## 3      6        3    3  4.5
## 4      4        3    1  3.5
## 5      3        3    0  3.0
## 6      4        6   -2  5.0
{% endhighlight %}

As shown in [this post](http://derekogle.com/fishR/2017-04-20-Modified_BlandAltmanPlot), the GAM is fit with `gam()` using `s()` from the `mgcv` package. The mean predicted differences in age estimates, and their standard errors, throughout the range of observed mean age estimates are calculated with `predict()` using `type="response"` and `se=TRUE`. Approximate 95% confidence intervals for the predicted mean differences in age estimates are computed from normal theory. The code below fits the GAM, creates a vector of mean age estimates at which to make predictions, makes the predictions, and computes the approximate 95% confidence intervals.

{% highlight r %}
library(dplyr)  # for mutate()
library(mgcv)   # for gam() and s()
mod1 <- gam(diff~s(mean,k=5),data=abSO$data)
tmp <- seq(0,18,0.1)
pred1 <- data.frame(age=tmp,
                    predict(mod1,data.frame(mean=tmp),type="response",se=TRUE)) %>%
  mutate(LCI=fit-1.96*se.fit,UCI=fit+1.96*se.fit)
head(pred1)
{% endhighlight %}



{% highlight text %}
##   age        fit    se.fit       LCI      UCI
## 1 0.0 -0.2479616 0.7058686 -1.631464 1.135541
## 2 0.1 -0.2333355 0.6846088 -1.575169 1.108498
## 3 0.2 -0.2187095 0.6634582 -1.519088 1.081669
## 4 0.3 -0.2040835 0.6424276 -1.463241 1.055075
## 5 0.4 -0.1894574 0.6215291 -1.407654 1.028740
## 6 0.5 -0.1748314 0.6007766 -1.352354 1.002691
{% endhighlight %}

The base plot of individual differences in age estimates plotted against the mean age estimates is constructed by adding `xvals="mean"` to `plot()`. By default, a histogram for the difference in age estimates is shown on the right. A histogram for the mean age estimates is not shown by default but can be added at the top with `xHist=TRUE`. The `allowAdd=TRUE` argument is used so that "items", like the GAM results, can be added to the main plot (i.e., not the marginal histograms). Note that using `allowAdd=TRUE` changes the current graphing parameters and that it is good practice to save the current graphing parameters (the first line below) so that they can be reset after finishing the plot (use of `par(op)` below).

{% highlight r %}
op <- par(no.readonly=TRUE)
plot(abSO,xvals="mean",transparency=1/4,allowAdd=TRUE)
{% endhighlight %}

The GAM results (line at the the predicted means and polygon for the 95% confidence bands) are then added to this plot as described in [this post](http://derekogle.com/fishR/2017-04-20-Modified_BlandAltmanPlot).

{% highlight r %}
with(pred1,polygon(c(age,rev(age)),c(LCI,rev(UCI)),
                   border=NA,col=col2rgbt("gray80",1/2)))
lines(fit~age,data=pred1,lwd=2,lty=2)
{% endhighlight %}

Finally, the graphing parameters are returned to their original values.

{% highlight r %}
par(op)
{% endhighlight %}

The example in Figure  3 suggests that the two age estimates generally agree to a mean age of about 5, after which ages estimated from scales are less than ages estimated from otoliths. The example in Figure  4 suggests no difference in age estimates between the two readers for all mean ages. 

![plot of chunk MeanSO1](http://derekogle.com/fishR/figures/MeanSO1-1.png)

Figure  3: Differences in scale and otolith age estimates at each mean age estimate for Lake Champlain Lake Whitefish. The dashed gray horizontal line is at 0, which represents no difference between scale and otolith age estimates. The dashed black line and gray polygon represent the mean and 95% confidence band for the predicted mean difference in age estimates from a generalized additive model. The right marginal histogram is for the differences in scale and otolith age estimates.

![plot of chunk MeanOO1](http://derekogle.com/fishR/figures/MeanOO1-1.png)

Figure  4: Differences in otolith age estimates between two readers at each mean age estimate for Lake Champlain Lake Whitefish. The dashed gray horizontal line is at 0, which represents no difference in age estimates between the two readers. The dashed black line and gray polygon represent the mean and 95% confidence band for the predicted mean difference in age estimates from a generalized additive model. The right marginal histogram is for the differences in age estimates between the two readers.


----

# Some "traditional" plots
My modification of the traditional age bias plot of Campana et al. (1995) is constructed from the `ageBias()` object with `plotAB()` (Figure  5). Some simple modifications of this plot are demonstrated in the documentation and examples for `plotAB()`.

{% highlight r %}
plotAB(abSO)
{% endhighlight %}

![plot of chunk AgeBiasSO1](http://derekogle.com/fishR/figures/AgeBiasSO1-1.png)

Figure  5: Mean (points) and 95% confidence intervals of scale age estimates at each otolith age estimate for Lake Champlain Lake Whitefish. The dashed gray line represents age estimates that agree. Open points (with red confidence intervals) represent mean scale age estimates that differ significantly from the corresponding otolith age estimate.

Finally, some users prefer a simple plot that shows the number of individuals at each point (Figure  6). This plot is constructed with `plotAB()` using `what="nunbers"`.


{% highlight r %}
plotAB(abSO,what="numbers")
{% endhighlight %}

![plot of chunk AgeBiasNumSO1](http://derekogle.com/fishR/figures/AgeBiasNumSO1-1.png)

Figure  6: Number of individuals by each scale and otolith age estimate combination for Lake Champlain Lake Whitefish. The dashed gray line represents age estimates that agree.

----

### References

* Campana, S.E., M.C. Annand, and J.I. McMillan. 1995. Graphical and statistical methods for determining the consistency of age determinations. Transactions of the American Fisheries Society 124:131-138.

* Ogle, D.H. 2015. [Introductory Fisheries Analyses with R book](http://derekogle.com/IFAR/). CRC Press.

----
