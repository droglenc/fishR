





[In my last post](http://fishr.wordpress.com/2013/11/19/a-problem-fitting-the-von-bertalanffy-growth-model-with-nls/), I suggested that the Francis parameterization of the von Bertalanffy growth model may be used in cases where the typical parameterization did not converge (likely due to issues related to highly correlated parameters and data with lengths that are highly variable within ages and the full curvature of the model is not readily apparent because the data are truncated for some reason (e.g., high mortality rates, size-selective gear)).  A follow-up question to [that post](http://fishr.wordpress.com/2013/11/19/a-problem-fitting-the-von-bertalanffy-growth-model-with-nls/) is how to compare parameter estimates between sexes when using the Francis parameterization.  This is largely the same as the demonstration for the typical parameterization in the [Von Bertalanffy Growth - Intro Vignette](http://fishr.wordpress.com/vignettes/) on the [fishR](http://fishr.wordpress.com/) page except, of course, that the user must write out the more bulky Francis parameterization.  This post is a demonstration of the required code (with few comments as most of this is generally described in the [Von Bertalanffy Growth - Intro Vignette](http://fishr.wordpress.com/vignettes/)).

## Preliminaries and Data Manipulation ##
Begin by loading the **FSA** package, ...


```r
library(FSA)
```


the data (note that the working direction would have been set before `read.csv()`), ...


```r
df <- read.csv("BKData.csv",header=TRUE)
str(df)
```

```
## 'data.frame':	55 obs. of  12 variables:
##  $ Primary_Code        : Factor w/ 3 levels "SH091613BK","SH091813BK",..: 3 3 3 3 3 1 1 1 1 1 ...
##  $ Location            : Factor w/ 1 level "SH": 1 1 1 1 1 1 1 1 1 1 ...
##  $ Date                : Factor w/ 3 levels "16-Oct-12","16-Sep-13",..: 1 1 1 1 1 2 2 2 2 2 ...
##  $ Transect            : Factor w/ 6 levels "SHWPBTEF03","SHWPHONT02",..: 1 1 1 1 1 3 3 6 6 6 ...
##  $ Replicate           : int  NA NA NA NA NA 1 1 1 1 1 ...
##  $ Species             : Factor w/ 1 level "CHC": 1 1 1 1 1 1 1 1 1 1 ...
##  $ Length              : int  526 227 214 226 508 501 486 732 630 588 ...
##  $ Weight              : int  1519 86 70 85 1223 1156 993 3655 2326 1528 ...
##  $ ID_Code             : Factor w/ 50 levels "A1","A10","A11",..: 5 6 7 8 1 6 9 19 21 22 ...
##  $ Age                 : int  7 1 1 1 10 7 10 16 10 9 ...
##  $ Sex                 : Factor w/ 3 levels "","Female","Male": 1 1 1 1 2 2 2 2 2 2 ...
##  $ Collection_Technique: Factor w/ 2 levels "BTEF","HONT": 1 1 1 1 1 2 2 2 2 2 ...
```

```r
levels(df$Sex)
```

```
## [1] ""       "Female" "Male"
```


and remove the four unknown sex individuals ...


```r
df1 <- Subset(df,Sex!="")
dim(df1)
```

```
## [1] 51 12
```



## Model Preparation ##
Declare all possible models, ...

```r
frGen <- Length~L1[Sex]+(L3[Sex]-L1[Sex])*(1-((L3[Sex]-L2[Sex])/(L2[Sex]-L1[Sex]))^(2*(Age-t1)/(t3-t1)))/(1-((L3[Sex]-L2[Sex])/(L2[Sex]-L1[Sex]))^2)
fr12 <- Length~L1[Sex]+(L3-L1[Sex])*(1-((L3-L2[Sex])/(L2[Sex]-L1[Sex]))^(2*(Age-t1)/(t3-t1)))/(1-((L3-L2[Sex])/(L2[Sex]-L1[Sex]))^2)
fr13 <- Length~L1[Sex]+(L3[Sex]-L1[Sex])*(1-((L3[Sex]-L2)/(L2-L1[Sex]))^(2*(Age-t1)/(t3-t1)))/(1-((L3[Sex]-L2)/(L2-L1[Sex]))^2)
fr23 <- Length~L1+(L3[Sex]-L1)*(1-((L3[Sex]-L2[Sex])/(L2[Sex]-L1))^(2*(Age-t1)/(t3-t1)))/(1-((L3[Sex]-L2[Sex])/(L2[Sex]-L1))^2)
fr1 <- Length~L1[Sex]+(L3-L1[Sex])*(1-((L3-L2)/(L2-L1[Sex]))^(2*(Age-t1)/(t3-t1)))/(1-((L3-L2)/(L2-L1[Sex]))^2)
fr2 <- Length~L1+(L3-L1)*(1-((L3-L2[Sex])/(L2[Sex]-L1))^(2*(Age-t1)/(t3-t1)))/(1-((L3-L2[Sex])/(L2[Sex]-L1))^2)
fr3 <- Length~L1+(L3[Sex]-L1)*(1-((L3[Sex]-L2)/(L2-L1))^(2*(Age-t1)/(t3-t1)))/(1-((L3[Sex]-L2)/(L2-L1))^2)
frCom <- Length~L1+(L3-L1)*(1-((L3-L2)/(L2-L1))^(2*(Age-t1)/(t3-t1)))/(1-((L3-L2)/(L2-L1))^2)
```


choose the youngest (`t1`) and oldest (`t3`) ages to use in the models, ...

```r
t1 <- 5
t3 <- 12
```


find starting values for the ``all parameters in common'' model, ...

```r
( svCom <- vbStarts(Length~Age,data=df1,type="Francis",tFrancis=c(t1,t3),methEV="poly") )
```

```
## $L1
## [1] 443.8
## 
## $L2
## [1] 542.2
## 
## $L3
## [1] 602.7
```


and expand those starting values for use with each possible model ...

```r
svGen <- lapply(svCom,rep,2)
sv12 <- mapply(rep,svCom,c(2,2,1))
sv13 <- mapply(rep,svCom,c(2,1,2))
sv23 <- mapply(rep,svCom,c(1,2,2))
sv1 <- mapply(rep,svCom,c(2,1,1))
sv2 <- mapply(rep,svCom,c(1,2,1))
sv3 <- mapply(rep,svCom,c(1,1,2))
```


## Fit All Models ##
Fit the general, one parameter in common, two parameters in common, and all parameters in common models declared above to the data ...

```r
fitGen <- nls(frGen,data=df1,start=svGen) 
fit12 <- nls(fr12,data=df1,start=sv12) 
fit13 <- nls(fr13,data=df1,start=sv13) 
fit23 <- nls(fr23,data=df1,start=sv23) 
fit1 <- nls(fr1,data=df1,start=sv1) 
fit2 <- nls(fr2,data=df1,start=sv2) 
fit3 <- nls(fr3,data=df1,start=sv3) 
fitCom <- nls(frCom,data=df1,start=svCom) 
```


## Model Comparisons ##
Compare each pair of "one parameter in common" models ...

```r
anova(fit12,fitGen)
```

```
## Analysis of Variance Table
## 
## Model 1: Length ~ L1[Sex] + (L3 - L1[Sex]) * (1 - ((L3 - L2[Sex])/(L2[Sex] - L1[Sex]))^(2 * (Age - t1)/(t3 - t1)))/(1 - ((L3 - L2[Sex])/(L2[Sex] - L1[Sex]))^2)
## Model 2: Length ~ L1[Sex] + (L3[Sex] - L1[Sex]) * (1 - ((L3[Sex] - L2[Sex])/(L2[Sex] - L1[Sex]))^(2 * (Age - t1)/(t3 - t1)))/(1 - ((L3[Sex] - L2[Sex])/(L2[Sex] - L1[Sex]))^2)
##   Res.Df Res.Sum Sq Df Sum Sq F value Pr(>F)
## 1     46     243467                         
## 2     45     239038  1   4429    0.83   0.37
```

```r
anova(fit13,fitGen)
```

```
## Analysis of Variance Table
## 
## Model 1: Length ~ L1[Sex] + (L3[Sex] - L1[Sex]) * (1 - ((L3[Sex] - L2)/(L2 - L1[Sex]))^(2 * (Age - t1)/(t3 - t1)))/(1 - ((L3[Sex] - L2)/(L2 - L1[Sex]))^2)
## Model 2: Length ~ L1[Sex] + (L3[Sex] - L1[Sex]) * (1 - ((L3[Sex] - L2[Sex])/(L2[Sex] - L1[Sex]))^(2 * (Age - t1)/(t3 - t1)))/(1 - ((L3[Sex] - L2[Sex])/(L2[Sex] - L1[Sex]))^2)
##   Res.Df Res.Sum Sq Df Sum Sq F value Pr(>F)  
## 1     46     268444                           
## 2     45     239038  1  29406    5.54  0.023 *
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

```r
anova(fit23,fitGen)
```

```
## Analysis of Variance Table
## 
## Model 1: Length ~ L1 + (L3[Sex] - L1) * (1 - ((L3[Sex] - L2[Sex])/(L2[Sex] - L1))^(2 * (Age - t1)/(t3 - t1)))/(1 - ((L3[Sex] - L2[Sex])/(L2[Sex] - L1))^2)
## Model 2: Length ~ L1[Sex] + (L3[Sex] - L1[Sex]) * (1 - ((L3[Sex] - L2[Sex])/(L2[Sex] - L1[Sex]))^(2 * (Age - t1)/(t3 - t1)))/(1 - ((L3[Sex] - L2[Sex])/(L2[Sex] - L1[Sex]))^2)
##   Res.Df Res.Sum Sq Df Sum Sq F value Pr(>F)
## 1     46     248698                         
## 2     45     239038  1   9660    1.82   0.18
```

From this it is seen that there is no difference in the L3 or $latex L_{1}$ parameters but there may be in the L2 parameter.  The model with L3 in common (i.e., `fit12`) fits slightly better (lower RSS) then the model with $latex L_{1}$ in common, so the following tests will compare the two two parameter in common models that also have L3 in common to the model with only L3 in common ...

```r
anova(fit1,fit12)
```

```
## Analysis of Variance Table
## 
## Model 1: Length ~ L1[Sex] + (L3 - L1[Sex]) * (1 - ((L3 - L2)/(L2 - L1[Sex]))^(2 * (Age - t1)/(t3 - t1)))/(1 - ((L3 - L2)/(L2 - L1[Sex]))^2)
## Model 2: Length ~ L1[Sex] + (L3 - L1[Sex]) * (1 - ((L3 - L2[Sex])/(L2[Sex] - L1[Sex]))^(2 * (Age - t1)/(t3 - t1)))/(1 - ((L3 - L2[Sex])/(L2[Sex] - L1[Sex]))^2)
##   Res.Df Res.Sum Sq Df Sum Sq F value Pr(>F)  
## 1     47     269584                           
## 2     46     243467  1  26117    4.93  0.031 *
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

```r
anova(fit2,fit12)
```

```
## Analysis of Variance Table
## 
## Model 1: Length ~ L1 + (L3 - L1) * (1 - ((L3 - L2[Sex])/(L2[Sex] - L1))^(2 * (Age - t1)/(t3 - t1)))/(1 - ((L3 - L2[Sex])/(L2[Sex] - L1))^2)
## Model 2: Length ~ L1[Sex] + (L3 - L1[Sex]) * (1 - ((L3 - L2[Sex])/(L2[Sex] - L1[Sex]))^(2 * (Age - t1)/(t3 - t1)))/(1 - ((L3 - L2[Sex])/(L2[Sex] - L1[Sex]))^2)
##   Res.Df Res.Sum Sq Df Sum Sq F value Pr(>F)  
## 1     47     260197                           
## 2     46     243467  1  16730    3.16  0.082 .
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

These results suggest that L2 differs between sexes and, perhaps, that $latex L_{1}$ also differs between sexes depending on the level of alpha that one is using.  It is probably reasonable to use an alpha of 0.1 with this type of data because of the high degree of variability in lengths and the likely interest in whether there is even a slight difference between sexes.  Of course, alpha should have been set way before this stage (i.e., way before looking at the results).  I will continue assuming that alpha was 0.05 and that these results show that only L2 differs between sexes.

Now compare the model with $latex L_{1}$ and L3, but not L2, in common to the model with no differences between sexes to confirm that L2 differs between the sexes ...

```r
anova(fitCom,fit2)
```

```
## Analysis of Variance Table
## 
## Model 1: Length ~ L1 + (L3 - L1) * (1 - ((L3 - L2)/(L2 - L1))^(2 * (Age - t1)/(t3 - t1)))/(1 - ((L3 - L2)/(L2 - L1))^2)
## Model 2: Length ~ L1 + (L3 - L1) * (1 - ((L3 - L2[Sex])/(L2[Sex] - L1))^(2 * (Age - t1)/(t3 - t1)))/(1 - ((L3 - L2[Sex])/(L2[Sex] - L1))^2)
##   Res.Df Res.Sum Sq Df Sum Sq F value Pr(>F)
## 1     48     272966                         
## 2     47     260197  1  12769    2.31   0.14
```

This model suggests that all parameters in common is a better model.  This, however, is inconsistent with what was seen above.  Perhaps the inconsistency comes from the fact that both L1 and L2 should be allowed to differ.  Thus, try comparing the model with separate L1 and L2 parameters to the model with all parameters in common.


```r
anova(fitCom,fit12)
```

```
## Analysis of Variance Table
## 
## Model 1: Length ~ L1 + (L3 - L1) * (1 - ((L3 - L2)/(L2 - L1))^(2 * (Age - t1)/(t3 - t1)))/(1 - ((L3 - L2)/(L2 - L1))^2)
## Model 2: Length ~ L1[Sex] + (L3 - L1[Sex]) * (1 - ((L3 - L2[Sex])/(L2[Sex] - L1[Sex]))^(2 * (Age - t1)/(t3 - t1)))/(1 - ((L3 - L2[Sex])/(L2[Sex] - L1[Sex]))^2)
##   Res.Df Res.Sum Sq Df Sum Sq F value Pr(>F)  
## 1     48     272966                           
## 2     46     243467  2  29499    2.79  0.072 .
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

There is some, but not significant evidence, for a difference in the L1 and L2 parameters between the sexes.  Thus, this ultimately shows that a single model would best fit both sexes.


The AIC results suggest that the $latex L_{1}$ and L2 parameters differ between the sexes ...

```r
AIC(fitGen,fit12,fit13,fit23,fit1,fit2,fit3,fitCom)
```

```
##        df   AIC
## fitGen  7 589.8
## fit12   6 588.7
## fit13   6 593.7
## fit23   6 589.8
## fit1    5 591.9
## fit2    5 590.1
## fit3    5 592.6
## fitCom  4 590.6
```


Thus, the AIC results suggest (though not stronlgy) that the mean length of males and females differs at age-8.5, potentially differ at age-5, but do not differ at age-12.  The coefficient results from the best-fit model(s) give an indication of the difference in mean lengths at 


```r
summary(fit12)
```

```
## 
## Formula: Length ~ L1[Sex] + (L3 - L1[Sex]) * (1 - ((L3 - L2[Sex])/(L2[Sex] - 
##     L1[Sex]))^(2 * (Age - t1)/(t3 - t1)))/(1 - ((L3 - L2[Sex])/(L2[Sex] - 
##     L1[Sex]))^2)
## 
## Parameters:
##     Estimate Std. Error t value Pr(>|t|)    
## L11    389.8       46.0    8.48  5.9e-11 ***
## L12    466.8       19.1   24.47  < 2e-16 ***
## L21    502.6       17.4   28.85  < 2e-16 ***
## L22    548.8       14.3   38.45  < 2e-16 ***
## L3     576.0       19.4   29.73  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 72.8 on 46 degrees of freedom
## 
## Number of iterations to convergence: 12 
## Achieved convergence tolerance: 8e-06
```


The two model fits can be visualized with ...


```r
xlbl <- "Age (yrs)"
ylbl <- "Total Length (mm)"
xlmt <- c(5,19)
ylmt <- c(300,750)

plot(Length~Age,data=Subset(df1,Sex=="Female"),pch=16,xlab=xlbl,ylab=ylbl,
     main="No differences",xlim=xlmt,ylim=ylmt)
points(Length~Age,data=Subset(df1,Sex=="Male"),pch=16,col="red")
legend("bottomright",c("Female","Male"),pch=16,col=c("black","red"),cex=0.75)
vbF <- vbFuns("Francis")
curve(vbF(x,L1=coef(fitCom),t1=t1,t3=t3),from=5,to=12,lwd=2,col="blue",add=TRUE)

plot(Length~Age,data=Subset(df1,Sex=="Female"),pch=16,xlab=xlbl,ylab=ylbl,
     main="L1 and L2 differ",xlim=xlmt,ylim=ylmt)
points(Length~Age,data=Subset(df1,Sex=="Male"),pch=16,col="red")
legend("bottomright",c("Female","Male"),pch=16,col=c("black","red"),cex=0.75)
vbF <- vbFuns("Francis")
curve(vbF(x,L1=coef(fit12)[c(1,3,5)],t1=t1,t3=t3),from=5,to=12,lwd=2,add=TRUE)
curve(vbF(x,L1=coef(fit12)[c(2,4,5)],t1=t1,t3=t3),from=5,to=12,lwd=2,col="red",add=TRUE)
```

![plot of chunk VBGMfit3](figure/VBGMfit31.png) ![plot of chunk VBGMfit3](figure/VBGMfit32.png) 


