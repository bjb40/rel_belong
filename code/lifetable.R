#@@@@@@@@@@@@@@@@@@@@@@@@@@
#dev R 3.2.1 "World-Famous Astronaut"
#develping increment-decrement tables as found in Lynch 2005, 2007, 2010
#HOWEVER, using PPD instead of direct probability computation (see Lynch 2007 pp. 311-312)
#see lynch 2007 pp. 312-314 (citations to singer/spilerman and schoen)
#Bryce Bartlett
#@@@@@@@@@@@@@@@@@@@@@@@@@@

#load general info

#load universals configuration file
source("H:/projects/rel_belong/code/config.R",
       echo =T, print.eval = T, keep.source=T)

#@@@@@@@@@@@@@@@@@@@@@@@@
#Load Posterior and calculate transition matrix
#@@@@@@@@@@@@@@@@@@@@@@@@

post = read.csv(paste(outdir,'post.csv',sep=''))

est = as.matrix(post[1,2:46])
b = matrix(0,9,5)
for(dim in 1:9){
  b[dim,] = est[((dim-1)*5+1):(dim*5)]
}

#construct data for simple transition matrix
#int, reltrad2-reltrad5, female, married, white, age
xsim = matrix(0,5,9)
for(i in 1:5){xsim[i,i] = 1}
#age
xsim[,9] = 25
  
#construct odds ratio by exponentiating predicted logits
#across k dimensions

Oddsratio = exp(xsim%*%b)

#convert Oddsratio to predicted probabilities by

#P<-diag(as.vector(exp(x %*% b)%*%as.matrix(rep(1,ncol(beta))))^-1) %*%exp(X %*% beta)

#construct probability matrix
#http://stats.stackexchange.com/questions/11336/predicted-probabilities-from-a-multinomial-regression-model-using-zelig-and-r

pmat<-diag(as.vector(exp(xsim %*% b) %*%
as.matrix(rep(1,ncol(b))))^-1) %*%
exp(xsim %*% b)

#@@@@@@@@@@@@@@@@@@@@@@@@
#Prepare Life table dimensions
#@@@@@@@@@@@@@@@@@@@@@@@@

radix= c(.2,.2,.2,.2,.2)

ageints=9; n=5
l=array(0,c(ageints,5,5)); l[1,,]=diag(5)*radix
bl=matrix(0,ageints,4); tl=matrix(0,ageints,4)

#@@@@@@@@@@@@@@@@@@@@@@@@
#Execute life table calculations
#@@@@@@@@@@@@@@@@@@@@@@@@



