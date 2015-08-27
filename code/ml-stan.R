#@@@@@@@@@@@@@@@@@@@@@@@@@@
#dev R 3.2.1 "World-Famous Astronaut"
#Requires Rstan (dev 2.7.0; same version as Stan) 
#develping increment-decrement tables as found in Lynch 2005, 2007, 2010
#using Bayesian Statistics
#Bryce Bartlett
#@@@@@@@@@@@@@@@@@@@@@@@@@@


#load universals configuration file
source("H:/projects/rel_belong/code/config.R",
       echo =T, print.eval = T, keep.source=T)



#@@@@@@@@@@@@@
#prep stan input
#@@@@@@@@@@@@@

#read data previously cleaned using ./prep-data.r
dat = read.csv(paste(outdir,'private~/subpanel.csv',sep=''))

y = as.integer(dat$reltrad)
x = as.matrix(subset(dat,
                     select=c(reltrad_last2,reltrad_last3,reltrad_last4,reltrad_last5,
                              female,married,white,age)
                     ))
xmat = cbind(rep(1,nrow(x)),x) #add intercept

D=ncol(xmat)
K=length(unique(y))
N=nrow(dat)

#@@@@@@@@@@@@@
#call stan model
#@@@@@@@@@@@@@

#Record start time
st = Sys.time()

library('rstan')

#detect cores to activate parallel procesing
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

fit <- stan("mnl.stan", data=c("K", "D", "N", "y", "xmat"),
            chains=4, iter=5000, seed=1234,verbose=T);

#print time taken
print(Sys.time() - st)

#@@@@@@@@@@@@@
#posterior analysis
#@@@@@@@@@@@@@

print(summary(fit))

#export sample of covariate profiles

write.csv(extract(fit,pars='beta'),paste(outdir,'post.csv',sep=''))