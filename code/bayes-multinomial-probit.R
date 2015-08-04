#dev R 3.2.1 "World-Famous Astronaut"
#develping mn probit extension as found in Lynch 2005, 2007, 2010
#Bryce Bartlett

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

rm(dat);

#@@@@
#Begin Gibbs Sampler
#@@@@

#Set starting values

iter = 200

g_base = matrix(0,iter,1)
b_base = matrix(0,iter,ncol(x))
g = matrix(0,iter,ydim-1)
b = matrix(0,iter,(ncol(x)*ydim-1))
u = matrix(0,nrow(x),ydim)
sigma = diag(ydim)+1 #equivalent to stata mprobit per specification

#probability matrix for boundary *cuts* in the TMVN
for(i in 2:iter){
  
  #simulate z (draw latent data from TMVN)
  bb=matrix(b,ncol(x),ydim)
  m=x%*%bb
  
  for(j in ydim:2){
    #p.285 gibbs sampler--identify conditional univariate distribution
    mm = m[j-1] + s[(j-1),(j:ydim)]%*%solve(s[j:ydim,j:ydim])%*%t(z[,j:ydim]-m[,j:ydim])
    ss=s[(j-1),(j:ydim)]%*%solve(s[j:ydim,j:ydim])%*%s[(j:ydim),(j-1)]
    
    #draw from conditional univariate distribution
    z[,j-1]=
  }
  #simulate tau (thresholds)
  
  #simulate b
  
  #simulate sigma (cov matrix)
  
  
}




