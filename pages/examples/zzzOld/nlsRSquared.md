





Recently, a fishR user asked me the following question:

> After fitting the age-length data into VBGM, I overviewed the results. But I can't find the coefficient of determination ($$latex r^2$$) for the VBGM fitting. Because some reviewer want the the coefficient of determination, I have to show it.

In general, the traditional ``coefficient of determination'' is not defined for non-linear regressions models.  To quote Douglas Bates from this [R-Help thread](https://stat.ethz.ch/pipermail/r-help/2002-July/023461.html) ...

> There is a good reason that an nls model fit in R does not provide
> r-squared - r-squared doesn't make sense for a general nls model.

> One way of thinking of r-squared is as a comparison of the residual sum of
> squares for the fitted model to the residual sum of squares for a trivial
> model that consists of a constant only.  You cannot guarantee that this is a
> comparison of nested models when dealing with an nls model.  If the models
> aren't nested this comparison is not terribly meaningful.

> So the answer is that you probably don't want to do this in the first place.

This [Stack Exchange thread](http://stackoverflow.com/questions/14530770/calculating-r2-for-a-nonlinear-model) also points to [this article](http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2892436/) as a reference.

At this point, I would "argue" with the referee about including an $r^2$ calculation.  If the referee only wants a measure of "fit" then I would probably just include a plot of the original data with the best-fit non-linear model super-imposed.

If the referree will not give in on this point then it is possible to exploit the usual definition of $r^2$ to develop what some call "quasi-$r^2$" values.  The code below demonstrates two ways to compute the two quasi-$r^2$ values mentioned in the Stack Exchange thread when applied to a von Bertalanffy growth model.

First, fit the model as demonstrated in the [Von Bertalanffy Growth Model (Intro) Vignette](https://5c3dc6c1-a-62cb3a1a-s-sites.googlegroups.com/site/fishrfiles/gnrl/VonBertalanffy.pdf) by loading the required packages ...


```r
library(FSA)
library(FSAdata)
```


... getting the data ...


```r
data(Croaker2)
crm <- Subset(Croaker2,sex=="M")
```


... and fitting the model ...


```r
svTypical <- vbStarts(tl~age,data=crm)
vbTypical <- tl~Linf*(1-exp(-K*(age-t0)))
fitTypical <- nls(vbTypical,data=crm,start=svTypical)
summary(fitTypical)
```

```
## 
## Formula: tl ~ Linf * (1 - exp(-K * (age - t0)))
## 
## Parameters:
##      Estimate Std. Error t value Pr(>|t|)    
## Linf  366.414     16.754   21.87   <2e-16 ***
## K       0.315      0.108    2.92   0.0042 ** 
## t0     -1.714      1.049   -1.63   0.1049    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 33.4 on 111 degrees of freedom
## 
## Number of iterations to convergence: 4 
## Achieved convergence tolerance: 3.82e-06
```


One quasi-$r^2$ is computed as the square of the correlation between the actual "y" values (lengths in this case) and the "y" values predicted from the best-fit model.  This quasi-"r^2" is computed as


```r
predtl <- predict(fitTypical)
cor(crm$tl,predtl)^2
```

```
## [1] 0.5338
```


A second quasi-$r^2$ is computed using the definition of the usual $r^2$ ...

\[ r^2 = 1-\frac{SS_{Error}}{SS_{Total}} \]

where $SS_{Error}$ is most easily computed as the sum of the squared residuals from the model fit and $SS_{Total}$, in this case, is best computed as the variance of the original "y" variable times $n-1$.  Thus, this quasi-$r^2$ is computed as


```r
SSE <- sum(residuals(fitTypical)^2)
SST <- var(crm$tl)*(length(crm$tl)-1)
1-SSE/SST
```

```
## [1] 0.5338
```


*It is not clear to me that these two calculations will always come out the same as they did here (see some of the comments in the Stack Exchange thread).*

Finally, again, I think that the plot is a more reliable summary of the model fit.


```r
fitPlot(fitTypical,xlab="Age",ylab="Total Length (mm)",main="")
```

![plot of chunk VBGMfit](figure/VBGMfit.png) 

