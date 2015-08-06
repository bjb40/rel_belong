#@@@@@@@@@@@@@@@@@@@@@@@@@@
#dev R 3.2.1 "World-Famous Astronaut"
#develping mn probit extension for
#increment-decrement tables as found in Lynch 2005, 2007, 2010
#implimenting Bayesian probit as found in McCulloch & Rossi 1994
#Gibbs sampler
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
  
#vectorize data for easier reference and calculating
y = as.matrix(dat$reltrad)
ydim = length(unique(y))

#expand to dummy matrix
ydum = matrix(0,nrow(y),ydim)
for(ob in 1:nrow(ydum)){ydum[ob,y[ob]]=1}

x = as.matrix(dat$female)
#add intercept
x = cbind(rep(1,nrow(x)),x)

rm(dat);

#@@@@
#Begin Gibbs Sampler
#@@@@

#Set starting values

iterations = 200
k = ydim-1
beta = matrix(0,nrow(x),k*ncol(x))
u = matrix(0,nrow(x),k) #single draw; will write to disk all acceptances
sigma = diag(ydim)+1 
i.k = diag(k)

#probability matrix for boundary *cuts* in the TMVN
for(iter in 2:iterations){
  
  #1 draw beta|sigma,u,y,x (lynch p. 297-280); improper...?
  vb = solve(solve(i.k)%x%(t(x)%*%x))
  mn = vb%*%(as.vector(t(x)%*%u%*%t(solve(i.k))))
  beta=mn+t(rnorm((ncol(x)*k),0,1)%*%chol(vb))
  
  #2 draw sigma|beta,u,y,x
  #sigma is fixed for now until #3 is working
  
  #3 for i=1...n and c=1...C draw u_ic|u_ic-1,beta,Sigma,y,x
  #mcculloch & Rossi, p. 212
  
  
}




