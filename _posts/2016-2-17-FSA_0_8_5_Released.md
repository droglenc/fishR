---
layout: post
title: FSA v0.8.5 Released
tags: [R, FSA]
---

A new minor version (0.8.5) of the **FSA** (Fisheries Stock Assessment) package was recently released and is now [on CRAN](https://cran.r-project.org/).  A full description of changes [is here](https://github.com/droglenc/FSA/blob/master/NEWS.md).  Major changes are:

* `agePrecision()`: Fixed bug related to computations of percent agreement when `NA` values were present. There was an inconsistency between when `what="precision"` and `what="difference"` was used in `summary()`.  The bug fix now properly divides by the "valid sample size" for `what="precision"`.
* `histFromSum()`: Added.  Allows one to construct a histogram from summarized frequency data.  This was a feature request to allow construction of length frequency histograms from summarized length frequency tables.  This is not yet a mature function, so please send suggestions or concerns to me.

I am also interested in new feature requests.  Let me know if you would like to see anything else in **FSA**.
