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

#transition/mortality rates calculated by mnl logistic
phi = read.csv(paste0(outdir,'phi.csv'))

#fertility rates calculated by logistic
load(paste0(outdir,'fx.RData'))

#size of sampel is 1800; I'm going to randomly draw from that based on the number below, however
iters=500

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

ageints=max(phi$ageint)
itrs=max(phi$iter)
#tst = array(unlist(l[,3:ncol(l)]),c(iters,ageints,6,6))
phix=array(0,c(itrs,ageints,6,6))
for(i in 1:itrs){
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

#include base data for repititions
p0.m=replicate(iters,p0.male,simplify='array') #replicate for 1800 
p0.m=aperm(p0.m,c(3,1,2)) #rearrange array

p0.f=replicate(iters,p0.female,simplify='array')
p0.f=aperm(p0.f,c(4,1,2,3))

#for testing
#p.m = p0.m
#p.f = p0.f
#i=1

#create temporary mortality and fertility samples; names will be replaced in function below
fullphi = phi; rm(phi)
fullfx = fx; rm(fx)


#function to simulate population change
sim=function(plist){
  #helper function for simulating population proportions
  #send it a list of two arrays as follows
  
  #p.m is an array of iters (1800), integers 15 age groups, 2 gender, and
  #5 religious belonging for males
  #p.f is the same, but includes an extra dimension for parity of births (0,1,2+)
  #f is boolean for female (includes birth simulations)
  #returns 1800 simulated population distributions 6 years later
    
    p.m = plist[[1]]
    p.f = plist[[2]]
    
    p1.m=array(0,c(dim(p.m)));dimnames(p1.m)=dimnames(p.m)
    p1.f=array(0,c(dim(p.f)));dimnames(p1.f)=dimnames(p.f)
    
    #@@
    #draw random posterior predictives for fertility and transition 
    #@@
    
    #create a vector of random values for iter sample
    samp = sample((1:1800),iters)
    
    cat('Sampling',iters,'estimates from fertility and mortality posteriors.\n\n')
    
    #create samples
    phi = fullphi[samp,,,]
    fx = lapply(fullfx,FUN=function(x) simplify2array(x,higher=TRUE)[,samp,])
    
    #@@
    #iterate through sample
    #@@

    for(i in 1:iters){
      #print whenever 10% more complete
      if(i==1 | i%%50==0){
        cat(i,'of',iters,'\n')
        if(i>1){print(Sys.time()-st_time)} else{
          print(paste('Starting simulation at',Sys.time()))
        }
        
        st_time=Sys.time()
        }
      
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
      #an array that will collapse by means
      fa = as.numeric(cut(1:29,c(seq(0,29,by=6),29))) + 3
      births = numeric(5) #holder for births by religion
      
      for(a in 4:8){
        #loop over religion (top list)
       for (rel in 1:5){
         qxj = fx[[rel]][,i,]
         #construct transition matrix (see note in fertility.R for more info)
         
         fm = matrix(0,3,3)
         fm[1,2] = mean(qxj[a == fa,1]); fm[1,1] = 1-mean(qxj[a==fa,1])
         fm[2,3] = mean(qxj[a==fa,2]); fm[2,2] = mean(1-qxj[a==fa,2])
         #fm[3,3] = 1
         fm[3,3]=mean(qxj[a==fa,3]) #--decrement vs. new births as repeated event !! Confusing!
         
         #births and parity transition across current states (need to multiply by 6 for each year!)
         #need to center on mean age for half/half
         tr = diag(p.f[1,a,rel,]) %*% fm
         births[rel] = births[rel] + round((tr[1,2]+tr[2,3]+tr[3,3])*6)
         
         fm[3,3] = 1 #births counted, now save as absorbing decrement!!
         #calculate next years' decrement--BUT KEEP IN THIS TEMP FILE FOR MORTALITY TR
         p.f[i,a,rel,] = colSums(diag(p.f[1,a,rel,]) %*% fm); 
         
       }#end religion loop
      }#end age loop
      
      #add births by religion
      f.births = mapply(births,FUN=function(x) rbinom(1,x,feprop))
      m.births = births-f.births
      p1.m[i,1,] = m.births
      p1.f[i,1,,1] = f.births
      
      #simulate transitions for adults
      for(a in 5:14){
       p1.m[i,a,] = trns(p.m[i,a-1,],prob=phi[i,a-4,,])
       for(c in 1:3){
         p1.f[i,a,,c] = trns(p.f[i,a-1,,c],prob=phi[i,a-4,,])
       }
      }
    
      #calculate final transition
      p1.m[i,15,]=trns(p.m[i,14,],prob=phi[i,11,,])+trns(p.m[i,15,],prob=phi[i,12,,])
      p1.f[i,15,,]=trns(p.f[i,14,,],prob=phi[i,11,,])+trns(p.f[i,15,,],prob=phi[i,12,,])
    }
    
    return(list(male=p1.m,female=p1.f))
}

#helper function for getting populatin proporitions
s_prop = function(poplist){
  #input is list of male/female list form above
  #output is list including
  # 1 sample of age-distribution by religion 
  # 2 samplle with sum of religion only
  
  agestruct = poplist[[1]] + apply(poplist[[2]],c(1,2,3),sum)
  religion = apply(agestruct,c(1,3),sum)
  
  return(list(agestructure=agestruct/rowSums(agestruct),relonly=religion/rowSums(religion)))
  
} 

#Prepare Holder variables, and simulate population change
p0 = list(male=p0.m,female=p0.f)

future = 10 #how many iterations x6 years each
p=list(p0)
for(y in 1:future){
  p[[y+1]] = sim(p[[y]])
}

#project population proportions by religion only
props=lapply(p,FUN=function(x) apply(s_prop(x)[[2]],2,eff,c=.95))


#@@@@@
#output and figures
#@@@@@

props=simplify2array(props,higher=TRUE)
aperm(props,c(3,2,1))

nm=c('Evangelical','Mainline','Other','Catholic','None')

ys=dim(props)[3]

png(paste0(draftimg,'line-project.png'),height=6.5,width=9,units='in',res=300)

#line plot
par(mfrow=c(1,1))
plot(1,ylim=c(0,max(props)),xlim=c(1,ys),type='n',xaxt='n',xlab='',ylab='Proportion of Population')
  for(l in 1:5){
    polygon(c(1:ys,rev(1:ys)),c(props[2,l,],rev(props[3,l,])),
            border=NA,col=paste0(colors1[l],'45'))
    
  }

  for(rel in 1:5){
     lines(props[1,rel,],col=colors1[rel],lty=rel)
  }

axis(1,labels=seq(2010,2010+(future*6),by=6),at=1:ys)
legend('bottom',nm,lty=1:5,bty='n',col=colors1,cex=.7,horiz=TRUE)
dev.off()

