---
title: "Replace compSlopes() with emtrends()"
layout: post
date: "May 11, 2021"
output:
  html_document
tags:
- R
- FSA
- linear_regressions

---




----

## Introduction
The `compSlopes()` function in `FSA` (prior to v0.9.0) was used to statistically compare slopes for all pairs of groups in an indicator/dummy variable regression (I/DVR). However, the excellent `emtrends()` function in the `emmmeans` package is a more general and strongly principaled function for this purpose. As such, `compSlopes()` will be removed from the next version (0.9.0) of `FSA`.

In this post I demonstrate how to use `emtrends()` for the same purpose as `compSlopes()` was used (prior to FSA v0.9.0). **Note, however, that the results will not be identical because `compSlopes()` and `emtrends()` use different methods to correct for multiple comparisons when comparing pairs of slopes.**

&nbsp;

The `Mirex` data described [here](http://derekogle.com/FSA/reference/Mirex.html), but filtered to include just three years, will be used in this post.[^filtered]


{% highlight r %}
library(FSA)
data(Mirex)
## reduce to three years ... only for simplicity in this post
Mirex <- subset(Mirex,year>1990)
## treat year as a factor for the IVR modeling
Mirex$year <- factor(Mirex$year)
{% endhighlight %}

The `lm()` below fits the I/DVR to determine if the relationship between mirex concentration and weight of the salmon differs by year.


{% highlight r %}
lm1 <- lm(mirex~weight*year,data=Mirex)
{% endhighlight %}

The `weight:year` interaction term p-value suggests that the slopes (i.e., relationship between mirex concentration and salmon weight) differs among some pair(s) of the three years.


{% highlight r %}
anova(lm1)
{% endhighlight %}



{% highlight text %}
## Analysis of Variance Table
## 
## Response: mirex
##             Df   Sum Sq  Mean Sq F value    Pr(>F)
## weight       1 0.115886 0.115886 30.6459 1.615e-06
## year         2 0.205825 0.102912 27.2149 2.028e-08
## weight:year  2 0.042176 0.021088  5.5767   0.00694
## Residuals   44 0.166385 0.003781
{% endhighlight %}

A next step is to determine which pair(s) of slopes differ significantly.

&nbsp;

## `compSlopes()` from `FSA`
The procedure coded in `compSlopes()` is described in more detail in [this supplement](http://derekogle.com/IFAR/supplements/weightlength/index.html) to the [Introductory Fisheries Analyses with R book](https://derekogle.com/IFAR/). The results of `compSlopes()` applied to the saved `lm()` object are assigned to an object below.[^print]


{% highlight r %}
csfsa <- compSlopes(lm1)
{% endhighlight %}

The `$comparisons` component in this saved object contains the results from comparing all pairs of slopes. Each paired comparison is a row in these results with the groups being compared under `comparison`, the differences in sample slopes under `diff`, 95% confidence intervals for the difference in slopes under `95% LCI` and `95% UCI`, and unadjusted and adjusted (for multiple comparisons) p-values for the hypothesis test comparing the slopes under `p.unadj` and `p.adj`, respectively.


{% highlight r %}
csfsa$comparisons
{% endhighlight %}



{% highlight text %}
##   comparison     diff  95% LCI  95% UCI p.unadj   p.adj
## 1  1996-1992 -0.01428 -0.02581 -0.00275 0.01638 0.03276
## 2  1999-1992 -0.02267 -0.03668 -0.00867 0.00214 0.00642
## 3  1999-1996 -0.00839 -0.02020  0.00341 0.15895 0.15895
{% endhighlight %}

For example, these results suggest that the slopes for 1996 and 1992 ARE statistically different (first row), but the slopes for 1999 and 1996 are NOT statistically different (last row).

The `$slopes` component in this saved object contains results specific to each slope. The groups are under `level`, sample slopes under `slopes`, 95% confidence intervals for the slopes under `95% LCI` and `95% UCI`, and unadjusted and adjusted p-values for the test if the slope is different from 0 under `p.unadj` and `p.adj`, respectively.


{% highlight r %}
csfsa$slope
{% endhighlight %}



{% highlight text %}
##   level  slopes  95% LCI 95% UCI p.unadj   p.adj
## 3  1999 0.00386 -0.00620 0.01393 0.44342 0.44342
## 2  1996 0.01225  0.00609 0.01842 0.00024 0.00048
## 1  1992 0.02653  0.01679 0.03628 0.00000 0.00000
{% endhighlight %}

For example, the slope for 1992 (last row) appears to be significantly different than 0 and may be between 0.01679 and 0.03628.

&nbsp;

## `emtrends()` from `emmeans`
Similar results can be obtained with `emtrends()` from `emmeans` using the fitted `lm()` object as the first argument, a `specs=` argument with `pairwise~` followed by the name of the factor variable from the `lm()` model (`year` in this case), and `var=` followed by the name of the covariate from the `lm()` model (`weight` in this case), which **must** be in quotes.


{% highlight r %}
library(emmeans)
cs <- emtrends(lm1,specs=pairwise~year,var="weight")
{% endhighlight %}

The object saved from `emtrends()` is then given as the first argument to `summary()`, which also requires `infer=TRUE` if you would like p-values to be calculated.[^pvalues]


{% highlight r %}
css <- summary(cs,infer=TRUE)
{% endhighlight %}

The `$contrasts` component in this saved object contains the results for comparing all pairs of slopes. Each paired comparison is a row with the groups compared under `contrasts`, the difference in sample slopes under `diff`, the standard error of the difference in sample slopes under `SE`, the degrees-of-freedom under `df`, a 95% confidence interval for the difference in slopes under `lower.CL` and `upper.CL`, and the t test statistic and p-value adjusted for multiple comparisons for testing a difference in slopes under `t.ratio` and `p.value`, respectively.


{% highlight r %}
css$contrasts
{% endhighlight %}



{% highlight text %}
##  contrast    estimate      SE df  lower.CL upper.CL t.ratio
##  1992 - 1996  0.01428 0.00572 44  0.000403   0.0282 2.496  
##  1992 - 1999  0.02267 0.00695 44  0.005815   0.0395 3.262  
##  1996 - 1999  0.00839 0.00586 44 -0.005813   0.0226 1.433  
##  p.value
##  0.0425 
##  0.0059 
##  0.3331 
## 
## Confidence level used: 0.95 
## Conf-level adjustment: tukey method for comparing a family of 3 estimates 
## P value adjustment: tukey method for comparing a family of 3 estimates
{% endhighlight %}

Comparing these results to the `$comparison` component from `compSlopes()` shows that the sample slopes are the same, but that the confidence interval values and p-values are slightly different. Again, this is due to `emtrends()` and `compSlopes()` using different methods of adjusting for multiple comparisons. These differences did not result in different conclusions in this case, but they could, especially if the p-values are near the rejection criterion.

The `$emtrends` component contains results for each slope with the groups under the name of the factor variable (`year` in this example), the sample slopes under `xxx.trend` (where `xxx` is replaced with the name of the covariate variable, `weight` in this example), standard errors of the sample slopes under `SE`, degrees-of-freedom under `df`, 95% confidence intervals for the slope under `lower.CL` and `upper.CL`, and t test statistics and p-values adjusted for multiple comparisons for testing that the slope is not equal to zero under `t.ratio` and `p.adj`, respectively.


{% highlight r %}
css$emtrends
{% endhighlight %}



{% highlight text %}
##  year weight.trend      SE df lower.CL upper.CL t.ratio p.value
##  1992      0.02653 0.00483 44  0.01679   0.0363 5.489   <.0001 
##  1996      0.01225 0.00306 44  0.00609   0.0184 4.004   0.0002 
##  1999      0.00386 0.00499 44 -0.00620   0.0139 0.773   0.4434 
## 
## Confidence level used: 0.95
{% endhighlight %}

Here the results match exactly with those in the `$slopes` component of `compSlopes()`.

&nbsp;

## Conclusion
The `emtrends()` function in the `emmeans` package provides a more general solution to comparing multiple slopes than what was used in `compSlopes()` in the `FSA` package (prior to v0.9.0). Thus, `compSlopes()` will be removed from FSA with v0.9.0. You should use `emtrends()` instead.

The `emmeans` package has extensive vignettes that further exaplain its use. For this use case see [this discussion](https://cran.r-project.org/web/packages/emmeans/vignettes/interactions.html#covariates). Their ["Basics" vignette](https://cran.r-project.org/web/packages/emmeans/vignettes/basics.html) is also useful.

Note that this change to `FSA` does not affect anything in the published [Introductory Fisheries Analyses with R](https://derekogle.com/IFAR/) book. However, the specific analysis in [this supplement](http://derekogle.com/IFAR/supplements/weightlength/index.html) to the book will no longer work as described. The use of `compSlopes()` there will need to be replaced with `emtrends()`.

In the next post I will demonstrate how to use `emmeans()` from the `emmeans` package to replace `compIntercepts()`, which will also be removed from the next version of `FSA`.

&nbsp;

&nbsp;

## Footnotes

[^filtered]: I filtered the data to only three years to reduce the amount of output below to make it easier to follow the main concepts.
[^print]: `compSlopes()` had a `print()` function for nicely printing the results. However, here we will look at each component separately to ease comparison with the `emtrends()` results.
[^pvalues]: `emmeans` does not compute p-values by default.
