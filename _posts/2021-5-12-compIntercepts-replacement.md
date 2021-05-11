---
title: "Replace compIntercepts() with emmeans()"
layout: post
date: "May 12, 2021"
output:
  html_document
tags:
- R
- FSA
- linear_regressions

---




----

## Introduction
The `compIntercepts()` function in `FSA` (prior to v0.9.0) was used to statistically compare intercepts for all pairs of groups with the same slope in an indicator/dummy variable regression (I/DVR). However, the excellent `emmeans()` function in the `emmmeans` package is a more general approach that follows principals similar to those of `emtrends()`, which I demonstrated in [a post yesterday](http://derekogle.com/fishR/2021-05-11-compSlopes-replacement). As such, `compIntercepts()` will be removed from the next version (0.9.0) of `FSA`.

In this post I demonstrate how to use `emmeans()` for the same purpose as `compIntercepts()` was used (prior to FSA v0.9.0). **Note, however, that the results will not be identical because `compSlopes()` and `emtrends()` use different methods to correct for multiple comparisons when comparing pairs of slopes.**

&nbsp;

The `Mirex` data described [here](http://derekogle.com/FSA/reference/Mirex.html), but filtered to include just three years, will be used in this post.[^filtered]


{% highlight r %}
library(FSA)
data(Mirex)
## reduce to three years ... only for simplicity in this post
Mirex <- subset(Mirex,year<1990)
## treat year as a factor for the IVR modeling
Mirex$year <- factor(Mirex$year)
{% endhighlight %}

The `lm()` below fits the I/DVR to determine if the relationship between mirex concentration and weight of the salmon differs by year.


{% highlight r %}
lm1 <- lm(mirex~weight*year,data=Mirex)
{% endhighlight %}

The `weight:year` interaction term p-value suggests that the slopes (i.e., relationship between mirex concentration and salmon weight) do NOT differ among the three years. However, the `year` term p-value suggests that the *intercepts* of at least one pair of these parallel lines DO differ.[^slopes]


{% highlight r %}
anova(lm1)
{% endhighlight %}



{% highlight text %}
## Analysis of Variance Table
## 
## Response: mirex
##             Df  Sum Sq Mean Sq F value    Pr(>F)
## weight       1 0.32844 0.32844 89.9408 6.064e-14
## year         2 0.05719 0.02859  7.8306 0.0008881
## weight:year  2 0.00089 0.00044  0.1218 0.8855178
## Residuals   66 0.24101 0.00365
{% endhighlight %}

A next step is to determine which pair(s) of intercepts differ significantly. In preparation for this next step, I fit a model that does not include the insignificant interaction term.[^nointeraction]


{% highlight r %}
lm1a <- lm(mirex~weight+year,data=Mirex)
{% endhighlight %}


&nbsp;

## `compIntercepts()` from `FSA`
The procedure coded in `compItercepts()` is described in more detail in [this supplement](http://derekogle.com/IFAR/supplements/weightlength/index.html#pinpointing-specific-differences-among-intercepts) to the [Introductory Fisheries Analyses with R book](https://derekogle.com/IFAR/). The results of `compIntercepts()` applied to the saved `lm()` object are assigned to an object below.[^print]


{% highlight r %}
cifsa <- compIntercepts(lm1a)
{% endhighlight %}

The `$comparisons` component in this saved object contains the results from comparing all pairs of intercepts. Each paired comparison is a row in these results with the groups being compared under `comparison`, the differences in sample intercepts under `diff`, 95% confidence intervals for the difference in intercepts under `95% LCI` and `95% UCI`, and adjusted (for multiple comparisons) p-values for the hypothesis test comparing the intercepts under `p.adj`.


{% highlight r %}
cifsa$comparisons
{% endhighlight %}



{% highlight text %}
##   comparison        diff     95% LCI     95% UCI        p.adj
## 1  1982-1977 -0.05418782 -0.09512956 -0.01324608 0.0063507871
## 2  1986-1977 -0.06550789 -0.10644963 -0.02456615 0.0007997388
## 3  1986-1982 -0.01132007 -0.05226181  0.02962167 0.7860342734
{% endhighlight %}

For example, these results suggest that the intercepts for 1982 and 1977 ARE statistically different (first row), but the intercepts for 1986 and 1982 are NOT statistically different (last row).

The `$smeans` component in this saved object contains the mean value of the response variable predicted at the mean value of the covariate. For example, the results below show the predicted mean mirex concentration at the overall mean salmon weight (i.e., 3.782083 kg).


{% highlight r %}
cifsa$means
{% endhighlight %}



{% highlight text %}
##      1977      1982      1986 
## 0.2379541 0.1837663 0.1724462
{% endhighlight %}

Because the lines are known to be parallel, differences in intercepts also represent differences in predicted means of the response at all other values of the covariate. `compIntercepts()` defaulted to show these means at the mean (i.e., center) of the covariate. This could be adjusted with `common.cov=` in `compIntercepts()`. For example, the actual intercepts are shown below.


{% highlight r %}
cifsa2 <- compIntercepts(lm1a,common.cov=0)
cifsa2$means
{% endhighlight %}



{% highlight text %}
##       1977       1982       1986 
## 0.13688994 0.08270212 0.07138205
{% endhighlight %}

&nbsp;

## `emmeans()` from `emmeans`
Similar results can be obtained with `emmeans()` from `emmeans` using the fitted `lm()` object (without the interaction term) as the first argument and a `specs=` argument with `pairwise~` followed by the name of the factor variable from the `lm()` model (`year` in this case).


{% highlight r %}
library(emmeans)
ci <- emmeans(lm1a,specs=pairwise~year)
{% endhighlight %}

The object saved from `emmeans()` is then given as the first argument to `summary()`, which also requires `infer=TRUE` if you would like p-values to be calculated.[^pvalues]


{% highlight r %}
cis <- summary(ci,infer=TRUE)
{% endhighlight %}

The `$contrasts` component in this saved object contains the results for comparing all pairs of predicted means at the overall mean of the covariate. Each paired comparison is a row with the groups compared under `contrast`, the difference in predicted means under `estimate`, the standard error of the difference in predicted means under `SE`, the degrees-of-freedom under `df`, a 95% confidence interval for the difference in predicted means under `lower.CL` and `upper.CL`, and the t test statistic and p-value adjusted for multiple comparisons for testing a difference in predicted means under `t.ratio` and `p.value`, respectively.


{% highlight r %}
cis$contrasts
{% endhighlight %}



{% highlight text %}
##  contrast    estimate     SE df lower.CL upper.CL t.ratio p.value
##  1977 - 1982   0.0542 0.0173 68   0.0128   0.0956 3.139   0.0070 
##  1977 - 1986   0.0655 0.0175 68   0.0235   0.1075 3.736   0.0011 
##  1982 - 1986   0.0113 0.0173 68  -0.0302   0.0529 0.653   0.7913 
## 
## Confidence level used: 0.95 
## Conf-level adjustment: tukey method for comparing a family of 3 estimates 
## P value adjustment: tukey method for comparing a family of 3 estimates
{% endhighlight %}

Comparing these results to the `$comparison` component from `compIntercepts()` shows that the difference in sample intercepts or predicted means are the same, though the signs differ because the subtraction was reversed. The confidence interval values and p-values are slightly different. Again, this is due to `emmeans()` and `compIntercepts()` using different methods of adjusting for multiple comparisons. These differences did not result in different conclusions in this case, but they could, especially if the p-values are near the rejection criterion.

The `$emmeans` component contains results for predicted means for each group with the groups under the name of the factor variable (`year` in this example), the predicted means under `emmean`, standard errors of the predicted means under `SE`, degrees-of-freedom under `df`, 95% confidence intervals for the predicted mean under `lower.CL` and `upper.CL`, and t test statistics and p-values adjusted for multiple comparisons for testing that the predicted mean is not equal to zero under `t.ratio` and `p.adj`, respectively. While it is not obvious here, these predict means of the response variable are at the mean of the covariate, as they were for `compIntercepts()`.


{% highlight r %}
cis$emmeans
{% endhighlight %}



{% highlight text %}
##  year emmean     SE df lower.CL upper.CL t.ratio p.value
##  1977  0.238 0.0123 68    0.213    0.262 19.392  <.0001 
##  1982  0.184 0.0122 68    0.159    0.208 15.091  <.0001 
##  1986  0.172 0.0123 68    0.148    0.197 14.015  <.0001 
## 
## Confidence level used: 0.95
{% endhighlight %}

Here the predicted means match exactly (within rounding) with those in the `$means` component of `compIntercepts()`.

The means can be predicted at any other "summary" value of the covariate using `cov.reduce=` in `emmeans()`. For example, the predicted values at the minimum value of the covariate are obtained below.


{% highlight r %}
ci2 <- emmeans(lm1a,specs=pairwise~year,cov.reduce=min)
cis2 <- summary(ci2,infer=TRUE)
cis2$emmeans
{% endhighlight %}



{% highlight text %}
##  year emmean     SE df lower.CL upper.CL t.ratio p.value
##  1977 0.1460 0.0143 68   0.1174    0.175 10.181  <.0001 
##  1982 0.0918 0.0151 68   0.0617    0.122  6.097  <.0001 
##  1986 0.0805 0.0163 68   0.0479    0.113  4.928  <.0001 
## 
## Confidence level used: 0.95
{% endhighlight %}

The following will compute predicted means that represent the actual intercepts.


{% highlight r %}
ci3 <- emmeans(lm1a,specs=pairwise~year,cov.reduce=function(x) 0)
cis3 <- summary(ci3,infer=TRUE)
cis3$emmeans
{% endhighlight %}



{% highlight text %}
##  year emmean     SE df lower.CL upper.CL t.ratio p.value
##  1977 0.1369 0.0148 68   0.1073    0.166 9.229   <.0001 
##  1982 0.0827 0.0156 68   0.0516    0.114 5.301   <.0001 
##  1986 0.0714 0.0169 68   0.0376    0.105 4.213   0.0001 
## 
## Confidence level used: 0.95
{% endhighlight %}

&nbsp;

## Conclusion
The `emmeans()` function in the `emmeans` package provides a more general solution to comparing multiple intercepts (or predicted means on parallel lines) than what was used in `compIntercepts()` in the `FSA` package (prior to v0.9.0). Thus, `compIntercepts()` will be removed from FSA with v0.9.0. You should use `emmeans()` instead.

The `emmeans` package has extensive vignettes that further explain its use. Their ["Basics" vignette](https://cran.r-project.org/web/packages/emmeans/vignettes/basics.html) is very useful.

Note that this change to `FSA` does not affect anything in the published [Introductory Fisheries Analyses with R](https://derekogle.com/IFAR/) book. However, the specific analysis in [this supplement](http://derekogle.com/IFAR/supplements/weightlength/index.html) to the book will no longer work as described. The use of `compIntercepts()` there will need to be replaced with `emmeans()`.

In [a previous post](http://derekogle.com/fishR/2021-05-11-compSlopes-replacement) I demonstrated how to use `emtrends()` from the `emmeans` package to replace `compSlopes()`, which will also be removed from the next version of `FSA`.

&nbsp;

&nbsp;

## Footnotes

[^filtered]: I filtered the data to only three years to reduce the amount of output below to make it easier to follow the main concepts.
[^slopes]: The `weight` term p-value suggests that there is a significant relationsip between mirex concentration and salmon weight, regardless of which year is considered.
[^nointeraction]: Note that use of the additive '+' in this model formula rather than the multiplicative '*'.
[^print]: `compIntercepts()` had a `print()` function for nicely printing the results. However, here we will look at each component separately to ease comparison with the `emtrends()` results.
[^pvalues]: `emmeans` does not compute p-values by default.
