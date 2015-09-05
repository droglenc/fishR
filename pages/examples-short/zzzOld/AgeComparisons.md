





Last week I taught part of a workshop for the Minnesota Chapter of the American Fisheries Society on "Analyzing Age Data in R" (materials are [here](http://fishr.wordpress.com/courses/analyzing-age-data-with-r/)).  I like doing these workshops because they give me ideas for improving the **FSA** package and [fishR](http://fishr.wordpress.com/).  One of several things that came out of this workshop was a realization that the measures of precision for multiple age assignments on individual fish (think two or more "readers" assigning an age to each fish) that I had coded in `ageComp()` was restricted to only two age assignments.  The methods as described in the literature generalize to two or more age assignments.  My code had to change!

The latest version of the **FSA** package now has two new functions, `ageBias()` and `agePrecision()`, which replace `ageComp()` (`ageComp()` currently remains in **FSA** but will be removed in future versions, so you should begin changing your usage now).  I have not yet updated the "Age Comparisons Vignette" on [fishR](http://fishr.wordpress.com/) (I want to make major changes to all of the content in that vignette, not just the R part), so I will briefly demonstrate the new functions in this post.

Obviously, I need to load the **FSA** package.


```r
library(FSA)
```


I will use the information in the `WhitefishLC` data frame which has age assignments for three structures (otoliths, finrays, and scales) made by two readers (1 and 2).  The readers also came to a concensus age (labeled with a "C").


```r
data(WhitefishLC)
str(WhitefishLC)
```

```
## 'data.frame':	151 obs. of  11 variables:
##  $ fishID  : int  1 2 3 4 5 6 7 8 9 10 ...
##  $ tl      : int  345 334 348 300 330 316 508 475 340 173 ...
##  $ scale1  : int  3 4 7 4 3 4 6 4 3 1 ...
##  $ scale2  : int  3 3 5 3 3 4 7 5 3 1 ...
##  $ scaleC  : int  3 4 6 4 3 4 7 5 3 1 ...
##  $ finray1 : int  3 3 3 3 4 2 6 9 2 2 ...
##  $ finray2 : int  3 3 3 2 3 3 6 9 3 1 ...
##  $ finrayC : int  3 3 3 3 4 3 6 9 3 1 ...
##  $ otolith1: int  3 3 3 3 3 6 9 11 3 1 ...
##  $ otolith2: int  3 3 3 3 3 5 10 12 4 1 ...
##  $ otolithC: int  3 3 3 3 3 6 10 11 4 1 ...
```


## Measures of Precision ##
Measures of precision are now computed with `agePrecision()` which uses formula notation with all variables on the right-hand-side of the formula and separated by "plus"es.  Of course, with the formula notation the `data=` argument is required.  [Note that the measures of precision here are not that useful because of potential bias between the structures; however, these data can be used to illustrate the use of more than two age assignments.]


```r
ap3 <- agePrecision(~otolithC+finrayC+scaleC,data=WhitefishLC)
```


The overall measures of precision (mean APE, mean CV, and percent total agreement for all structures) are then computed with

```r
summary(ap3,what="precision")
```

```
## Precision summary statistics
##    n R    CV   APE PercAgree
##  151 3 21.77 16.19     12.58
```


The percentages of fish by absolute difference in age assignment for each pair of measures are obtained with

```r
summary(ap3,what="agreement")
```

```
## Percentage of fish by differences in ages between pairs of assignments
##                           0       1       2       3       4       5
## otolithC v. finrayC 24.5033 21.1921 17.8808 11.9205  7.2848  7.9470
## otolithC v. scaleC  19.8675 30.4636 16.5563 13.9073  5.9603  3.3113
## finrayC v. scaleC   40.3974 34.4371 15.2318  5.2980  3.9735  0.0000
##                           6       7       8       9      10      11
## otolithC v. finrayC  3.3113  2.6490  0.6623  1.3245  0.0000  0.6623
## otolithC v. scaleC   5.2980  1.9868  1.3245  0.0000  0.0000  0.6623
## finrayC v. scaleC    0.6623  0.0000  0.0000  0.0000  0.0000  0.0000
##                          12      13      14
## otolithC v. finrayC  0.0000  0.0000  0.6623
## otolithC v. scaleC   0.0000  0.6623  0.0000
## finrayC v. scaleC    0.0000  0.0000  0.0000
```


The example above demonstrated the new functionality for more than two age assignments.  Of course, two age assignments can still be used

```r
ap2 <- agePrecision(~otolith1+otolith2,data=WhitefishLC)
summary(ap2,what="precision")
```

```
## Precision summary statistics
##    n R    CV   APE PercAgree
##  151 2 4.719 3.337     62.25
```

```r
summary(ap2,what="agreement")
```

```
## Percentage of fish by differences in ages between pairs of assignments
##     0     1     2 
## 62.25 31.79  5.96
```



## Age Bias ##
The new code for assessing age bias uses `ageBias()` with the same arguments used in the original `ageComp()` -- i.e., a formula with the age assignments thought to be "more correct" on the left-hand-side, the other age assignment on the right-hand-side, the `data=` argument, and column and row labels in `col.lab=` and `row.lab=`, respectively.  The `ageBias()` function still only works with two sets of age assignments.

```r
ab1 <- ageBias(otolithC~scaleC,data=WhitefishLC,
               col.lab="Otolith Age",row.lab="Scale Age")
```


The overall age agreement table and Bowker's test for symmetry are computed with

```r
summary(ab1,what="symmetry")
```

```
## Raw agreement table (square)
##          Otolith Age
## Scale Age  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21
##        1   5  4  1  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
##        2   4  1  -  1  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
##        3   -  1 10  6  -  1  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
##        4   -  -  5  7  3  3  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
##        5   -  1  -  3  2  5  3  4  -  -  1  -  -  -  -  -  -  -  -  -  -
##        6   -  -  1  1  2  1  3  4  1  2  1  1  2  1  -  -  -  -  -  -  -
##        7   -  -  -  -  -  -  1  3  6  4  2  2  1  1  -  -  -  1  -  -  -
##        8   -  -  -  -  1  -  1  1  3  3  3  1  -  -  -  -  -  -  -  -  -
##        9   -  -  -  -  -  -  -  -  -  -  1  1  1  -  2  -  1  -  -  -  -
##        10  -  -  -  -  -  -  1  -  -  -  -  1  1  -  -  1  -  -  -  -  -
##        11  -  -  -  -  -  -  -  -  -  -  -  -  1  -  1  -  2  -  -  -  -
##        12  -  -  -  -  -  -  -  -  -  -  -  1  -  -  1  1  -  -  -  -  -
##        13  -  -  -  -  -  -  -  -  -  -  -  -  1  1  -  1  1  1  -  -  -
##        14  -  -  -  -  -  -  -  -  -  -  -  -  -  -  1  -  -  -  1  -  -
##        15  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  1  -  -  -  -  -
##        16  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
##        17  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
##        18  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
##        19  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
##        20  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
##        21  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
##        22  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
##        23  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
##          Otolith Age
## Scale Age 22 23
##        1   -  -
##        2   -  -
##        3   -  -
##        4   -  -
##        5   -  -
##        6   -  -
##        7   -  -
##        8   -  -
##        9   -  -
##        10  -  1
##        11  -  -
##        12  -  -
##        13  -  -
##        14  -  -
##        15  -  -
##        16  -  -
##        17  -  -
##        18  -  -
##        19  -  -
##        20  -  -
##        21  -  -
##        22  -  -
##        23  -  -
## 
## Bowker's (Hoenig's) Test of Symmetry
##  df chi.sq       p
##  54  75.98 0.02598
```


The summary statistics, t-test results, and confidence intervals for the "other" (row) age assignments at each age of the "more correct" (column) age assignments are obtained with

```r
summary(ab1,what="bias")
```

```
## Summary of Scale Age by Otolith Age 
##  otolithC  n min max  mean    SE       t   adj.p   sig   LCI   UCI
##         1  9   1   2  1.44 0.176   2.530 0.21160 FALSE 1.039  1.85
##         2  7   1   5  2.00 0.577   0.000 1.00000 FALSE 0.587  3.41
##         3 17   1   6  3.35 0.242   1.460 0.81763 FALSE 2.841  3.87
##         4 18   2   6  3.83 0.232  -0.718 1.00000 FALSE 3.343  4.32
##         5  8   4   8  5.25 0.491   0.509 1.00000 FALSE 4.089  6.41
##         6 10   3   6  4.60 0.267  -5.250 0.00528  TRUE 3.997  5.20
##         7  9   5  10  6.44 0.556  -1.000 1.00000 FALSE 5.163  7.73
##         8 12   5   8  6.08 0.288  -6.665 0.00042  TRUE 5.450  6.72
##         9 10   6   8  7.20 0.200  -8.999 0.00011  TRUE 6.748  7.65
##        10  9   6   8  7.11 0.261 -11.087 0.00005  TRUE 6.510  7.71
##        11  8   5   9  7.25 0.453  -8.275 0.00081  TRUE 6.178  8.32
##        12  7   6  12  8.43 0.782  -4.564 0.03450  TRUE 6.514 10.34
##        13  7   6  13  8.86 1.010  -4.101 0.05079 FALSE 6.385 11.33
##        14  3   6  13  8.67    NA      NA      NA FALSE    NA    NA
##        15  5   9  14 11.00 0.949  -4.216 0.09462 FALSE 8.366 13.63
##        16  4  10  15 12.50    NA      NA      NA FALSE    NA    NA
##        17  4   9  13 11.00    NA      NA      NA FALSE    NA    NA
##        18  2   7  13 10.00    NA      NA      NA FALSE    NA    NA
##        19  1  14  14 14.00    NA      NA      NA FALSE    NA    NA
##        23  1  10  10 10.00    NA      NA      NA FALSE    NA    NA
```


The default age-bias plot is provided with

```r
plot(ab1)
```

![plot of chunk agebiasplot1](figure/agebiasplot1.png) 

I changed the code for the age-bias plot so that confidence intervals are not computed for ages with "small" sample sizes.  The definition of small can be controlled with `min.n.CI=` (which defaults to 5) in the `ageBias()` call.  For example, the default age-bias plot from the original `ageComp()` is constructed with

```r
ab2 <- ageBias(otolithC~scaleC,data=WhitefishLC,min.n.CI=2,
               col.lab="Otolith Age",row.lab="Scale Age")
plot(ab2)
```

![plot of chunk agebiasplot2](figure/agebiasplot2.png) 

This is, of course, quite ugly.  I also modified the code to more sensibly handle controlling the axes in situations like this.  For example,

```r
plot(ab2,ylim=c(0,23))
```

![plot of chunk agebiasplot3](figure/agebiasplot3.png) 


More details are in the help files for `ageBias()` and `agePrecision()`.  Let me know if you have any questions or comments.
