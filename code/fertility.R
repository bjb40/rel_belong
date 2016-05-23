#Bryce Bartlett
#Makes fertility rates
#Dev R 3.3.0 "Supposedly Educational"
#Stan 2.9

#@@@@@
#Preliminaries and load data
#@@@@@

rm(list=ls())

source("H:/projects/rel_belong/code/config.R",
       echo =T, print.eval = T, keep.source=T)

#savefert = fertpanel
fertpanel = read.csv(paste0(outdir,'private~/fertpanel.csv'))


#@@@@
#assign variables
#@@@@

#listwise delete
print(c(nrow(fertpanel),length(unique(fertpanel$idnump))))
fertpanel = na.omit(fertpanel)
print(c(nrow(fertpanel),length(unique(fertpanel$idnump))))

#######################
# Because this is a repeated event, and the GSS occurs every 2 years
# everyone is observed twice (because they are still at risk)
# so, I duplicate observations
######################

fert2 = fertpanel
#clear out already observed births
fert2$birth[fertpanel$birth==1 & fertpanel$nchilds %in% c(0,1)] = 0
fert2$childs[fertpanel$birth==1 & fertpanel$nchilds > 0] = 
  fert2$childs[fertpanel$birth==1 & fertpanel$nchilds > 0] + 1
fert2$panelwave = fert2$panelwave + .5
fert2$age = fert2$age+1

fertpanel = rbind(fertpanel,fert2)
#rm(fert2)

cat(sum(fertpanel$birth),sum(fert2$birth))

#print 6 random individuals
ids = sample(unique(fertpanel$idnump[fertpanel$birth==1]),2)
ids = c(ids,sample(unique(fertpanel$idnump[fertpanel$birth==0]),2))
ids = c(ids,sample(unique(fertpanel$idnump[fertpanel$nchilds>1]),2))

#old
#print(savefert[savefert$idnump %in% ids ,c('idnump','panelwave','childs','nchilds','birth')])

#recoded doubled up
print(fertpanel[fertpanel$idnump %in% ids ,c('idnump','panelwave','childs','nchilds','birth')])

#dummy series for parity
fertpanel$c = 0
fertpanel$c[fertpanel$childs==1] = 1
fertpanel$c[fertpanel$childs>=2] = 2
#fertpanel$c[fertpanel$childs>2] = 3

table(fertpanel[,c('childs','c')])

fertpanel$c = as.factor(fertpanel$c)

#prepare age dummies
fertpanel$agef = cut(fertpanel$age,c(17,22,26,30,34,38,46))

fertpanel$reltrad = factor(fertpanel$reltrad,labels=c('evang','mainline','other','catholic','none'))

#@@@@@@@
#frequentist test
#@@@@@@@

#mean(fertpanel$age)
fertpanel$c_age = fertpanel$age - mean(fertpanel$age) 
fertpanel$c_age2=fertpanel$c_age*fertpanel$c_age

fert_freq = glm(birth ~ agef + reltrad + c + c:reltrad + c:agef + white + married + educ + rswitch,
    data=fertpanel,family='binomial')

sink(paste0(outdir,'freq_logistic.txt'))
  summary(fert_freq)
sink()

rm(fert_freq)

#@@@@@@@
#set up data for stan
#@@@@@@@

#cyrus stata code : 1) evangelical (ref); 2) mainline; 3)other; (4) catholic; (5) none
y=fertpanel$birth
x = model.matrix(~ ~ agef + reltrad + c + c:reltrad + c:agef + white + married + educ + rswitch,
                 data=fertpanel)
N=nrow(fertpanel)
D=ncol(x)

#@@@@@@
#call stan and sample
#@@@@@@

#Record start time
st = Sys.time()

library('rstan')

#detect cores to activate parallel procesing
rstan_options(auto_write = TRUE)
#options(mc.cores = parallel::detectCores())
options(mc.cores = 3) #leave one core free for work

fert <- stan("fertility.stan", data=c("D", "N", "y", "x"),
            #algorithm='HMC',
            chains=3,iter=1200,verbose=T)
            #sample_file = paste0(outdir,'diagnostic~/post-samp.txt'),
            #diagnostic_file = paste0(outdir,'diagnostic~/stan-diagnostic.txt'),
            #open_progress=T);

#print time taken
print(Sys.time() - st)

#@@@@
#print table and graph of preicted probabilities
#@@@@

effnames = colnames(x)
fertpost=extract(fert,pars='beta',permuted=TRUE,inc_warmup=FALSE)

sink(paste0(outdir,'bayesian_logistic_table.txt'))
  cat('Bayesian logistic estimates for log odds of having a child in the next two years (women 18-45).\n\n')
  cat('|  |  |\n')
  cat('|:----|----:|\n')
  for(e in 1:length(effnames)){
    cat('|',effnames[e],'|');printeff(fertpost$beta[,e]); cat('|\n')
  }
  cat('\nNote: Mean estimates with 95% C.I. Bold indicates different from 0.\n\n')
  
  cat('\n\nFit Statistics\n')
  cat('WAIC (two versions)\n')
  print(waic(fert))
  w2=waic2(fert)
  print(w2$total); print(w2$se); rm(w2)
  
  cat('DIC')
  print(dic(fert))
  
sink()

rm(effnames)

write.csv(fertpost,paste0(outdir,'fertposterior.csv'))

makeprob = function(logodds){
  o = exp(logodds)
  return(o/(1+o))
}

ages=18:46
meanages = mean(fertpanel$age,na.rm=T)
c_ages = ages - meanages
c_ages2 = ages*ages

#calculate length for unique across c values and religion values
cv = unique(fertpanel$c); rv = unique(fertpanel$reltrad); cv=cv[order(cv)]; rv=rv[order(rv)]
nr = length(c_ages)*length(cv)*length(rv)

#create block of empty data for each of the 3 parity values across all values
simdat = matrix(NA,nr,7)
colnames(simdat) = c('c_age','c_age2','reltrad','c','married','educ','rswitch')
simdat=data.frame(simdat)

#fill in basic data
simdat$age=ages
simdat$c_age = c_ages; simdat$c_age2=c_ages2
simdat$reltrad[order(simdat$c_age)] = rep(rv,nrow(simdat)/length(rv))
simdat$c[order(simdat$c_age)] = rep(as.character(cv),nrow(simdat)/length(cv))

simdat$agef = cut(simdat$age,c(17,22,26,30,34,38,46))

#input covariates at observed means
simdat$married = mean(fertpanel$married)
simdat$educ = mean(fertpanel$educ)
simdat$rswitch = mean(fertpanel$rswitch)
simdat$white = mean(fertpanel$white)

#check coding
View(simdat[order(simdat$reltrad,simdat$c),])

simdat$reltrad = factor(simdat$reltrad, labels = as.character(rv))

simx = model.matrix(~ ~ agef + reltrad + c + c:reltrad + c:agef + white + married + educ + rswitch,
                        data=simdat)

#rearrange column order to reproduce order of estimated design
#simx = simx[,colnames(x)]

#confirm same columns are in the right spot
if(all(colnames(simx) == colnames(x)) == FALSE){
  stop('Error in simx structure. Double check!!')
}

#holder for predicted probs
simprob=matrix(NA,nrow(simdat),nrow(fertpost$beta))

#calculate predicted probs
for(s in 1:nrow(fertpost$beta)){
  simprob[,s] = makeprob(simx%*%fertpost$beta[s,])
}


#code for plotting
#cyrus stata code : 1) evangelical (ref); 2) mainline; 3)other; (4) catholic; (5) none

plotdat = list()
"plotdat$evangelical = simprob[simdat$reltrad=='evang',]
plotdat$mainline = simprob[simdat$reltrad=='mainline',]
plotdat$other = simprob[simdat$reltrad=='other',]
plotdat$catholic = simprob[simdat$reltrad=='catholic',]
plotdat$none = simprob[simdat$reltrad=='none',]"

fx.evangelical=list()
fx.mainline=list()
fx.other=list()
fx.catholic=list()
fx.none=list()

cs = unique(simdat$c)

for(c in cs){
  fx.evangelical[[c]] = simprob[simdat$reltrad=='evang' & simdat$c == c,]
  fx.mainline[[c]] = simprob[simdat$reltrad=='mainline'& simdat$c == c,]
  fx.other[[c]] = simprob[simdat$reltrad=='other'& simdat$c == c,]
  fx.catholic[[c]] = simprob[simdat$reltrad=='catholic'& simdat$c == c,]
  fx.none[[c]] = simprob[simdat$reltrad=='none'& simdat$c == c,]

}

fx = list(fx.evangelical,fx.mainline,fx.other,fx.catholic,fx.none)
names(fx) = c('evangelical','mainline','other','catholic','none')

#helper function to generate mean and ci by parity
genplot=function(l){
  #input list; output summary of 
  return(lapply(l,FUN=function(x) apply(x,1,eff,c=.84)))
}

#gen summaries
plotdat = lapply(fx,genplot)

yl=range(unlist(plotdat))
xl=range(ages)

#colsf = rainbow(s=1,v=.75,5,alpha=.1)
#cols = rainbow(s=1,v=1,5)
colsf=terrain.colors(5,alpha=.25)
cols=terrain.colors(5)

#png(paste0(draftimg,'age-fertility.png'),height=9,width=18,units='in',res=300)
par(mfrow=c(length(cs),1))

for(c in 1:length(cs)){
  plot(ages,rep(1,length(ages)),ylim=yl,xlim=xl,type='n',
       main='Probability of New Child by Age (Women Only)', cex.main=.75,xlab='',ylab='')
    #ci-polygon
    lapply(1:5,function(x)
                polygon(c(ages,rev(ages)),c(plotdat[[x]][[c]][2,],rev(plotdat[[x]][[c]][3,])),
                                           border=NA,col=paste0(colors1[x],'45'))
    )
    #mean probability-line
    lapply(1:5,function(x) 
      lines(ages,plotdat[[x]][[c]][1,],col=colors1[x],lty=x,lwd=3)
    )


  if(c == 1){
    #add legend
    legend('topright',legend=c('Evangelical','Mainline','Other','Catholic','None'),
           bty='n',
           lty=1:5,lwd=rep(3,5),
           col=colors1, cex=.5)
  }

} #end plotting

#dev.off()

  #tfr by religion

#this is wrong -- need dxj per pp. 10 and 11 of van hook et al.
#need a multiple decrement life table set up (pooled means...)
  
sink(paste(outdir,'tfr.txt'))
  cat('median tfr with 84% intervals by religious tradition\n\n')
  print(rv); cat('\n\n')
  #1.9 is current US average
  for(r in unique(simdat$reltrad)){  
    tfr = apply(simprob[simdat$reltrad==r,],2,sum)
    cat('median + 84% intervals \n')
    cat(r,eff(tfr,c=.84),'\n')
    cat('mean + 95% intervals\n')
    cat(r,eff(tfr,c=.95,usemean=TRUE), '\n\n')
  }

sink()