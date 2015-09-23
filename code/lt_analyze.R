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
phi.lower = aggregate(phi[,3:38],by=list(phi$ageint), FUN=quantile, probs=0.08)
phi.upper = aggregate(phi[,3:38],by=list(phi$ageint), FUN=quantile, probs=0.92)
rm(phi) #save space

le = read.csv(paste0(outdir,'le.csv'))
le.mean = aggregate(le[,3:27],by=list(le$ageint), FUN=mean)
#84% for biviariate comparisons in table
le.lower = aggregate(le[,3:27],by=list(le$ageint), FUN=quantile, probs=0.08)
le.upper = aggregate(le[,3:27],by=list(le$ageint), FUN=quantile, probs=0.92)
le.sd = aggregate(le[,3:27],by=list(le$ageint), FUN=sd)
rm(le) #save space

l = read.csv(paste0(outdir,'l.csv'))
l.mean = aggregate(l[,3:38],by=list(l$ageint), FUN=mean)
#84% for biviariate comparisons in table
l.lower = aggregate(l[,3:38],by=list(l$ageint), FUN=quantile, probs=0.025)
l.upper = aggregate(l[,3:38],by=list(l$ageint), FUN=quantile, probs=0.975)
l.sd = aggregate(l[,3:38],by=list(l$ageint), FUN=sd)
rm(l) #save space

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

png(paste0(draftimg,'mort-stay-probs.png'))
par(mfrow=c(2,1), oma=c(1,1,1,1), mar=c(2,1,1.5,1))
#mortality
diers = c(31:35)
plot(yx,phi.mean$phi6, ylim=c(0,.3), type="n", xlab='', xaxt='n',ylab='',main="Probability of Mortality")
for(k in 1:length(diers)){
  polygon(c(yx, rev(yx)), c(phi.upper[,paste0('phi',diers[k])],rev(phi.lower[,paste0('phi',diers[k])])), 
          col="gray90", border=NA)
}
for(k in 1:length(diers)){
  lines(yx,phi.mean[,paste0('phi',diers[k])], lty=k)
}

legend('topleft',legend=nm[1:5],
       bty='n',
       lty=1:5,
       cex=.75)


#diagonal of phi - stayers
stayers = c(1,8,15,22,29)

plot(yx,phi.mean$phi1, ylim=c(0.25,.9), type="n", xlab='Age', ylab='',main="Probability of Staying in Tradition")
for(k in 1:length(stayers)){
  polygon(c(yx, rev(yx)), c(phi.upper[,paste0('phi',stayers[k])],rev(phi.lower[,paste0('phi',stayers[k])])), 
          col="gray90", border=NA)
}
for(k in 1:length(stayers)){
  lines(yx,phi.mean[,paste0('phi',stayers[k])], lty=k)
}
dev.off()


#transitions
toev = 2:5
tonone = 25:28

png(paste0(draftimg,'big-takers.png'))
par(mfrow=c(2,1), oma=c(1,1,1,1), mar=c(2,1,1.5,1))
#to evangelical
plot(yx,phi.mean$phi2, ylim=c(0,.4), type="n", xlab='Age', xaxt='n',ylab='',main="Probability of Transitioning to Evangelical")
for(k in 1:length(toev)){
  polygon(c(yx, rev(yx)), c(phi.upper[,paste0('phi',toev[k])],rev(phi.lower[,paste0('phi',toev[k])])), 
          col="gray90", border=NA)
}
for(k in 1:length(toev)){
  lines(yx,phi.mean[,paste0('phi',toev[k])], lty=k+1)
}

legend('topright',legend=paste('From',nm[2:5]),
       bty='n',
       lty=2:5,
       cex=.75)

#to none
plot(yx,phi.mean$phi2, ylim=c(0,.45), type="n", xlab='Age',ylab='',main="Probability of Transitioning to None")
for(k in 1:length(tonone)){
  polygon(c(yx, rev(yx)), c(phi.upper[,paste0('phi',tonone[k])],rev(phi.lower[,paste0('phi',tonone[k])])), 
          col="gray90", border=NA)
}
for(k in 1:length(tonone)){
  lines(yx,phi.mean[,paste0('phi',tonone[k])], lty=k)
}

legend('topright',legend=paste('From',nm[1:4]),
       bty='n',
       lty=1:4,
       cex=.75)

dev.off()

#@@@@@@@@@@@@@@@@@@@@@@@@
#Generate summary table for life expectancy
#@@@@@@@@@@@@@@@@@@@@@@@@

#generate table for 18 years old (ageint=1), 30 years old (ageint=6), 50 years old (ageint=16), and 70 years old (ageint=26)
ages = c(1,7,17,27)

sink(paste0(outdir,'le-table.txt'))

cat('\n')
cat('\n|Religious Tradition at Age x|',paste(nm[1:5],'|'),'\n')
cat('|:---------------------------|------------:|---------:|------:|---------:|-----:|\n')

for(age in ages){
    
  mn = round(t(matrix(as.numeric(le.mean[age,2:26]),5,5)),1)
  l = round(t(matrix(as.numeric(le.lower[age,2:26]),5,5)),1)
  u = round(t(matrix(as.numeric(le.upper[age,2:26]),5,5)),1)

  cat(paste0('|$e_{',age*n+agestart-n,'}$: Expected years in Tradition (from age ',age*n+agestart-n),')| | | | | |\n')
  
  for(r in 1:5){
    cat('|',nm[r],'| ',paste(mn[r,],'| '),'\n') 
    cat('|\t|',paste0('[',l[r,],', ',u[r,],'] |'),'\n')
  }  
  cat('|Total |',paste(colSums(mn),' |'), '\n')
  cat('|\t|',paste0('[',colSums(l),', ',colSums(u),'] |'),'\n')
  
  #cat('| | | | | | |')
}

cat('\n\nNOTE: Mean posterior estimates with 84% intervals in brackets.')

sink()


#@@@@@@@@@@@@@@@@@@@@@@@@
#Generate table for projections based on stable population
#@@@@@@@@@@@@@@@@@@@@@@@@

#create multidimensional array for l
lmat.m = array(as.matrix(l.mean[,2:37]),c(33,6,6))
lmat.l = array(as.matrix(l.lower[,2:37]),c(33,6,6))
lmat.u = array(as.matrix(l.upper[,2:37]),c(33,6,6))

lmat.mean = matrix(NA,33,6)
lmat.lower = matrix(NA,33,6)
lmat.upper = matrix(NA,33,6)

for(a in 1:33){
  lmat.mean[a,2:6] = colSums(lmat.m[a,1:5,1:5])
  lmat.lower[a,2:6] = colSums(lmat.l[a,1:5,1:5])
  lmat.upper[a,2:6] = colSums(lmat.u[a,1:5,1:5])
  
  lmat.lower[a,1] = lmat.upper[a,1] = lmat.mean[a,1] = (agestart + (a-1)*n)
}

rm(lmat.m,lmat.l,lmat.u)

dat = read.csv(paste(outdir,'private~/subpanel.csv',sep=''))

ages = c(20,30,50,70)

sink(paste0(outdir,'proj-table.txt'))

cat('\n')
cat('\n|Proportion Age x and Greater|',paste(nm[1:5],'|'),'\n')
cat('|:---------------------------|------------:|---------:|------:|---------:|-----:|\n')


for(a in 1:length(ages)){
    cat('| ', ages[a], '|')
    cat(paste0('**',round(table(dat[dat$age>=ages[a],'reltrad'])/sum(dat$age>=ages[a]),3),'** |'),'\n')
    cat('|      |')
    cat(paste(round(colSums(lmat.mean[lmat.mean[,1]>=ages[a],2:6])/sum(lmat.mean[lmat.mean[,1]>=ages[a],2:6]),3),' | '),'\n')
    
    up = round(colSums(lmat.upper[lmat.upper[,1]>=ages[a],2:6])/sum(lmat.upper[lmat.upper[,1]>=ages[a],2:6]),3)
    low = round(colSums(lmat.lower[lmat.lower[,1]>=ages[a],2:6])/sum(lmat.lower[lmat.lower[,1]>=ages[a],2:6]),3)  
 
    cat('|      |')
    cat(paste0('[',up,', ',low,'] |'),'\n')
}

sink()