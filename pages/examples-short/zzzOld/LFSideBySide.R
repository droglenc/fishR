library(XLConnect)
wb <- loadWorkbook("LFSideBySide.xlsx")
df <- readWorksheet(wb,sheet="Sheet1")
str(df)

# reasonable facsimile of the Excel graph
barplot(t(as.matrix(df[,2:3])),names.arg=df[,1],beside=TRUE,xlab="Total Length (mm)",ylab="Frequency",ylim=c(0,30),col=c("darkred","lightgreen"))
legend("topright",c("Freq1","Freq2"),col=c("darkred","lightgreen"),pch=15,bty="n",cex=1.25)

# a better option
par(mfrow=c(2,1),mar=c(3.5,3.5,0.5,0.5),mgp=c(2,0.5,0),tcl=-0.2)
plotH(Freq1~Lcat,data=df,width=0.5,xlab="Total Length (mm)",ylab="Frequency")
plotH(Freq2~Lcat,data=df,width=0.5,xlab="Total Length (mm)",ylab="Frequency")
?plotH
