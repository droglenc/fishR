
library(FSA)
library(FSAdata)  # for datafile

data(AlewifeLH)
str(AlewifeLH)

ab.ale <- ageBias(otoliths~scales,data=AlewifeLH,col.lab="Otolith Age",
row.lab="Scale Age")
summary(ab.ale,what="symmetry")

sumab.ale <- summary(ab.ale,what="symmetry")

plot(ab.ale)

plot(ab.ale,difference=TRUE)

plot(ab.ale,show.pts=TRUE,transparency=1/10)

plot(ab.ale,show.rng=TRUE)

summary(ab.ale,what="bias")
summary(ab.ale,what="bias",difference=TRUE)

data(Croaker1)
str(Croaker1)
ap.croak <- agePrecision(~reader1+reader2,data=Croaker1)
summary(ap.croak,what="precision")
summary(ap.croak,what="agreement")

