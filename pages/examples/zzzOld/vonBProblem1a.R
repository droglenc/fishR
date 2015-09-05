library(FSA)


## ------------------------------------------------------------------------
df <- read.csv("BKData.csv",header=TRUE)
str(df)
levels(df$Sex)


## ------------------------------------------------------------------------
df1 <- Subset(df,Sex!="")
dim(df1)


## ------------------------------------------------------------------------
frGen <- Length~L1[Sex]+(L3[Sex]-L1[Sex])*(1-((L3[Sex]-L2[Sex])/(L2[Sex]-L1[Sex]))^(2*(Age-t1)/(t3-t1)))/(1-((L3[Sex]-L2[Sex])/(L2[Sex]-L1[Sex]))^2)
fr12 <- Length~L1[Sex]+(L3-L1[Sex])*(1-((L3-L2[Sex])/(L2[Sex]-L1[Sex]))^(2*(Age-t1)/(t3-t1)))/(1-((L3-L2[Sex])/(L2[Sex]-L1[Sex]))^2)
fr13 <- Length~L1[Sex]+(L3[Sex]-L1[Sex])*(1-((L3[Sex]-L2)/(L2-L1[Sex]))^(2*(Age-t1)/(t3-t1)))/(1-((L3[Sex]-L2)/(L2-L1[Sex]))^2)
fr23 <- Length~L1+(L3[Sex]-L1)*(1-((L3[Sex]-L2[Sex])/(L2[Sex]-L1))^(2*(Age-t1)/(t3-t1)))/(1-((L3[Sex]-L2[Sex])/(L2[Sex]-L1))^2)
fr1 <- Length~L1[Sex]+(L3-L1[Sex])*(1-((L3-L2)/(L2-L1[Sex]))^(2*(Age-t1)/(t3-t1)))/(1-((L3-L2)/(L2-L1[Sex]))^2)
fr2 <- Length~L1+(L3-L1)*(1-((L3-L2[Sex])/(L2[Sex]-L1))^(2*(Age-t1)/(t3-t1)))/(1-((L3-L2[Sex])/(L2[Sex]-L1))^2)
fr3 <- Length~L1+(L3[Sex]-L1)*(1-((L3[Sex]-L2)/(L2-L1))^(2*(Age-t1)/(t3-t1)))/(1-((L3[Sex]-L2)/(L2-L1))^2)
frCom <- Length~L1+(L3-L1)*(1-((L3-L2)/(L2-L1))^(2*(Age-t1)/(t3-t1)))/(1-((L3-L2)/(L2-L1))^2)


## ------------------------------------------------------------------------
t1 <- 5
t3 <- 12


## ------------------------------------------------------------------------
( svCom <- vbStarts(Length~Age,data=df1,type="Francis",tFrancis=c(t1,t3),methEV="poly") )


## ------------------------------------------------------------------------
svGen <- lapply(svCom,rep,2)
sv12 <- mapply(rep,svCom,c(2,2,1))
sv13 <- mapply(rep,svCom,c(2,1,2))
sv23 <- mapply(rep,svCom,c(1,2,2))
sv1 <- mapply(rep,svCom,c(2,1,1))
sv2 <- mapply(rep,svCom,c(1,2,1))
sv3 <- mapply(rep,svCom,c(1,1,2))


## ------------------------------------------------------------------------
fitGen <- nls(frGen,data=df1,start=svGen) 
fit12 <- nls(fr12,data=df1,start=sv12) 
fit13 <- nls(fr13,data=df1,start=sv13) 
fit23 <- nls(fr23,data=df1,start=sv23) 
fit1 <- nls(fr1,data=df1,start=sv1) 
fit2 <- nls(fr2,data=df1,start=sv2) 
fit3 <- nls(fr3,data=df1,start=sv3) 
fitCom <- nls(frCom,data=df1,start=svCom) 


## ------------------------------------------------------------------------
anova(fit12,fitGen)
anova(fit13,fitGen)
anova(fit23,fitGen)


## ------------------------------------------------------------------------
anova(fit1,fit12)
anova(fit2,fit12)


## ------------------------------------------------------------------------
anova(fitCom,fit2)


## ------------------------------------------------------------------------
AIC(fitGen,fit12,fit13,fit23,fit1,fit2,fit3,fitCom)


## ------------------------------------------------------------------------
summary(fit2)
summary(fit12)


## ----VBGMfit3, fig.width=4, fig.height=4, fig.show='hold'----------------
xlbl <- "Age (yrs)"
ylbl <- "Total Length (mm)"
xlmt <- c(5,19)
ylmt <- c(300,750)

plot(Length~Age,data=Subset(df1,Sex=="Female"),pch=16,xlab=xlbl,ylab=ylbl,
     main="Only L2 differs",xlim=xlmt,ylim=ylmt)
points(Length~Age,data=Subset(df1,Sex=="Male"),pch=16,col="red")
legend("bottomright",c("Female","Male"),pch=16,col=c("black","red"),cex=0.75)
vbF <- vbFuns("Francis")
curve(vbF(x,L1=coef(fit2)[c(1,2,4)],t1=t1,t3=t3),from=5,to=12,lwd=2,add=TRUE)
curve(vbF(x,L1=coef(fit2)[c(1,3,4)],t1=t1,t3=t3),from=5,to=12,lwd=2,col="red",add=TRUE)

plot(Length~Age,data=Subset(df1,Sex=="Female"),pch=16,xlab=xlbl,ylab=ylbl,
     main="L1 and L2 differ",xlim=xlmt,ylim=ylmt)
points(Length~Age,data=Subset(df1,Sex=="Male"),pch=16,col="red")
legend("bottomright",c("Female","Male"),pch=16,col=c("black","red"),cex=0.75)
vbF <- vbFuns("Francis")
curve(vbF(x,L1=coef(fit12)[c(1,3,5)],t1=t1,t3=t3),from=5,to=12,lwd=2,add=TRUE)
curve(vbF(x,L1=coef(fit12)[c(2,4,5)],t1=t1,t3=t3),from=5,to=12,lwd=2,col="red",add=TRUE)


