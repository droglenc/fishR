
library(FSA)
library(lattice)  #xyplot

data(SMBassWB)

SMBassWByearclass <- SMBassWB$yearcap-SMBassWB$agecap
wb90 <- Subset(SMBassWB,yearcap==1990)

par(mfrow=c(2,2),mar=c(3.5,3.5,2,1),mgp=c(2,0.75,0),las=1,tcl=-0.2,xaxs="i",yaxs="i")
attach(wb90)
#-------------------------------------------------------------------------------
# Plots the Dahl-Lea
#-------------------------------------------------------------------------------
plot(radcap,lencap,xlim=c(0,max(radcap)),ylim=c(0,max(lencap)),xlab=expression(S[C]),ylab=expression(L[C]),yaxt="n",xaxt="n")
axis(2,c(0,50,seq(150,350,50)))
xs <- c(0,2,6,8,10)
axis(1,xs)

Sc <- 9.2219; Lc <- 312                                             # Fish #701 as an example -- just show line
points(Sc,Lc,pch=19,col="grey",cex=1.25)                            # Highlight the point
lines(c(0,Sc),c(0,Lc),lwd=2,col="grey")                             # Show the back-calculation line
Sc <- 7.44389; Lc <- 218; Si <- 3.49804                             # Fish #704 as an example -- show calculation
points(Sc,Lc,pch=19,cex=1.5)                                        # Highlight the point
lines(c(0,Sc),c(0,Lc),lwd=2)                                        # Show the back-calculation line
Li<-(Si/Sc)*Lc                                                      # Back-calculated length
text(Si,-10,paste(Si),pos=1,col="blue",xpd=TRUE)                    # Label scale radius on x-axis
arrows(Si,-5,Si,Li,lwd=2,col="blue",length=0.1,angle=20,xpd=TRUE)   # Draw a line up from scale radius on x-axis
arrows(Si,Li,-0.1,Li,lwd=2,col="red",length=0.1,angle=20,xpd=TRUE)  # Draw a line over to the length axis
text(-0.1,Li,paste(round(Li,2)),pos=2,col="red",xpd=TRUE)           # Label back-calculated length
mtext("Dahl-Lea",line=0.5)

#-------------------------------------------------------------------------------
# Plots Fraser-Lee method
#-------------------------------------------------------------------------------
plot(radcap,lencap,xlim=c(0,max(radcap)),ylim=c(0,max(lencap)),xlab=expression(S[C]),ylab=expression(L[C]),yaxt="n",xaxt="n")
axis(2,seq(0,350,50))
xs <- c(0,2,6,8,10)
axis(1,xs)

lm.bph <- lm(lencap~radcap)
c <- coef(lm.bph)[1]
Sc <- 9.2219; Lc <- 312                                             # Fish #701 as an example -- just show line
points(Sc,Lc,pch=19,col="grey",cex=1.25)                            # Highlight the point
lines(c(0,Sc),c(c,Lc),lwd=2,col="grey")                             # Show the back-calculation line
Sc <- 7.44389; Lc <- 218; Si<-3.49804                               # Fish #704 as an example -- show calculation
points(Sc,Lc,pch=19,cex=1.5)                                        # Highlight the point
lines(c(0,Sc),c(c,Lc),lwd=2)                                        # Show the back-calculation line
Li <- (Si/Sc)*(Lc-c)+c
text(Si,-10,paste(Si),pos=1,col="blue",xpd=TRUE)                    # Label scale radius on x-axis
arrows(Si,-5,Si,Li,lwd=2,col="blue",length=0.1,angle=20,xpd=TRUE)   # Draw a line up from scale radius on x-axis
arrows(Si,Li,-0.1,Li,lwd=2,col="red",length=0.1,angle=20,xpd=TRUE)  # Draw a line over to the length axis
text(-0.1,Li,paste(round(Li,2)),pos=2,col="red",xpd=TRUE)           # Label back-calculated length
mtext("Fraser-Lee",line=0.5)

#-------------------------------------------------------------------------------
# Plots the SPH method
#-------------------------------------------------------------------------------
plot(radcap,lencap,xlim=c(0,max(radcap)),ylim=c(0,max(lencap)),xlab=expression(S[C]),ylab=expression(L[C]),yaxt="n",xaxt="n")
axis(2,seq(0,350,50))
xs <- c(0,2,6,8,10)
axis(1,xs)

lm.sph <- lm(radcap~lencap)
a <- coef(lm.sph)[1]; b <- coef(lm.sph)[2]
Sc <- 9.2219; Lc <- 312                                             # Fish #701 as an example -- just show line
points(Sc,Lc,pch=19,col="grey",cex=1.25)                            # Highlight the point
lines(c(0,Sc),c(-a/b,Lc),lwd=2,col="grey")                          # Show the back-calculation line
Sc <- 7.44389; Lc <- 218; Si <- 3.49804                             # Fish #704 as an example -- show calculation
points(Sc,Lc,pch=19,cex=1.5)                                        # Highlight the point
lines(c(0,Sc),c(-a/b,Lc),lwd=2)                                     # Show the back-calculation line
Li <- (-a/b)+(Lc+a/b)*(Si/Sc)
text(Si,-10,paste(Si),pos=1,col="blue",xpd=TRUE)                    # Label scale radius on x-axis
arrows(Si,-5,Si,Li,lwd=2,col="blue",length=0.1,angle=20,xpd=TRUE)   # Draw a line up from scale radius on x-axis
arrows(Si,Li,-0.1,Li,lwd=2,col="red",length=0.1,angle=20,xpd=TRUE)  # Draw a line over to the length axis
text(-0.1,Li,paste(round(Li,2)),pos=2,col="red",xpd=TRUE)           # Label back-calculated length
mtext("SPH",line=0.5)

#-------------------------------------------------------------------------------
# Plots the BPH method
#-------------------------------------------------------------------------------
plot(radcap,lencap,xlim=c(0,max(radcap)),ylim=c(0,max(lencap)),xlab=expression(S[C]),ylab=expression(L[C]),yaxt="n",xaxt="n")
axis(2,seq(0,350,50))
xs <- c(0,2,6,8,10)
axis(1,xs)

lm.bph <- lm(lencap~radcap)
c <- coef(lm.bph)[1]; d <- coef(lm.bph)[2]
Sc <- 9.2219; Lc <- 312                                             # Fish #701 as an example -- just show line
int <- (c*Lc)/(c+d*Sc)
points(Sc,Lc,pch=19,col="grey",cex=1.25)                            # Highlight the point
lines(c(0,Sc),c(int,Lc),lwd=2,col="grey")                           # Show the back-calculation line
Sc <- 7.44389; Lc <- 218; Si <- 3.49804                             # Fish #704 as an example -- show calculation
points(Sc,Lc,pch=19,cex=1.5)                                        # Highlight the point
int <- (c*Lc)/(c+d*Sc)
lines(c(0,Sc),c(int,Lc),lwd=2)                                      # Show the back-calculation line
Li <- Lc*(c+d*Si)/(c+d*Sc)
text(Si,-10,paste(Si),pos=1,col="blue",xpd=TRUE)                    # Label scale radius on x-axis
arrows(Si,-5,Si,Li,lwd=2,col="blue",length=0.1,angle=20,xpd=TRUE)   # Draw a line up from scale radius on x-axis
arrows(Si,Li,-0.1,Li,lwd=2,col="red",length=0.1,angle=20,xpd=TRUE)  # Draw a line over to the length axis
text(-0.1,Li,paste(round(Li,2)),pos=2,col="red",xpd=TRUE)           # Label back-calculated length
mtext("BPH",line=0.5)
detach(wb90)

head(wb90)
tail(wb90)

wb90r <- gReshape(wb90,in.pre="anu")
head(wb90r)

str(wb90r)        # to see the variable names
wb90z <- reshape(wb90r,v.names="anu",timevar="age",idvar=c("species","lake","gear","yearcap","fish","agecap","lencap","radcap"),direction="wide")
head(wb90z)

lm.sph <- lm(radcap~lencap,data=wb90)
coef(lm.sph)
a <- coef(lm.sph)[1]
b <- coef(lm.sph)[2]

lm.bph <- lm(lencap~radcap,data=wb90)
coef(lm.bph)
c <- coef(lm.bph)[1]
d <- coef(lm.bph)[2]

wb90r$dl.len <- with(wb90r,(anu/radcap)*lencap)
head(wb90r)

wb90r$fl.len <- with(wb90r,(anu/radcap)*(lencap-c)+c)
wb90r$sph.len <- with(wb90r,(-a/b)+(lencap+a/b)*(anu/radcap))
wb90r$bph.len <- with(wb90r,lencap*(c+d*anu)/(c+d*radcap))
head(wb90r)

Summarize(sph.len~age,data=wb90r,numdigs=2)

plot(sph.len~jitter(age),data=wb90r,ylab="Back-Calculated Length (mm)",xlab="Age (jittered)")

Summarize(sph.len~interaction(age,agecap),data=wb90r,numdigs=2)

xyplot(sph.len~jitter(age)|factor(agecap),data=wb90r,
ylab="Back-Calculated Length (mm)",xlab="Age (jittered)")

