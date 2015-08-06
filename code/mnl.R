#@@@@@@@@@@@@@@@@@@@@@@@@@@
#dev R 3.2.1 "World-Famous Astronaut"
#develping increment-decrement tables as found in Lynch 2005, 2007, 2010
#using Bayesian Statistics
#Bryce Bartlett
#@@@@@@@@@@@@@@@@@@@@@@@@@@

require('MCMCpack')

#load universals configuration file
source("H:/projects/rel_belong/code/config.R",
       echo =T, print.eval = T, keep.source=T)


#@@@@
#Load and clean data
#@@@@

#read data previously cleaned using ./prep-data.r
dat = read.csv(paste(outdir,'private~/subpanel.csv',sep=''))
  
#prepare dataset for MCMCmnl
usedat = subset(dat,select=c(reltrad,female))
rm(dat)


attach(usedat)

#estimate model
mnl.post = MCMCmnl(reltrad~female,
               mcmc.method='IndMH',verbose=500,mcmc=1000)


detach(usedat)

