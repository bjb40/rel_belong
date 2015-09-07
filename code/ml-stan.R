#@@@@@@@@@@@@@@@@@@@@@@@@@@
#dev R 3.2.1 "World-Famous Astronaut"
#Requires Rstan (dev 2.7.0; same version as Stan) 
#develping increment-decrement tables as found in Lynch 2005, 2007, 2010
#using Bayesian Statistics
#Bryce Bartlett
#@@@@@@@@@@@@@@@@@@@@@@@@@@

st1 = proc.time()[3]

#load universals configuration file
source("H:/projects/rel_belong/code/config.R",
       echo =T, print.eval = T, keep.source=T)


#@@@@@@@@@@@@@
#prep stan input
#@@@@@@@@@@@@@

#read data previously cleaned using ./prep-data.r
dat = read.csv(paste(outdir,'private~/subpanel.csv',sep=''))

#@@@@@@@@@@@@@@@@
#Need to move to prep data
#@@@@@@@@@@@@@@@@

#mnage = mean(dat$age)
#dat$age = dat$age - mnage
#dat$age2 = dat$age*dat$age

y = as.integer(dat$nstate)
x = as.matrix(subset(dat,
                     select=c(reltrad2,reltrad3,reltrad4,reltrad5,
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
#options(mc.cores = parallel::detectCores())
options(mc.cores = 3) #leave one core free for work

fit <- stan("mnl.stan", data=c("K", "D", "N", "y", "xmat"),
            #algorithm='HMC',
            chains=3,iter=1200, seed=6590,verbose=T,
            sample_file = paste0(outdir,'diagnostic~/post-samp.txt'),
            diagnostic_file = paste0(outdir,'diagnostic~/stan-diagnostic.txt'),
            open_progress=T);


#print time taken
print(Sys.time() - st)

#@@@@@@@@@@@@@
#posterior analysis
#@@@@@@@@@@@@@

sink(paste(outdir,'post_summary.txt',sep=''))
print(Sys.Date(),quote="F")

cat('\n\n@@@@@@@@@@@@@@@@@@@\n POSTERIOR SUMMARY ')
cat('\n@@@@@@@@@@@@@@@@@@@@@\n\n')

print(summary(fit))

#export posterior sample

cat('NOTE:\nbeta[k,d] are relevant estimates, where\n
    k = NEXT wave odds of (1) evangelical; (2) mainline; (3) other; (4) catholic; (5) none; (6) death 
    d = intercept,reltrad2,reltrad3,reltrad4,reltrad5,female,married,white,age,age2')

write.csv(extract(fit,pars='beta'),paste(outdir,'post.csv',sep=''))

cat('\n\n@@@@@@@@@@@@@@@@@@@\n MISC INFO ')
cat('\n@@@@@@@@@@@@@@@@@@@@@\n\n')


cat('\n\n\nTime Taken (munutes)\n')
print((proc.time()[3] - st1)/60)

cat('\n\n\nSource:ml-stan.R, model: mnl.stan')

sink()

for(c in 2:6){
  png(filename=paste0(outdir,'diagnostic~/trace',c,'.png'))
  traceplot(fit,pars=paste0("beta[",c,",",c(1:9),"]"),nrow=5,ncol=2)
  dev.off()
}

