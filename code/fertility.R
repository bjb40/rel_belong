#Bryce Bartlett
#Makes fertility rates
#Dev R 3.3.0 "Supposedly Educational"
#Stan 2.9

#@@@@@
#Preliminaries and load data
#@@@@@

#savefert = fertpanel
fertpanel = savefert

source("H:/projects/rel_belong/code/config.R",
       echo =T, print.eval = T, keep.source=T)

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
print(savefert[savefert$idnump %in% ids ,c('idnump','panelwave','childs','nchilds','birth')])

#recoded doubled up
print(fertpanel[fertpanel$idnump %in% ids ,c('idnump','panelwave','childs','nchilds','birth')])

#dummy series for parity
fertpanel$c = 0
fertpanel$c[fertpanel$childs==1] = 1
fertpanel$c[fertpanel$childs==2] = 2
fertpanel$c[fertpanel$childs>2] = 3

table(fertpanel[,c('childs','c')])

fertpanel$c = as.factor(fertpanel$c)

#prepare age dummies
fertpanel$agef = cut(fertpanel$age,c(17,22,26,34,38,42,46))

fertpanel$reltrad = factor(fertpanel$reltrad,labels=c('evang','mainline','other','catholic','none'))

#@@@@@@@
#frequentist test
#@@@@@@@

#mean(fertpanel$age)
fertpanel$c_age = fertpanel$age - mean(fertpanel$age) 
fertpanel$c_age2=fertpanel$c_age*fertpanel$c_age

fert_freq = glm(birth ~ c_age + c_age2 + c + c_age:c + c_age2:c + reltrad + reltrad:c_age +reltrad:c_age2 + married + educ + rswitch,
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
x = model.matrix(~c_age + c_age2 + c + c_age:c + c_age2:c + reltrad + reltrad:c_age +reltrad:c_age2 + married + educ + rswitch,
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

#input covariates at observed means
simdat$married = mean(fertpanel$married)
simdat$educ = mean(fertpanel$educ)
simdat$rswitch = mean(fertpanel$rswitch)

#check coding
View(simdat[order(simdat$reltrad,simdat$c),])

simdat$reltrad = factor(simdat$reltrad, labels = as.character(rv))

simx = model.matrix(~c_age + c_age2 + c + c_age:c + c_age2:c + reltrad + reltrad:c_age +reltrad:c_age2 + married + educ + rswitch,
                        data=simdat)

#rearrange column order to reproduce order of estimated design
#simx = simx[,colnames(x)]

#confirm same columns are in the right spot
colnames(simx) == colnames(x)

#holder for predicted probs
simprob=matrix(NA,nrow(simdat),nrow(fertpost$beta))

#calculate predicted probs
for(s in 1:nrow(fertpost$beta)){
  simprob[,s] = makeprob(simx%*%fertpost$beta[s,])
}

#########################################################################
#########################################################################
#EDIT HERE 
##########################################################################
##########################################################################

#code for plotting
#cyrus stata code : 1) evangelical (ref); 2) mainline; 3)other; (4) catholic; (5) none
plotdat = list()
plotdat$evangelical = simprob[simdat$reltrad2==0 & simdat$reltrad3==0 & simdat$reltrad4==0 & simdat$reltrad5==0,]
plotdat$mainline = simprob[simdat$reltrad2==1,]
plotdat$other = simprob[simdat$reltrad3==1,]
plotdat$catholic = simprob[simdat$reltrad4==1,]
plotdat$none = simprob[simdat$reltrad5==1,]

#generate mean and 95% ci (should actually get median...)
plotdat = lapply(plotdat,FUN=function(x) apply(x,1,eff,c=.84))

yl=range(plotdat)
xl=range(ages)
#create plot of fertility rates with 84% ci
#this is wierd that it calculates the probabilty over the next two years -- can i divide by 2? 

#colsf = rainbow(s=1,v=.75,5,alpha=.1)
#cols = rainbow(s=1,v=1,5)
colsf=terrain.colors(5,alpha=.25)
cols=terrain.colors(5)

#png(paste0(draftimg,'age-fertility.png'),height=9,width=18,units='in',res=300)
plot(ages,rep(1,length(ages)),ylim=yl,xlim=xl,type='n',
     main='Probability of New Child by Age (Women Only)', cex.main=.75,xlab='',ylab='')
  #ci-polygon
  lapply(1:5,function(x)
              polygon(c(ages,rev(ages)),c(plotdat[[x]][2,],rev(plotdat[[x]][3,])),
                                         border=NA,col=paste0(colors1[x],'45'))
  )
  #mean probability-line
  lapply(1:5,function(x) 
    lines(ages,plotdat[[x]][1,],col=colors1[x],lty=x,lwd=3)
  )
  
  #add legend
  legend('topright',legend=c('Evangelical','Mainline','Other','Catholic','None'),
         bty='n',
         lty=1:5,lwd=rep(3,5),
         col=colors1, cex=.5)

#dev.off()

  #tfr by religion

  #1.9 is current US average
for(rel in unique(fertprobs[,'reltrad'])){  
  tfr = apply(fertprobs[fertprobs[,'reltrad']==rel,],2,sum)
  cat(rel,eff(tfr),'\n')
}

