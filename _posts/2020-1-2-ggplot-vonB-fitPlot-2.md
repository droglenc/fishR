---
title: "von Bertalanffy Growth Plots II"
layout: post
date: "January 2, 2020"
output:
  html_document
tags:
- R
- ggplot
- von_Bertalanffy
- Growth

---




----

## Introduction


{% highlight r %}
library(FSAdata) # for data
library(FSA)     # for vbFuns(), vbStarts(), confint.bootCase()
library(car)     # for Boot()
library(dplyr)   # for filter(), mutate()
library(ggplot2)
{% endhighlight %}

In [a previous post](http://derekogle.com/fishR/2019-12-31-ggplot-vonB-fitplot-1) I demonstrated how to make a plot that illustrated the fit of a von Bertalanffy growth function (VBGF) to data. In this post, I will demonstrate how to show the VBGF fits for two or more groups (e.g., sexes, locations, years). Here I will again use the lengths and ages of Lake Erie Walleye (*Sander vitreus*) captured during October-November, 2003-2014. These data are available in my [`FSAdata` package](https://github.com/droglenc/FSAdata) and formed many of the examples in Chapter 12 of the [**Age and Growth of Fishes: Principles and Techniques book**](https://derekogle.com/AGF/). My primary interest is in the `tl` (total length in mm), `age`, and `sex` variables ([see here for more details](https://derekogle.com/fishR/data/data-html/WalleyeErie2.html)). I will focus initially on Walleye from location "1" captured in 2014 (as an example).


{% highlight r %}
data(WalleyeErie2)
w14T <- filter(WalleyeErie2,year==2014,loc==1)
{% endhighlight %}

The workflow below requires the `predict2()` and `vb()` functions that were created in the previous post.


{% highlight r %}
vb <- vbFuns()
predict2 <- function(x) predict(x,data.frame(age=ages))
{% endhighlight %}

&nbsp;

## Fitting all von Bertalanffy Growth Functions

The key to constructing plots with multiple VBGF trajectories is to create a "long format" data.frame of predicted mean lengths-at-age with associated bootstrap confidence intervals. In this format one row corresponds to a single "group" and age with columns (variabls) that identify the "group", age", predicted mean length, and the lower and upper values for the confidence interval. There is likely many ways to construct such a data.frame, but a loop over the "groups" (i.e., sexes) is used below

Begin by finding the range of ages for both sexes so that the confidence polygon can be restricted to observed ages.


{% highlight r %}
agesum <- group_by(w14T,sex) %>%
  summarize(minage=min(age),maxage=max(age))
agesum
{% endhighlight %}



{% highlight text %}
## # A tibble: 2 x 3
##   sex    minage maxage
##   <fct>   <int>  <int>
## 1 female      0     11
## 2 male        1     11
{% endhighlight %}

To simplify coding below, the levels and number of "groups" are saved into objects.

{% highlight r %}
( sexes <- levels(w14T$sex) )
{% endhighlight %}



{% highlight text %}
## [1] "female" "male"
{% endhighlight %}



{% highlight r %}
( nsexes <- length(sexes) )
{% endhighlight %}



{% highlight text %}
## [1] 2
{% endhighlight %}

In the loop across sexes, the VBGF will be fit for each sex and parameter estimates will be saved into `cfs`, confidence intervals for the parameter estimates into `cis`, predicted mean lengths-at-age for all ages considered in `preds1`, and predicted mean lengths-at-age for only observed ages in `preds2`. These objects are initialized with `NULL` prior to starting the loop.[^paramsNotNeeded]

{% highlight r %}
cfs <- cis <- preds1 <- preds2 <- NULL
{% endhighlight %}

The code inside the loop follows the same logic as shown in [the previous post](http://derekogle.com/fishR/2019-12-31-ggplot-vonB-fitplot-1) for fitting the VBGF to one group.[^loopNote]


{% highlight r %}
for (i in 1:nsexes) {
  ## Loop notification (for peace of mind)
  cat(sexes[i],"Loop\n")
  ## Isolate sex's data
  tmp1 <- filter(w14T,sex==sexes[i])
  ## Fit von B to that sex
  sv1 <- vbStarts(tl~age,data=tmp1)
  fit1 <- nls(tl~vb(age,Linf,K,t0),data=tmp1,start=sv1)
  ## Extract and store parameter estimates and CIs
  cfs <- rbind(cfs,coef(fit1))
  boot1 <- Boot(fit1)
  tmp2 <-  confint(boot1)
  cis <- rbind(cis,c(tmp2["Linf",],tmp2["K",],tmp2["t0",]))
  ## Predict mean lengths-at-age with CIs
  ##   preds1 -> across all ages
  ##   preds2 -> across observed ages only
  ages <- seq(-1,12,0.2)
  boot2 <- Boot(fit1,f=predict2)
  tmp2 <- data.frame(sex=sexes[i],age=ages,
                     predict(fit1,data.frame(age=ages)),
                     confint(boot2))
  preds1 <- rbind(preds1,tmp2)
  tmp2 <- filter(tmp2,age>=agesum$minage[i],age<=agesum$maxage[i])
  preds2 <- rbind(preds2,tmp2)
}
{% endhighlight %}



{% highlight text %}
## female Loop
{% endhighlight %}



{% highlight text %}
## Error in eval(object$data): object 'tmp1' not found
{% endhighlight %}

The `cfs`, `cis`, `preds1`, and `preds2` objects will have poorly named rows, columns, or both after the loop. These deficiencies are corrected below.

{% highlight r %}
rownames(cfs) <- rownames(cis) <- sexes
{% endhighlight %}



{% highlight text %}
## Error in `rownames<-`(`*tmp*`, value = c("female", "male")): attempt to set 'rownames' on an object with no dimensions
{% endhighlight %}



{% highlight r %}
colnames(cis) <- paste(rep(c("Linf","K","t0"),each=2),
                       rep(c("LCI","UCI"),times=2),sep=".")
{% endhighlight %}



{% highlight text %}
## Error in `colnames<-`(`*tmp*`, value = c("Linf.LCI", "Linf.UCI", "K.LCI", : attempt to set 'colnames' on an object with less than two dimensions
{% endhighlight %}



{% highlight r %}
colnames(preds1) <- colnames(preds2) <- c("sex","age","fit","LCI","UCI")
{% endhighlight %}



{% highlight text %}
## Error in `colnames<-`(`*tmp*`, value = c("sex", "age", "fit", "LCI", "UCI": attempt to set 'colnames' on an object with less than two dimensions
{% endhighlight %}

The `preds1` and `preds2` objects now contain the predicted mean lengths-at-age with associated confidence intervals in the desired long format.

{% highlight r %}
headtail(preds1) # predicted lengths-at-age w/ CIs for ALL ages
{% endhighlight %}



{% highlight text %}
## Error: 'x' must be a matrix or data.frame.
{% endhighlight %}



{% highlight r %}
headtail(preds2) # predicted lengths-at-age w/ CIs for OBSERVED ages
{% endhighlight %}



{% highlight text %}
## Error: 'x' must be a matrix or data.frame.
{% endhighlight %}

&nbsp;

## Multiple VBGFs on One Plot

Constructing the plot with multiple VBGF trajectories is similar to what was shown for one group in [the previous post](http://derekogle.com/fishR/2019-12-31-ggplot-vonB-fitplot-1). Note, however, that colors will depend on the sex variable for the confidence polygon because of `fill=sex` in `geom_ribbon()`, the points because of `color=sex` in `geom_point()`, and the lines because of `color=sex` in `geom_line()`. The default colors can be changed in a variety of ways but are set manually to two colors for both fill and color aesthetics below with `scale_color_manual()`.[^chooseColors] Also note that `position_dodge()` is used in `geom_point()` to shift the points for the groups slightly left and right to minimize overlap of points between groups. Finally, `legend.position=` in `theme()` is used to place the legend inside the plot centered at approximately 80% of the way along the x-axis and 20% of the way up the y-axis, and `legend.title=` removes the title on the legend (was just the word "sex").


{% highlight r %}
vbFitPlot1 <- ggplot() + 
  geom_ribbon(data=preds2,aes(x=age,ymin=LCI,ymax=UCI,fill=sex),alpha=0.2) +
  geom_point(data=w14T,aes(y=tl,x=age,color=sex),alpha=0.25,size=2,
             position=position_dodge(width=0.2)) +
  geom_line(data=preds1,aes(y=fit,x=age,color=sex),size=1,linetype=2) +
  geom_line(data=preds2,aes(y=fit,x=age,color=sex),size=1) +
  scale_color_manual(values=c('#00429d', '#93003a'),
                     aesthetics=c("fill","color")) +
  scale_y_continuous(name="Total Length (mm)",limits=c(0,700),expand=c(0,0)) +
  scale_x_continuous(name="Age (years)",expand=c(0,0),
                     limits=c(-1,12),breaks=seq(0,12,2)) +
  theme_bw() +
  theme(panel.grid=element_blank(),
        legend.position=c(0.8,0.2),
        legend.title=element_blank())
vbFitPlot1
{% endhighlight %}



{% highlight text %}
## Error in FUN(X[[i]], ...): object 'age' not found
{% endhighlight %}

![plot of chunk vbCompFit1](http://derekogle.com/fishR/figures/vbCompFit1-1.png)

Some people may prefer to just see model fits. If so, then simply omit `geom_point()`.


{% highlight r %}
vbFitPlot2 <- ggplot() + 
  geom_ribbon(data=preds2,aes(x=age,ymin=LCI,ymax=UCI,fill=sex),alpha=0.2) +
  geom_line(data=preds1,aes(y=fit,x=age,color=sex),size=1,linetype=2) +
  geom_line(data=preds2,aes(y=fit,x=age,color=sex),size=1) +
  scale_color_manual(values=c('#00429d', '#93003a'),
                     aesthetics=c("fill","color")) +
  scale_y_continuous(name="Total Length (mm)",limits=c(0,700),expand=c(0,0)) +
  scale_x_continuous(name="Age (years)",expand=c(0,0),
                     limits=c(-1,12),breaks=seq(0,12,2)) +
  theme_bw() +
  theme(panel.grid=element_blank(),
        legend.position=c(0.8,0.2),
        legend.title=element_blank())
vbFitPlot2
{% endhighlight %}



{% highlight text %}
## Error in FUN(X[[i]], ...): object 'age' not found
{% endhighlight %}

![plot of chunk vbCompFit2](http://derekogle.com/fishR/figures/vbCompFit2-1.png)

&nbsp;

## Multiple VBGFs in Separate Plots
An alternative to putting multiple VBGF trajectories in one plot is to separate them into individual plots. This is easily handled by including the "grouping" variable name within `vars()` within `facet_wrap()`.[^removedColors]


{% highlight r %}
vbFitPlot3 <- ggplot() + 
  geom_ribbon(data=preds2,aes(x=age,ymin=LCI,ymax=UCI),alpha=0.2) +
  geom_point(data=w14T,aes(y=tl,x=age),alpha=0.25,size=2) +
  geom_line(data=preds1,aes(y=fit,x=age),size=1,linetype=2) +
  geom_line(data=preds2,aes(y=fit,x=age),size=1) +
  scale_y_continuous(name="Total Length (mm)",limits=c(0,700),expand=c(0,0)) +
  scale_x_continuous(name="Age (years)",expand=c(0,0),
                     limits=c(-1,12),breaks=seq(0,12,2)) +
  facet_wrap(vars(sex)) +
  theme_bw() +
  theme(panel.grid=element_blank())
vbFitPlot3
{% endhighlight %}



{% highlight text %}
## Error in if (empty(data)) {: missing value where TRUE/FALSE needed
{% endhighlight %}

![plot of chunk vbFitFacet1](http://derekogle.com/fishR/figures/vbFitFacet1-1.png)

Faceting is more interesting when there are more "groups." The plot below shows different VBGF fits across all available years for female Walleye from location "1."  The code is basically the same as above (i.e., strategically replacing `sex` with `fyear` and making sure to use the new data.frame).

{% highlight r %}
wfT <- filter(WalleyeErie2,sex=="female",loc==1)

agesum <- group_by(wfT,year) %>%
  summarize(minage=min(age),maxage=max(age))

years <- unique(wfT$year)
nyears <- length(years)

cfs <- cis <- preds1 <- preds2 <- NULL

for (i in 1:nyears) {
  ## Loop notification (for peace of mind)
  cat(years[i],"Loop\n")
  ## Isolate year's data
  tmp1 <- filter(wfT,year==years[i])
  ## Fit von B to that year
  sv1 <- vbStarts(tl~age,data=tmp1)
  fit1 <- nls(tl~vb(age,Linf,K,t0),data=tmp1,start=sv1)
  ## Extract and store parameter estimates and CIs
  cfs <- rbind(cfs,coef(fit1))
  boot1 <- Boot(fit1)
  tmp2 <-  confint(boot1)
  cis <- rbind(cis,c(tmp2["Linf",],tmp2["K",],tmp2["t0",]))
  ## Predict mean lengths-at-age with CIs
  ##   preds1 -> across all ages
  ##   preds2 -> across observed ages only
  ages <- seq(-1,16,0.2)
  boot2 <- Boot(fit1,f=predict2)
  tmp2 <- data.frame(year=years[i],age=ages,
                     predict(fit1,data.frame(age=ages)),
                     confint(boot2))
  preds1 <- rbind(preds1,tmp2)
  tmp2 <- filter(tmp2,age>=agesum$minage[i],age<=agesum$maxage[i])
  preds2 <- rbind(preds2,tmp2)
}
{% endhighlight %}



{% highlight text %}
## 2003 Loop
{% endhighlight %}



{% highlight text %}
## Error in eval(object$data): object 'tmp1' not found
{% endhighlight %}



{% highlight r %}
rownames(cfs) <- rownames(cis) <- years
{% endhighlight %}



{% highlight text %}
## Error in `rownames<-`(`*tmp*`, value = 2003:2014): attempt to set 'rownames' on an object with no dimensions
{% endhighlight %}



{% highlight r %}
colnames(cis) <- paste(rep(c("Linf","K","t0"),each=2),
                       rep(c("LCI","UCI"),times=2),sep=".")
{% endhighlight %}



{% highlight text %}
## Error in `colnames<-`(`*tmp*`, value = c("Linf.LCI", "Linf.UCI", "K.LCI", : attempt to set 'colnames' on an object with less than two dimensions
{% endhighlight %}



{% highlight r %}
colnames(preds1) <- colnames(preds2) <- c("year","age","fit","LCI","UCI")
{% endhighlight %}



{% highlight text %}
## Error in `colnames<-`(`*tmp*`, value = c("year", "age", "fit", "LCI", : attempt to set 'colnames' on an object with less than two dimensions
{% endhighlight %}


{% highlight r %}
vbFitPlot4 <- ggplot() + 
  geom_ribbon(data=preds2,aes(x=age,ymin=LCI,ymax=UCI),alpha=0.2) +
  geom_point(data=wfT,aes(y=tl,x=age),alpha=0.25,size=2) +
  geom_line(data=preds1,aes(y=fit,x=age),size=1,linetype=2) +
  geom_line(data=preds2,aes(y=fit,x=age),size=1) +
  scale_y_continuous(name="Total Length (mm)",limits=c(0,800),expand=c(0,0)) +
  scale_x_continuous(name="Age (years)",expand=c(0,0),
                     limits=c(-1,17),breaks=seq(0,16,2)) +
  facet_wrap(vars(year),ncol=3) +
  theme_bw() +
  theme(panel.grid=element_blank())
vbFitPlot4
{% endhighlight %}



{% highlight text %}
## Error in if (empty(data)) {: missing value where TRUE/FALSE needed
{% endhighlight %}

![plot of chunk vbFitFacet2](http://derekogle.com/fishR/figures/vbFitFacet2-1.png)

&nbsp;

## BONUS -- Plots of Parameter Estimates
A bonus for keeping track of the parameter point and interval estimates through this entire post is to plot the estimates across years. I will leave this up to you to decipher, but note that the years must be added to the `cfs` and `cis` data.frames to make the plot shown here.

{% highlight r %}
( cfs <- data.frame(year=years,cfs) )
{% endhighlight %}



{% highlight text %}
##    year     Linf        K       t0
## 1  2003 540.1804 1.684325 1.077078
## 2  2004 540.1804 1.684325 1.077078
## 3  2005 540.1804 1.684325 1.077078
## 4  2006 540.1804 1.684325 1.077078
## 5  2007 540.1804 1.684325 1.077078
## 6  2008 540.1804 1.684325 1.077078
## 7  2009 540.1804 1.684325 1.077078
## 8  2010 540.1804 1.684325 1.077078
## 9  2011 540.1804 1.684325 1.077078
## 10 2012 540.1804 1.684325 1.077078
## 11 2013 540.1804 1.684325 1.077078
## 12 2014 540.1804 1.684325 1.077078
{% endhighlight %}



{% highlight r %}
( cis <- data.frame(year=years,cis) )
{% endhighlight %}



{% highlight text %}
## Error in data.frame(year = years, cis): arguments imply differing number of rows: 12, 0
{% endhighlight %}


{% highlight r %}
p.Linfs <- ggplot() +
  geom_point(data=cfs,aes(x=year,y=Linf)) +
  geom_line(data=cfs,aes(x=year,y=Linf),color="gray80") +
  geom_errorbar(data=cis,aes(x=year,ymin=Linf.LCI,ymax=Linf.UCI),width=0.3) +
  scale_y_continuous(name=expression(L[infinity])) +
  scale_x_continuous(name="Year",breaks=years) +
  theme_bw() +
  theme(panel.grid=element_blank(),
        axis.text.x=element_text(angle=90,vjust=0.5))
p.Linfs
{% endhighlight %}



{% highlight text %}
## Error in FUN(X[[i]], ...): object 'year' not found
{% endhighlight %}

![plot of chunk LinfPlot](http://derekogle.com/fishR/figures/LinfPlot-1.png)

This is repeated for the other two parameters.

{% highlight r %}
p.K <- ggplot() +
  geom_point(data=cfs,aes(x=year,y=K)) +
  geom_line(data=cfs,aes(x=year,y=K),color="gray80") +
  geom_errorbar(data=cis,aes(x=year,ymin=K.LCI,ymax=K.UCI),width=0.3) +
  scale_y_continuous(name="K") +
  scale_x_continuous(name=" ",breaks=years) +
  theme_bw() +
  theme(panel.grid=element_blank(),
        axis.text.x=element_text(angle=90,vjust=0.5))

p.t0 <- ggplot() +
  geom_point(data=cfs,aes(x=year,y=t0)) +
  geom_line(data=cfs,aes(x=year,y=t0),color="gray80") +
  geom_errorbar(data=cis,aes(x=year,ymin=t0.LCI,ymax=t0.UCI),width=0.3) +
  scale_y_continuous(name=expression(t[0])) +
  scale_x_continuous(name=" ",breaks=years) +
  theme_bw() +
  theme(panel.grid=element_blank(),
        axis.text.x=element_text(angle=90,vjust=0.5))
{% endhighlight %}

Which can then be neatly placed on top of each other with the `patchwork` package.

{% highlight r %}
library(patchwork)
p.K / p.t0 / p.Linfs
{% endhighlight %}



{% highlight text %}
## Error in FUN(X[[i]], ...): object 'year' not found
{% endhighlight %}

![plot of chunk vbParamsPlot](http://derekogle.com/fishR/figures/vbParamsPlot-1.png)

&nbsp;

## Final Thoughts

I am trying to post examples here as I learn `ggplot2`. My other `ggplot2`-related posts can be [found here](http://derekogle.com/fishR/blog/tags.html#ggplot). I will post more about `patchwork` in future posts.

&nbsp;

&nbsp;

## Footnotes

[^paramsNotNeeded]: The parameter estimates and their confidence intervals are not needed to make the plots below; however, they are often of interest so I include them here.

[^loopNote]: I inclued the notification in `cat()` as it gives me peace of mind to see where the loop is at. This is useful here because this loop can take a while given the two sets of bootstraps.

[^chooseColors]: I used <a href="https://gka.github.io/palettes/#/2|d|00429d,96ffea|ffffe0,ff005e,93003a|1|1">this resource</a> to help choose two divergent colors that were "color-blind safe."

[^removedColors]: All `fill=sex` and `color=sex` items were removed from the previous code as leaving them in would result in each facet using a different color (which is redundant with the labels).
