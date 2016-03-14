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
round(prop.table(p0)*100000)

#proportion
barplot(apply(p0,3,FUN=function(x) sum(x)/sum(p0)),col=colors1)

#@@@@@@@@@@@@@
#Calculate Conversions, Apostasies, and Deaths
#@@@@@@@@@@@@@
#similar to lifetable.R, but projecting forward
#read in life table values

#calculate 6 year probabilities (dividing lx / lx+6)
#see prob set 3 in demography i exercizes for examples
l = read.csv(paste0(outdir,'l.csv'))

#calculate survival probabilities for children 
#using the 2010 published life table in same manner
ageints=max(l$ageint)
iters=max(l$iter)
#tst = array(unlist(l[,3:ncol(l)]),c(iters,ageints,6,6))
lx=array(0,c(iters,ageints,6,6))
for(i in 1:iters){
  lx[i,,,] = array(unlist(l[l$iter==i,3:ncol(l)]),c(ageints,6,6))
}

#create 6-year intervals of probabilities for converts, apostates, death
#sum of probabilities 2-year (??) (survive or convert...)


#@@@@@@@@@@@@@
#Calculate Births 
#@@@@@@@@@@@@@

#calculate predicted mean fertility rates by 6 year age intervals
#p. 114
