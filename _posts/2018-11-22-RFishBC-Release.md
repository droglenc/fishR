---
title: "RFishBC CRAN Release"
layout: post
date: "November 22, 2018"
output:
  html_document
tags:
- R
- RFishBC
- back_calculation

---


----

<img src="http://derekogle.com/RFishBC/reference/figures/logo.png" align="right" height="300">

I am pleased to announce that the **RFishBC** package has been released to CRAN. This package is intended to help fisheries scientists gather age and measurement data from digital images of calcified structures and, possibly, back-calculate previous length from that data. **RFishBC** is intended to replace the FishBC software that has long been available for purchase from the American Fisheries Society but does not work on machines with Windows versions newer than version 7, and there are no plans to update the software to remove that limitation. I have never actually used FishBC, but I believe that **RFishBC** also has some useful new functionality, especially related to archiving and visualizing multiple measurements on calcified structures.

Development of **RFishBC** began about a year ago when I was teaching an R workshop in Milwaukee and Ben Neely brought the FishBC issue to my attention and wondered if the same functionality could be accomplished in R. Since then I have created a workflow that seems to work well for my students and for Ben and his crew in Kansas. In addition, volunteers from Michigan and North Carolina have put **RFishBC** through its paces and provided valuable feedback, most of which I have incorporated into the released version. I feel that the package is sufficiently mature to release to CRAN, but I am still hoping that more of you will use **RFishBC** and send me bug reports, irritations, and feature requests so that it can continue to evolve.

I have introduced and described the primary functionality of the package with the following four vignettes that are available from [the official **RFishBC** webpage](http://derekogle.com/RFishBC/).

1. [Short Introduction to Back-Calculation](http://derekogle.com/RFishBC/articles/BCIntro/BCIntro.html)
1. [Collect Radial Measurements from a Calcified Structure by Interactively Selecting Annuli](http://derekogle.com/RFishBC/articles/MeasureRadii/collectRadiiData.html)
1. [Visualize Points Selected on a Calcified Structure](http://derekogle.com/RFishBC/articles/MeasureRadii/seeRadiiData.html)
1. [Compute Back-Calculated Lengths](http://derekogle.com/RFishBC/articles/BCCalc/BCCalc.html)

A fifth vignette provides a [suggested workflow](http://derekogle.com/RFishBC/articles/Workflow/BCWorkflow.html). The R Documentation (i.e., "help files") for each function [are also available on the webpage](http://derekogle.com/RFishBC/reference/index.html) (including output from the examples).

If you have comments or questions about **RFishBC** please [contact me](mailto:derek@derekogle.com) or submit a bug report or feature request though [the packages GitHub Issues page](https://github.com/droglenc/RFishBC/issues).
