#Bryce Bartlett
#Makes fertility rates
#Dev R ""



#@@@@@
#Preliminaries and load data
#@@@@@

source("H:/projects/rel_belong/code/config.R",
       echo =T, print.eval = T, keep.source=T)

#@@@@
#assign variables
#@@@@

#listwise delete
print(c(nrow(fertpanel),length(unique(fertpanel$idnump))))
fertpanel = na.omit(fertpanel)
print(c(nrow(fertpanel),length(unique(fertpanel$idnump))))

#mean center age
fertpanel$c_age = fertpanel$age - mean(fertpanel$age)
fertpanel$age2 = fertpanel$age^2
fertpanel$c_age2 = fertpanel$c_age^2

for(var in 2:5){
  fertpanel[,paste0('c_agexreltrad',var)] = fertpanel$c_age * fertpanel[,paste0('reltrad',var)]
  fertpanel[,paste0('c_age2xreltrad',var)] = fertpanel$c_age2 * fertpanel[,paste0('reltrad',var)]
  
}

#cyrus stata code : 1) evangelical (ref); 2) mainline; 3)other; (4) catholic; (5) none
y=fertpanel$birth
fertpanel$intercept = 1
#age^2 has no effect
x=fertpanel[,c('intercept','c_age','c_age2','married','educ',
               paste0('reltrad',2:5),paste0('c_agexreltrad',2:5),paste0('c_age2xreltrad',2:5),'rswitch')]
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

sink(paste0(outdir,'bayesian_logistic_table.txt'))
  cat('Bayesian logistic estimates for log odds of having a child in the next two years (women 18-45).\n\n')
  cat('|  |  |\n')
  cat('|:----|----:|\n')
  for(e in 1:length(effnames)){
    cat('|',effnames[e],'|');printeff(fertpost$beta[,e]); cat('|\n')
  }
  
  cat('\nNote: Mean estimates with 95% C.I. Bold indicates different from 0.')
sink()

rm(effnames)

fertpost=extract(fert,pars='beta',permuted=TRUE,inc_warmup=FALSE)
write.csv(fertpost,paste0(outdir,'fertposterior.csv'))

makeprob = function(logodds){
  o = exp(logodds)
  return(o/(1+o))
}

#genrate simulation data for plotting

ages=18:45
meanages = mean(fertpanel$age,na.rm=T)
c_ages = ages - meanages

simdat = matrix(NA,5*length(ages),ncol(x))
colnames(simdat) = colnames(x)
simdat=data.frame(simdat)

simdat$intercept=rep(1,nrow(simdat)); simdat$c_age=rep(c_ages,5); simdat$c_age2=rep(c_ages^2,5)
simdat$married=rep(1,nrow(simdat)); simdat$educ=12; simdat$rswitch=0
simdat$reltrad2=c(rep(0,length(ages)),rep(1,length(ages)),rep(0,length(ages)*3))
simdat$reltrad3=c(rep(0,length(ages)*2),rep(1,length(ages)),rep(0,length(ages)*2))
simdat$reltrad4=c(rep(0,length(ages)*3),rep(1,length(ages)),rep(0,length(ages)))
simdat$reltrad5=c(rep(0,length(ages)*4),rep(1,length(ages)))

for(var in 2:5){
  simdat[,paste0('c_agexreltrad',var)] = simdat$c_age * simdat[,paste0('reltrad',var)]
  simdat[,paste0('c_age2xreltrad',var)] = simdat$c_age2 * simdat[,paste0('reltrad',var)]
}


#holder for predicted probs
simprob=matrix(NA,nrow(simdat),nrow(fertpost$beta))

#calculate predicted probs
for(s in 1:nrow(fertpost$beta)){
  simprob[,s] = makeprob(as.matrix(simdat)%*%fertpost$beta[s,])
}

#write simprob to csv with ages for projection
reltrads = rep(0,nrow(simprob))
  reltrads[simdat$reltrad2==1] =2
  reltrads[simdat$reltrad3==1] =3 
  reltrads[simdat$reltrad4==1] =4 
  reltrads[simdat$reltrad5==1] =5 
  reltrads[reltrads==0] = 1

fertprobs = cbind(simdat$c_age+meanages,reltrads,simprob)
colnames(fertprobs) = c('age','reltrad',paste0('iter',1:1800))

write.csv(fertprobs,paste0(outdir,'fertprobs.csv'))

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

png(paste0(draftimg,'age-fertility.png'),height=9,width=18,units='in',res=300)
plot(ages,rep(1,length(ages)),ylim=yl,xlim=xl,type='n',
     main='Age-Specific Fertility Probabilities', cex.main=3,xlab='',ylab='')
  #ci-polygon
  lapply(1:5,function(x)
              polygon(c(ages,rev(ages)),c(plotdat[[x]][2,],rev(plotdat[[x]][3,])),
                                         border=NA,col=paste0(colors1[x],'45'))
  )
  #mean probability-line
  lapply(1:5,function(x) 
    lines(ages,plotdat[[x]][1,],col=colors1[x],lty=x)
  )
  
  #add legend
  legend('topright',legend=c('Evangelical','Mainline','Other','Catholic','None'),
         bty='n',
         lty=1:5,
         col=colors1, cex=1.75)

dev.off()


