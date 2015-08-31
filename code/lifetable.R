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

#need to edit to load y (from ml-stan.R)
propy = table(y)/length(y)

ageints=30; n=2; agestart = 25
radix= matrix(propy,nrow=1,ncol=length(propy))
L=l=array(0,c(ageints,5,5)); l[1,,]=diag(5)*as.numeric(propy)


#from Lynch 2007 book
#mpower=function(mat,power)
#{ma<-diag(3);for(i in 1:power){ma=ma%*%mat};return(ma)}

#construct data for simple transition matrix
#int, reltrad2-reltrad5, female, married, white, age
xsim = matrix(0,5,9)
for(i in 1:5){xsim[i,i] = 1}
#age
xsim[,9] = agestart #beginning age

#@@@@@@@@@@@@@@@@@@@@@@@@
#Compute over sample
#@@@@@@@@@@@@@@@@@@@@@@@@

for(m in 1:nrow(post)){
#for(m in 1:10){
  
  #compute over predefined age intervals
  for(a in 0:ageints){
    #update xsim age
    xsim[,9] = agestart + a*n
    
    #print(c(m,agestart + a*n))
    
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
    
    if(a+2 <= ageints){
      #survive based on pmat for lx
      l[a+2,,] = l[a+1,,] %*% pmat
    
      #update Lx for agegroup - currently piecewise exponential hazard
      #see lynch&brown (New approach), and Keyfitz for calcualtions

      L[a+1,,] = (l[a+1,,]+l[a+2,,])/2
    }
    #need to close out correctly...
    
  } #close age cycle
  
  #calculate ex--wrong b/c no mortality - 
  #need to think whether dim is appropriate and add names
  Tx = array(0,c(5,5))
  
  for(d in 1:5){
    Tx[d,] = apply(l[,d,],2,sum)*n
  }
    #each row provides expectancy in each state from starting
    le = apply(Tx,2,function(x) x/diag(l[1,,]))
  
  #write estimates to file (need to manually delete)
  write.table(le,file=paste(outdir,'le.csv',''),append=T, col.names=FALSE,sep=',')
  write.table(l,file=paste(outdir,'l.csv',''),append=T, col.names=FALSE,sep=',')
    
} #close sample cycle
