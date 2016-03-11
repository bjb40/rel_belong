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

#read data previously cleaned using ./prep-data.r
dat = read.csv(paste(outdir,'private~/subpanel.csv',sep=''))


#@@@@@@@@@@@@@
#Calculate p0
#@@@@@@@@@@@@@

#limit to 2010 sample
base=dat[dat$year==2010,]

#cut ages
base$abin = cut_width(base$age,6,boundary=18)
#add babies, preteens and teens
bs = aggregate(base$babies,by=list(base$reltrad), sum,na.rm=T)

#calculate initial distributions
adults=table(base[,c('abin','female','reltrad')])

#add babies, preteens, and teens, with missing gender
sexratio=1.06
feprop = 1-(sexratio/(sexratio+1))

bs = aggregate(base$babies,by=list(base$reltrad), sum,na.rm=T)
pt = aggregate(base$preteen,by=list(base$reltrad),sum,na.rm=T)
t = aggregate(base$teens,by=list(base$reltrad),sum,na.rm=T)

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

#@@@@@@@@@@@@@
#Calculate Births 
#@@@@@@@@@@@@@



#@@@@@@@@@@@@@
#Calculate Conversions, Apostasies, and Deaths
#@@@@@@@@@@@@@


