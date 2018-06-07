---
title: "Testers for RFishBC"
layout: post
date: "June 7, 2018"
output:
  html_document
tags:
- R
- back_calculation

---


----

Back-calculating lengths of fish at previous ages from measurements made on calcified structures (scales, otoliths, etc.) is fairly common practice within some fisheries agencies and institutions. The FishBC software distributed by the American Fisheries Society is used by some of these agencies to facilitate gathering the required information from the structures and computing the back-calculations. It is my understanding that the FishBC software does not work on machines with Windows versions newer than version 7 and that there are no plans to update the software to remove that limitation. Although I have never personally used FishBC, I have created the **RFishBC** package to potentially replace FishBC. The current version of **RFishBC** is documented on the [RFishBC webpage](http://derekogle.com/RFishBC/) (especially in the four vignettes there).

To this point I have tested that measurements made on structures using **RFishBC** closely match measurements made with other systems (at least within the precision of selecting particular points on a structure). In addition, the interface works well for my workflow and the documentation was useful for at least one of my students.

At this time, I am seeking volunteers to use **RFishBC** and provide feedback to me to make improvements on the next version. The only prerequisite for volunteering is having the ability to capture digital images of structures on which annuli can be identified (and a minimal working knowledge of R).

If you are interested in testing **RFishBC** for back-calculating fish lengths from previous ages, please [contact me](mailto:derek@derekogle.com).
