# make some toy data
lens <- data.frame(net=rep(c(1,2,3),c(7,5,6)),
                   eff=rep(c(1,2,2),c(7,5,6)),
                   temp=rep(c(17,15.5,16.5),c(7,5,6)),
                   species=c(rep(c("BKT","LKT","RBT"),c(3,2,2)),
                             rep(c("BKT","LKT"),c(2,3)),
                             rep(c("BKT","RBT"),c(4,2))),
                   tl=round(rnorm(18,mean=100,sd=10),0)
                  )
lens

# now turn it into catch data
library(plyr)
catch1 <- ddply(lens,~net+eff+temp+species,
                summarize,catch=length(tl))
catch1

# now add zeroes where needed
library(FSA)
catch2 <- addZeroCatch(catch1,"net","species",
                       zerovar="catch")
catch2[order(catch2$net,catch2$species),]

# illustrate compute mean/sd CPE
catch2$cpe <- catch2$catch/catch2$eff
ddply(catch2,~species,
      summarize,mean.cpe=mean(cpe),sd.cpe=sd(cpe))
