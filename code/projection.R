#
#Bryce Bartlett
#

#Equation
#p0 + births + conversions - apostates - deaths
#births - fertility model; the rest mnomial
#p0 - proportion distribution in 2010 - because that
#year is teh center of the 2006 to 2014 panel sample used

#@@@@@@@@@@@@@
#preliminaries
#@@@@@@@@@@@@@

library(ggplot2)

#read data previously cleaned using ./prep-data.r
dat = read.csv(paste(outdir,'private~/subpanel.csv',sep=''))


#@@@@@@@@@@@@@
#Calculate p0
#@@@@@@@@@@@@@

#limit to initial observation for everyone
base=dat[dat$panelwave==1,]

#cut ages - has to be 6; otherwise not enough pooling
#and cells will be off -- probably need to stratify by weight...
base$abin = cut_width(base$age,6,boundary=18)

#calculate initial distributions
adults=table(base[,c('abin','female','reltrad')])

#add babies, preteens, and teens, with missing gender
sexratio=1.06
feprop = 1-(sexratio/(sexratio+1))

#women only! otherwise proportion will be off, also aligned with assumptions
bs = aggregate(base$babies[base$female==1],by=list(base$reltrad[base$female==1]), sum,na.rm=T)
pt = aggregate(base$preteen[base$female==1],by=list(base$reltrad[base$female==1]),sum,na.rm=T)
t = aggregate(base$teens[base$female==1],by=list(base$reltrad[base$female==1]),sum,na.rm=T)

#apply sex ratio to assign babies -- add in MCMC step
minors=array(integer(0),c(3,dim(p0[1,,])))
nm = dimnames(adults); nm[[1]] = c("[0,6]","(6,13]","(13,17]")
dimnames(minors) = nm

#babies
minors[1,2,] = unlist(lapply(bs$x,FUN=function(x) sum(rbinom(x,1,sexprop))))
minors[1,1,] = bs$x - minors[1,2,]

#preteen
minors[2,2,] = unlist(lapply(pt$x,FUN=function(x) sum(rbinom(x,1,sexprop))))
minors[2,1,] = pt$x - minors[2,2,]

#teens
minors[3,2,] = unlist(lapply(t$x,FUN=function(x) sum(rbinom(x,1,sexprop))))
minors[3,1,] = t$x - minors[3,2,]

#create p0
p0=array(integer(0),c(dim(adults)[1]+dim(minors)[1],dim(adults[1,,])))
nm[[1]] = c(nm[[1]],dimnames(adults)[[1]])
dimnames(p0)=nm
p0[1:3,,] = minors;p0[4:15,,] = adults

#translate to a radix of 100000
p0 = round(prop.table(p0)*100000)

#@@@@@@@@@@@@@
#Load fertility and transition estimates for
#@@@@@@@@@@@@@
#similar to lifetable.R, but projecting forward
#read in life table values

#calculate 6 year probabilities (dividing lx / lx+6)
#see prob set 3 in demography i exercizes for examples
phi = read.csv(paste0(outdir,'phi.csv'))

ageints=max(phi$ageint)
iters=max(phi$iter)
#tst = array(unlist(l[,3:ncol(l)]),c(iters,ageints,6,6))
phix=array(0,c(iters,ageints,6,6))
for(i in 1:iters){
  phix[i,,,] = array(unlist(phi[phi$iter==i,3:ncol(phi)]),c(ageints,6,6))
}

rm(phi)

#input survival probabilities for children 
#using the 2010 published life table in same manner
#link: http://www.cdc.gov/nchs/products/life_tables.htm (2010,p.9)
#
px.minors = c(0.006123,0.000428,0.000275,0.000211,0.000158,
              0.000145,0.000128,0.000114,0.000100,0.000087,
              0.000079,0.000086,0.000116,0.000175,0.000252,
              0.000333,0.000412,0.000492)

survive = function(n,prob){
  #helper function for surviving life tables (minors only)
  #n is life table individuals alive
  #returns number surviving over interval
  #prob is the probability of dying 
  return(n-sum(rbinom(n,1,sum(prob))))
}

#function for conversions, apostasies and deaths

msurv = function(n,prob){
  #helper function for surviving life tables (adults only)
  #n is life table individuals alive
  #returns number surviving or apostatizing over interval
  #prob is a vecotr of probability of dying or transition
  draw = rmultinom(n,size=1,prob=prob)
  return(rowSums(draw))
}

trns = function(row,prob){
  #helper function for transition life tables (adults only)
  #row is row vector of individuals alive in time +1
  #prob is transition matrix
  #returns row vector of multinomial counts
  
  mat = mapply(1:5,FUN=function(x) msurv(row[x],prob=prob[x,]))
  return(rowSums(mat[1:5,]))
  
}

#calculate average probability over six year intervals

phi = array(0,c(1800,12,6,6))
for(i in 1:1800){
  for(a in 1:11){ #ignoring first and last age groups
    r = ((a*3)-2):(a*3)
    phi[i,a,,]=(phix[i,r[1],,] + phix[i,r[2],,] + phix[i,r[3],,])/3
  }
  #last period same
  phi[i,12,,] = phix[i,34,,]
}

#@@@@@@@@@@@@@
#Input Births over 6 year interval 
#@@@@@@@@@@@@@

#calculate predicted mean fertility rates by 6 year age intervals
#p. 114
#18-48; 4:8

births = function(n,probs){
  #helper fucntion
  #n is a vector of ns for religious grup
  #probs is a vector of probabilities 
  #returns number of births
  rbinom(n,size=1,probs)
}

fx = read.csv(paste0(outdir,'fertprobs.csv'))
fx=fx[,2:ncol(fx)]
fx$age=fx$age-17 

f = array(0,c(1800,5,5)) #five age groups 18-48, 5 trads

for(i in 1:1800){
  for(a in 1:5){
    r = ((a*6)-5):(a*6)
    #print(r)
    c = paste0('iter',i) #column name for fx
    #mean fertility rate
    mfr = aggregate(fx[fx$age %in% r,paste0('iter',i)],by=list(fx$reltrad[fx$age %in% r]),mean)
    f[i,a,]=mfr[,2]
  }
}

#@@@@@@@@@@@@@@@@@
#Simulate future proportions
#@@@@@@@@@@@@@@@@@@

#function to simulate population change
sim=function(p0){
  #helper function for simulating population proportions
  #p0 is an array of integers 15 age groups, 2 gener, and
  #5 religious belonging
  #returns 1800 simulated population distributions 6 years later
    p1=array(0,c(iters,dim(p0)))
    nm=list(1:iters);names(nm)='iter'; nm=c(nm,dimnames(p0))
    dimnames(p1)=nm  
    
    #@@
    #draw posterior predictives for 
    #@@
    
    #cat('Beginning Simulation...\n')
    #st = Sys.time()
    
    for(i in 1:iters){
      if(i%%100==0){cat(i,'of',iters,'\n')}
      
      #check cohort component method -- may need to mean over interval ((x1+x2)/2)
      #sumulate minor survival (assuming no changes)
      p1[i,2,,] = mapply(p0[1,,],FUN=function(x) survive(x,sum(px.minors[1:3])))
      p1[i,3,,] = mapply(p0[2,,],FUN=function(x) survive(x,sum(px.minors[4:6])))
      p1[i,4,,] = mapply(p0[3,,],FUN=function(x) survive(x,sum(px.minors[7:9])))
    
      #simulate transitions for adult men and women
      for(a in 5:14){
       p1[i,a,1,] = trns(p0[a-1,1,],prob=phi[i,a-4,,])
       p1[i,a,2,] = trns(p0[a-1,1,],prob=phi[i,a-4,,])
      }
    
      #calculate final transition
      p1[i,15,1,]=trns(p0[14,1,],prob=phi[i,11,,])+trns(p0[15,1,],prob=phi[i,12,,])
      p1[i,15,2,]=trns(p0[14,1,],prob=phi[i,11,,])+trns(p0[15,1,],prob=phi[i,12,,])
    
      #simulate births
      atrisk=p0[4:8,2,]
      #pull values from iteration
      fr=f[i,,]
    
      births=matrix(sapply(atrisk,FUN = function(x) sum(rbinom(x,size=1,prob=fr[(which(atrisk==x,arr.ind=TRUE))])),simplify='array'),5,5)
      p1[i,1,1,] = apply(births,2,FUN=function(x) sum(rbinom(sum(x),size=1,prob=sexprop)))
      p1[i,1,2,] = colSums(births)-p1[i,1,1,]
    }
    
    return(p1)
}

#Prepare Holder variables, and simulate population change

future = 5 #how many iterations
p=list()
p[[1]] = sim(p0=p0)

for(y in 2:future){
  p0mean=apply(p[[y-1]],c(2,3,4),FUN=function(x) round(eff(x,c=.66)))[1,,,]
  p[[y]]=sim(p0=p0mean)
}

#cat('One simulation took',Sys.time()-st)-- 
#alittle over 30 seconds

#@@@@@
#output and figures
#@@@@@

#calculate proportions
props=list()
for(y in 1:future){
  props[[y]] = array(0,c(1800,5))
  for(i in 1:iters){
    props[[y]][i,] = apply(p[[y]][i,,,],3,FUN=function(x) sum(x)/sum(p[[y]][i,,,]))
  }
}

bprop=apply(p0,3,FUN=function(x) sum(x)/sum(p0))
base=rbind(bprop,bprop,bprop)
plt=lapply(props,FUN=function(x) apply(x,2,eff))
for(l in 1:5){plt[[(l+1)]]=plt[[l]]}
plt[[1]]=base
names(plt)=seq(2010,2010+(future*6),by=6)
nm=c('Evangelical','Mainline','Other','Catholic','None')
for(l in 1:6){colnames(plt[[l]])=nm}
plotdat = list()
for(l in 1:5){
  plotdat[[l]] = sapply(1:6,FUN=function(x) plt[[x]][,l]) 
}
names(plotdat)=nm

#line plot
par(mfrow=c(1,1))
plot(1,ylim=range(props),xlim=c(1,(future+1)),type='n',xaxt='n')
  for(l in 1:5){
    polygon(c(1:6,rev(1:6)),c(plotdat[[l]][2,],rev(plotdat[[l]][3,])),
            border=NA,col=paste0(colors1[l],'45'))
    
  }

  for(l in 1:5){
     lines(1:6,plotdat[[l]][1,],col=colors1[l],lty=l)
  }

axis(1,labels=seq(2010,2010+(future*6),by=6),at=1:6)

#barplots (18 years-- index no. 4)
par(mfrow=c(1,5), mar=c(1,1,1,1), oma=c(1,1,2,1))
yl = c(0,max(unlist(plotdat))+.05)
mp=barplot(plotdat[[1]][1,c(1,4)],ylim=yl,col=colors1[1],xlab='Evangelical')
  segments(mp[[2]],plotdat[[1]][2,4],mp[[2]],plotdat[[1]][3,4])
  text(mp[[1]],0,'2010',pos=3,cex=.75)
  text(mp[[2]],0,'2028',pos=3,cex=.75)
  mtext('Evangelical',side=1,cex=.75)
  
for(r in 2:5){  
mp=barplot(plotdat[[r]][1,c(1,4)],ylim=yl,axes=F,col=colors1[r],xlab=nm[r])
  segments(mp[[2]],plotdat[[r]][2,4],mp[[2]],plotdat[[r]][3,4])
  text(mp[[1]],0,'2010',pos=3,cex=.75)
  text(mp[[2]],0,'2028',pos=3,cex=.75)
  mtext(nm[r],side=1,cex=.75)
}
  
  mtext("Predicted Proportions in 2028",outer=TRUE,cex=1)