#@@@@@@@@@@@@@@@@@@@@@@@@@@
#dev R 3.2.1 "World-Famous Astronaut"
#analyzing increment-decrement tables produced in lifetable.R
#Bryce Bartlett
#@@@@@@@@@@@@@@@@@@@@@@@@@@

#load general info

#load universals configuration file
source("H:/projects/rel_belong/code/config.R",
       echo =T, print.eval = T, keep.source=T)

#@@@@@@@@@@@@@@@@@@@@@@@@
#Load life table samples
#@@@@@@@@@@@@@@@@@@@@@@@@

ageints=33; n=2; agestart = 18 #need to change based on lifetable.R
nm = c('Evangelical','Mainline', 'Other', 'Catholic','None','Death')

#NOTE: as vector reads out the matrix columnwise; i.e. first 6 obs in each age are TO evangelical
phi = read.csv(paste0(outdir,'phi.csv'))
phi.mean = aggregate(phi[,3:38],by=list(phi$ageint), FUN=mean)
phi.lower = aggregate(phi[,3:38],by=list(phi$ageint), FUN=quantile, probs=0.025)
phi.upper = aggregate(phi[,3:38],by=list(phi$ageint), FUN=quantile, probs=0.975)
rm(phi) #save space

le = read.csv(paste0(outdir,'le.csv'))
le.mean = aggregate(le[,3:27],by=list(le$ageint), FUN=mean)
le.lower = aggregate(le[,3:27],by=list(le$ageint), FUN=quantile, probs=0.025)
le.upper = aggregate(le[,3:27],by=list(le$ageint), FUN=quantile, probs=0.975)
le.sd = aggregate(le[,3:27],by=list(le$ageint), FUN=sd)
#rm(le) #save space

#@@@@@@@@@@@@@@@@@@@@@@@@
#Plot Transition Probabilities
#@@@@@@@@@@@@@@@@@@@@@@@@


png(paste0(draftimg,'predprobs.png'),width=9,height=6.5,units='in',res=250)

yx = ((0:ageints)*2)+agestart
yax = c(min(phi.lower[,2:37])+.01,max(phi.upper[,2:37])+.01)


par(mfrow=c(6,5),mar=c(0,0,0,0), oma=c(3,6,3,2)) 
#Note that par prints row-wise (so transpose of T matrix)
nmcount = 1 #indicator to get the raight label on y axis

for(p in 1:36){
  #print(c(p,p%%6!=0))
  #skip multiples of 6: these are the determined absorbing setate of death
  if(p%%6!=0){
    plot(yx,phi.mean[,paste0('phi',p)], type="l", ylim=yax, xlab='', ylab='', xaxt='n', yaxt='n')
      lines(yx,phi.lower[,paste0('phi',p)], lty=3)
      lines(yx,phi.upper[,paste0('phi',p)], lty=3)

      #id labels
      if(p %in% 31:35){axis(side=1)} 
      if(p %in% 1:5){mtext(paste('From', nm[p]),side=3, cex=.5)}
      if(p %in% ((0:5)*6+1)){
        axis(side=2) 
        mtext(paste('To',nm[nmcount]),side=2,cex=.5,line=2)
          nmcount=nmcount+1}
  }
    
}
dev.off()

#@@@@@@@@@@@@@@@@@@@@@@@@
#Generate summary table for life expectancy
#@@@@@@@@@@@@@@@@@@@@@@@@

#generate table for 18 years old (ageint=1), 30 years old (ageint=6), 50 years old (ageint=16), and 70 years old (ageint=26)
ages = c(1,6,16,26)

#sink()

#sink()
