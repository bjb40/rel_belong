#@@@@@@@@@@@@@@@@@@@@@@@@@@
#dev R 3.2.1 "World-Famous Astronaut"
#Requires Rstan (dev 2.7.0; same version as Stan) 
#develping increment-decrement tables as found in Lynch 2005, 2007, 2010
#using Bayesian Statistics
#Bryce Bartlett
#@@@@@@@@@@@@@@@@@@@@@@@@@@

#manually reun code bits from mnl.R -- needs updated


#@@@@@@@@@@@@@
#prep stan input
#@@@@@@@@@@@@@

C=length(unique(y))
N=nrow(dat)
K=2

x = as.matrix(dat$female)
#add intercept
xmat = cbind(rep(1,nrow(x)),x)

y = as.integer(dat$reltrad)

#@@@@@@@@@@@@@
#call stan model
#@@@@@@@@@@@@@

library('rstan')

#detect cores to activate parallel procesing
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

fit <- stan("mnl1.stan", data=c("K", "C", "N", "y", "xmat"),
            chains=4, iter=200, seed=1234);

#@@@@@@@@@@@@@
#posterior analysis
#@@@@@@@@@@@@@

print(summary(fit))

