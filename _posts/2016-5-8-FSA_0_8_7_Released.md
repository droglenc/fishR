---
layout: post
title: FSA v0.8.7 Released
tags: [R, FSA]
---

A new minor version (0.8.7) of the **FSA** (Fisheries Stock Assessment) package was recently released and is now [on CRAN](https://cran.r-project.org/).  A full description of changes [is here](https://github.com/droglenc/FSA/blob/master/NEWS.md).  Three major changes are described below.

* Removed the `dynamicPlot=TRUE` option from `vbStarts()` and `srStarts()`.  This functionality has been moved to `vbStartsDP()` and `srStartsDP()`, respectively, in the `FSAsim` package [available only on GitHub](https://github.com/droglenc/FSAsim).  This functionality was removed because of the reliance on the `relax` package and `tcltk` which was getting difficult (for me) to maintain relative to CRAN.
* The `ageKey()` and `ageKeyPlot()` functions have been permanently removed.  These have been deprecated since v0.4.24.  Use `alkIndivAge()` and `alkPlot()` instead for the same functionality.
* A new function `growthFunShow()` is introducted to create `plotmath()` expressions of common parameterizations of the von Bertalanffy, Gompertz, Richards, and logistic growth functions.  The documentation for this function shows how it can be used to place these expressions on plots, including creating a plot that shows several parameterizations.  With this, `vbModels()`, `GompertzModels()`, `RichardsModels()`, and `LogisticModels` were all removed.  This change allows for more flexibilty as more parameterizations are added.
* A new function `srFunShow()` is introduced that is similar to `growthFunShow()` but for expressions of stock-recruitment models.  With this, `srModels()` was removed.

[Bug reports and feature requests can be filed as an issue](https://github.com/droglenc/FSA/issues) on the **FSA** GitHub page.
