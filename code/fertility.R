#Bryce Bartlett
#Makes fertility rates
#Dev R ""



#@@@@@
#Preliminaries and load data
#@@@@@


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


#cyrus stata code : 1) evangelical (ref); 2) mainline; 3)other; (4) catholic; (5) none
y=fertpanel$birth
fertpanel$intercept = 1
x=fertpanel[,c('intercept','c_age','c_age2','married','educ',paste0('reltrad',2:5),'rswitch')]
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



#@@@@@@
#save posterior
#@@@@@@
