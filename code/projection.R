#
#Bryce Bartlett
#

#Equation
#p0 + births + conversions - apostates - deaths
#births - fertility model; the rest mnomial
#p0 - proportion distribution in 2010 - because that
#year is the center of the 2006 to 2014 panel sample used

#@@@@@@@@@@@@@
#preliminaries
#@@@@@@@@@@@@@

rm(list=ls())

source("H:/projects/rel_belong/code/config.R",
       echo =T, print.eval = T, keep.source=T)

#read data previously cleaned using ./prep-data.r
dat = read.csv(paste(outdir,'private~/subpanel.csv',sep=''))

#@@@@@@@@@@@@@
#Calculate p0--initial distribution
#@@@@@@@@@@@@@

#initialize p0 -- 6 year age intervals to 90 by religion,male,female
#female needs additional dim for nchildren decrement
ages=1:90
fages = unique(cut(ages,seq(0,90,by=6)))
table(cut(ages,seq(0,90,by=6)),ages)

p0.male = array(0,c(length(fages),5)); 
  dimnames(p0.male)=list(ages=fages,
                         rel=c('evangelical','mainline','other','catholic','none'))
p0.female = array(0,c(length(fages),5,3))
dimnames(p0.female)=list(ages=fages,
                         rel=c('evangelical','mainline','other','catholic','none'),
                         parity=c('0','1','2+'))

#limit to initial observation for everyone
base=dat[dat$panelwave==1,]

#cut ages - has to be 6; otherwise not enough pooling
#and cells will be off -- probably need to stratify by weight...
base$abin = cut(base$age,seq(18,90,by=6))
base$c = cut(base$childs,c(-1,0,1.5,8))
levels(base$c) = c('0','1','2+')
table(base[,c('c','childs')])

#calculate initial distributions
males=table(base[base$female==0,c('abin','reltrad')])
females=table(base[base$female==0,c('abin','reltrad','c')])

#add to p0
p0.male[(dim(p0.male)[1]-dim(males)[1]+1):dim(p0.male)[1],] = males
p0.female[(dim(p0.female)[1]-dim(females)[1]+1):dim(p0.female)[1],,]=females

#add babies, preteens, and teens, and impute gender
sexratio=1.06
feprop = 1-(sexratio/(sexratio+1))

#women only! -- not accurate probably
#otherwise proportion will be off, also aligned with assumptions
bs = aggregate(base$babies[base$female==1],by=list(base$reltrad[base$female==1]), sum,na.rm=T)
pt = aggregate(base$preteen[base$female==1],by=list(base$reltrad[base$female==1]),sum,na.rm=T)
t = aggregate(base$teens[base$female==1],by=list(base$reltrad[base$female==1]),sum,na.rm=T)

p0.male[1,] = round(bs[,2]*(1-feprop))
p0.male[2,] = round(pt[,2]*(1-feprop))
p0.male[3,] = round(t[,2]*(1-feprop))

#all females begin at parity = 0
p0.female[1,,1] = round(bs[,2]*feprop)
p0.female[2,,1] = round(pt[,2]*feprop)
p0.female[3,,1] = round(t[,2]*feprop)

print(p0.male)
print(p0.female)

totp = sum(p0.male)+sum(p0.female)

#translate to a radix of 100000
p0.female = round((p0.female/totp)*100000)
p0.male = round((p0.male/totp)*100000)

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


#rows ages 18-46 conditional fertility rates (qx) from model; 
# columns: rel.parity.iter
#this csv takes a lot of work to load!
fxj = read.csv(paste0(outdir,'fx-parity.csv'))

#mean six year estimates 
#create index
fxj$X = as.numeric(cut(1:29,c(seq(0,29,by=6),29)))
#collapse by means
fxj=aggregate(fxj,by=list(fxj$X),FUN=function(x) sum(x)/length(x))





###########################################
##EDIT
##HERE
###########################################

#getting fertility rates from fxj
#testl = grep('other',colnames(fxj))
#fxj.main = fxj[,c(testl)]
#View(t(fxj.main))

#testl2 = grep('\\.0\\.',colnames(fxj))
#fxj.0 = fxj[,c(testl2)]
#View(t(fxj.0))
  
#@@@@@@@@@@@@@@@@@
#Simulate future proportions
#@@@@@@@@@@@@@@@@@@

#include base data for repititions
p0.m=replicate(1800,p0.male,simplify='array') #replicate for 1800 
p0.m=aperm(p0.m,c(3,1,2)) #rearrange array

p0.f=replicate(1800,p0.female,simplify='array')
p0.f=aperm(p0.f,c(4,1,2,3))

#for testing
p.m = p0.m
p.f = p0.f

#function to simulate population change
sim=function(p.m,p.f){
  #helper function for simulating population proportions
  #p.m is an array of iters (1800), integers 15 age groups, 2 gender, and
  #5 religious belonging for males
  #p.f is the same, but includes an extra dimension for parity of births (0,1,2+)
  #f is boolean for female (includes birth simulations)
  #returns 1800 simulated population distributions 6 years later
  
    p1.m=array(0,c(dim(p.m)));dimnames(p1.m)=dimnames(p.m)
    p1.f=array(0,c(dim(p.f)));dimnames(p1.f)=dimnames(p.f)
    
    #@@
    #draw posterior predictives for 
    #@@
    
    #cat('Beginning Simulation...\n')
    #st = Sys.time()
    
    for(i in 1:iters){
      if(i%%100==0){cat(i,'of',iters,'\n')}
      
      #check cohort component method -- may need to mean over interval ((x1+x2)/2)
      #sumulate *minor* survival (assuming religion changes)
      p1.m[i,2,] = mapply(p.m[i,1,],FUN=function(x) survive(x,sum(px.minors[1:3])))
      p1.m[i,3,] = mapply(p.m[i,2,],FUN=function(x) survive(x,sum(px.minors[4:6])))
      p1.m[i,4,] = mapply(p.m[i,3,],FUN=function(x) survive(x,sum(px.minors[7:9])))
    
      #children all have parity of 0 (i.e. 0 children)
      p1.f[i,2,,1] = mapply(p.f[i,1,,1],FUN=function(x) survive(x,sum(px.minors[1:3])))
      p1.f[i,3,,1] = mapply(p.f[i,2,,1],FUN=function(x) survive(x,sum(px.minors[4:6])))
      p1.f[i,4,,1] = mapply(p.f[i,3,,1],FUN=function(x) survive(x,sum(px.minors[7:9])))

      #births and parity transition (without mortality)
      for(a in 4:8){
        p.f[i,]
      }
      
      
      #simulate transitions for adults
      for(a in 5:14){
       p1.m[i,a,] = trns(p.m[i,a-1,],prob=phi[i,a-4,,])
       for(c in 1:3){
         p1.f[i,a,,c] = trns(p.f[i,a-1,,c],prob=phi[i,a-4,,])
       }
      }
    
      #calculate final transition
      p1[i,15,]=trns(p0[i,14,],prob=phi[i,11,,])+trns(p0[i,15,],prob=phi[i,12,,])

      
################      
#EDIT HERE
################
      
      #simulate births
      atrisk=p0[i,4:8,2,]
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
pfirst = array(0,c(iters,dim(p0)))
nm=list(1:iters);names(nm)='iter'; nm=c(nm,dimnames(p0))
dimnames(pfirst)=nm  

for(i in 1:iters){pfirst[i,,,]=p0}
p[[1]] = sim(p0=pfirst)

for(y in 2:future){
  p[[y]]=sim(p0=p[[(y-1)]])
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

png(paste0(draftimg,'project-bar.png'),height=9,width=18,units='in',res=300)

#barplots (18 years-- index no. 4)
par(mfrow=c(1,5), mar=c(2,1,1,1), oma=c(1,1,4,1))
yl = c(0,max(unlist(plotdat))+.05)
mp=barplot(plotdat[[1]][1,c(1,4)],ylim=yl,col=colors1[1],xlab='Evangelical')
  segments(mp[[2]],plotdat[[1]][2,4],mp[[2]],plotdat[[1]][3,4])
  text(mp[[1]],0,'2010',pos=3,cex=1.75)
  text(mp[[2]],0,'Stable',pos=3,cex=1.75)
  mtext('Evangelical',side=1,cex=1.75,padj=.75)
  
for(r in 2:5){  
mp=barplot(plotdat[[r]][1,c(1,4)],ylim=yl,axes=F,col=colors1[r],xlab=nm[r])
  segments(mp[[2]],plotdat[[r]][2,4],mp[[2]],plotdat[[r]][3,4])
  text(mp[[1]],0,'2010',pos=3,cex=1.75)
  text(mp[[2]],0,'Stable',pos=3,cex=1.75)
  mtext(nm[r],side=1,cex=1.75,padj=.75)
}
  
  mtext("Simulated Change in Proportions to Stable Distribution",outer=TRUE,cex=3)
  
dev.off()

#growth of proportions
print(plotdat)

#(Big) table of proportion changes

#calculate totls of age group
tots = apply(p[[5]],c(1,2),sum)
d = apply(tots,2,eff)

#age distributions 12 years later -- fertility is too low
plot(d[1,],ylim=range(d))
segments(1:15,d[2,],1:15,d[3,])
agep=apply(p0,1,sum)
lines(agep,type='p',pch=3)

#create proportion of age groups by tradition
stable = apply(p[[5]],c('iter','abin','reltrad'),sum)
for(i in 1:1800){
  stable[i,,] = stable[i,,]/tots[i,]
}

ageprop = apply(stable,c('abin','reltrad'),eff)

png(paste0(draftimg,'2040_prop.png'))
mp=barplot(t(ageprop[1,,]),col=colors1,horiz=TRUE,yaxt='n',
           main='Proportion of age-group by Tradition, 2040',
           cex.main=1)
#segments(ageprop[2,,1],mp,ageprop[3,,1],mp)
#segments(1-ageprop[2,,5],mp,1-ageprop[3,,5],mp)
axis(2,labels=seq(0,14*6,by=6),at=mp)
legend('bottom',names(plotdat),fill=colors1,bty='n',cex=.75,
       xpd=TRUE,horiz=TRUE,inset=-.2)
dev.off()
