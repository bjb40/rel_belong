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

ageints=33; n=2; agestart = 20 #need to change based on lifetable.R
nm = c('Evangelical','Mainline', 'Other', 'Catholic','None','Death')

#NOTE: as vector reads out the matrix columnwise; i.e. first 6 obs in each age are TO evangelical
phi = read.csv(paste0(outdir,'phi.csv'))
phi.mean = aggregate(phi[,3:38],by=list(phi$ageint), FUN=mean)
phi.lower = aggregate(phi[,3:38],by=list(phi$ageint), FUN=quantile, probs=0.025)
phi.upper = aggregate(phi[,3:38],by=list(phi$ageint), FUN=quantile, probs=0.975)
rm(phi) #save space

#l = read.csv(paste(outdir,'l.csv',sep=''), header=F)
#lar = array(unlist(read.csv(paste(outdir,'l.csv',''), header=F)[,2:26]),c(30,10000,25))
#confirm array is put together correctly
#View(l[1:30,2:26] == lar[,1,])
#rm(l)

#le = read.csv(paste(outdir,'le.csv',sep=''), header=F)



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

#estimate
le.est = aggregate(le,by=list(le$V1),mean)
#95 percentile
le.lower = aggregate(le,by=list(le$V1),quantile, prob=0.025)
le.upper = aggregate(le,by=list(le$V1),quantile, prob=0.975)

colnames(le.lower)[3:7] = colnames(le.upper)[3:7] = colnames(le.est)[3:7] = nm 

sink(paste(outdir,'le-table.txt',sep=''))
  print(Sys.Date(),quote="F")
  cat('\n\n@@@@@@@@@@@@@@@@@@@\nFull Expectances (le0) ')
  cat('\n@@@@@@@@@@@@@@@@@@@@@\n\n')

  for(r in 1:5){
    cat(paste('\nExpeted time (with 95% intervals) in traditions for those starting as', nm[r]))
    cat('\n')
    print(rbind(round(le.est[r,3:7],3),
                round(le.lower[r,3:7],3),
                round(le.upper[r,3:7],3)
                ),
          row.names=c('estimate','lower','uppper'))
    }

sink()



