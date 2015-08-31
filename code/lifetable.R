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
#Load Posterior sample
#@@@@@@@@@@@@@@@@@@@@@@@@

post = read.csv(paste(outdir,'post.csv',sep=''))

#@@@@@@@@@@@@@@@@@@@@@@@@
#Initialize key variables & functions
#@@@@@@@@@@@@@@@@@@@@@@@@

ageints=30; n=2; agestart = 25
l=array(0,c(ageints,5,5)); l[1,,]=diag(5)*radix
bl=matrix(0,ageints,4); tl=matrix(0,ageints,4)

#need to edit to load y (from ml-stan.R)
propy = table(y)/length(y)

radix= matrix(propy,nrow=1,ncol=length(propy))
lx = rbind(radix,matrix(0,ageints,ncol(radix)))
ex = Lx = matrix(0,nrow(lx),ncol(lx))

mpower=function(mat,power)
{ma<-diag(3);for(i in 1:power){ma=ma%*%mat};return(ma)}

#construct data for simple transition matrix
#int, reltrad2-reltrad5, female, married, white, age
xsim = matrix(0,5,9)
for(i in 1:5){xsim[i,i] = 1}
#age
xsim[,9] = agestart #beginning age

#@@@@@@@@@@@@@@@@@@@@@@@@
#Compute over sample
#@@@@@@@@@@@@@@@@@@@@@@@@

#for(m in 1:nrow(post)){
for(m in 1:10){
  
  #compute over predefined age intervals
  for(a in 0:ageints){
    #update xsim age
    xsim[,9] = agestart + a*n
    
    print(c(m,agestart + a*n))
    
    #compute predicted odds from parameter estimates
    est = as.matrix(post[m,2:46])
    b = matrix(0,9,5)
    for(dim in 1:9){
      b[dim,] = est[((dim-1)*5+1):(dim*5)]
    }
    
    #construct odds ratio by exponentiating predicted logits
    #across k dimensions
    Oddsratio = exp(xsim%*%b)
    
    #convert Oddsratio to predicted probabilities by
    #http://stats.stackexchange.com/questions/11336/predicted-probabilities-from-a-multinomial-regression-model-using-zelig-and-r
    
    pmat <-diag(as.vector(Oddsratio %*%
      as.matrix(rep(1,ncol(b))))^-1) %*%
      Oddsratio
    
    #convert tp to m via Sylvester's formula
    #need to extend to 5 dimensions - makes piecewise constant hazard by logging
    #ensures a true stationary markov process
#    mmat=0
#    lam2=(pmat[2,2]+pmat[1,1]+sqrt((pmat[2,2]+pmat[1,1])^2-4*(pmat[1,1]*pmat[2,2]-pmat[1,2]*pmat[2,1])))/2
#    lam3=(pmat[2,2]+pmat[1,1]-sqrt((pmat[2,2]+pmat[1,1])^2-4*(pmat[1,1]*pmat[2,2]-pmat[1,2]*pmat[2,1])))/2
#    mmat= (log(lam2)/((lam2-1)*(lam2-lam3)))*
#      ((pmat-diag(5))%*%(pmat-lam3*diag(5)))+(log(lam3)/((lam3-1)*(lam3-lam2)))*
#      ((pmat-diag(5))%*%(pmat-lam2*diag(5)))
  
#    mmat=-mmat
    
    #survive based on pmat for lx
    lx[a+2,] = lx[a+1,] %*% pmat
    
    #update Lx for agegroup - currently piecewise exponential hazard
    #see lynch&brown (New approach), and Keyfitz for calcualtions
    Lx[a+1,] = (lx[a+1,]+lx[a+2,])/2
    
    #need to close out correctly...
    
  } #close age cycle
  
  #calculate ex--this seems wrong/maybe b/c no mortality
  #need explicit decrements for detail (check Land)
  Tx = apply(lx,2,sum)
  le = Tx/lx[1,] #divide by sum of lx for pop...
  
  #write estimates to file
  
} #close sample cycle
