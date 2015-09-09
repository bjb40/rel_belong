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

#read data previously cleaned using ./prep-data.r
dat = read.csv(paste(outdir,'private~/subpanel.csv',sep=''))

#@@@@@@@@@@@@@@@@@@@@@@@@
#Load Posterior sample
#@@@@@@@@@@@@@@@@@@@@@@@@

post = read.csv(paste(outdir,'post.csv',sep=''))

#@@@@@@@@@@@@@@@@@@@@@@@@
#Initialize key variables & functions
#@@@@@@@@@@@@@@@@@@@@@@@@

#radix from observed proportions
startstate = c(table(dat$reltrad)/nrow(dat),0)

ageints=33; n=2; agestart = 18
radix= matrix(startstate,nrow=1,ncol=length(startstate))*100000
L=l=array(0,c(ageints,6,6)); l[1,,] = diag(6)*as.numeric(radix)

#estimate rates from observations in final period
age_last = ageints*2+agestart
Mx_last = prop.table(
            table(dat[dat$age>=age_last,'reltrad'],
                  dat[dat$age>=age_last,'reltrad']
                  )) #insufficient informatoion at 84 - will assume no tr. and 2006 life table rate for Lx

rm(dat) #no longer needed


#from Lynch 2007 book
#mpower=function(mat,power)
#{ma<-diag(3);for(i in 1:power){ma=ma%*%mat};return(ma)}

#construct data for simple transition matrix
#int, reltrad2-reltrad5, female, married, white, age
xsim = matrix(0,5,9)

#add intercept
xsim[,1] = 1

#add white effect
xsim[,8] = 1

#iterate over each starting state
for(i in 2:5){xsim[i,i] = 1}

#insput starting age
xsim[,9] = agestart 

#@@@@@@@@@@@@@@@@@@@@@@@@
#Compute over sample
#@@@@@@@@@@@@@@@@@@@@@@@@

#initialize tables for saving output
write.table(t(as.matrix(c('iter','ageint',paste0('phi',1:36)))),file=paste0(outdir,'phi.csv'),
            append=F, col.names=F,row.names=F,sep=',')

write.table(t(as.matrix(c('iter','ageint',paste0('le',1:25)))),file=paste0(outdir,'le.csv'),
            append=F, col.names=F,row.names=F,sep=',')


for(m in 1:nrow(post)){
#for(m in 1:10){
  
  #compute over predefined age intervals
  for(a in 0:ageints){
    #update xsim age
    xsim[,9] = agestart + a*n
    
    #print(c(m,agestart + a*n))
    
    #compute predicted odds from parameter estimates
    est = as.matrix(post[m,2:ncol(post)])
    b = matrix(0,9,6)
    for(dim in 1:9){
      b[dim,] = est[((dim-1)*6+1):(dim*6)]
    }
    
    #construct odds ratio by exponentiating predicted logits
    #across k dimensions
    Oddsratio = exp(xsim%*%b)
    
    #convert Oddsratio to predicted probabilities by
    phi = t(apply(Oddsratio,1,function(x) x/sum(x)))
    
    
    #add absorbing state probabilities
    phi = rbind(phi,c(rep(0,5),1))
    
    #convert tp to m via Sylvester's formula
    #need to extend to 5 dimensions - makes piecewise constant hazard by logging
    #ensures a true stationary markov process
#    mmat=0
#    lam2=(phi[2,2]+phi[1,1]+sqrt((phi[2,2]+phi[1,1])^2-4*(phi[1,1]*phi[2,2]-phi[1,2]*phi[2,1])))/2
#    lam3=(phi[2,2]+phi[1,1]-sqrt((phi[2,2]+phi[1,1])^2-4*(phi[1,1]*phi[2,2]-phi[1,2]*phi[2,1])))/2
#    mmat= (log(lam2)/((lam2-1)*(lam2-lam3)))*
#      ((phi-diag(5))%*%(phi-lam3*diag(5)))+(log(lam3)/((lam3-1)*(lam3-lam2)))*
#      ((phi-diag(5))%*%(phi-lam2*diag(5)))
  
#    mmat=-mmat
    
    if(a+2 <= ageints){
      #survive based on phi for lx
      l[a+2,,] =  diag(rowSums(l[a+1,,])) %*% phi
    
      #update Lx for agegroup - currently piecewise exponential hazard (sylvester's formula changes)
      #see lynch&brown (New approach), and Keyfitz for calcualtions

      L[a+1,,] = (l[a+1,,]+l[a+2,,])*n/2
    }
    
    #write phi estimates
    write.table(t(as.matrix(c(m,a+1,as.vector(phi)))),file=paste0(outdir,'phi.csv'),
                append=T, col.names=FALSE,row.names=F,sep=',')

  } #close age cycle

  #close out multistate life table
  #apply by dividing by inverse of rate (scott 2010, p. 1068, but he says this is expectancy)
  #see schoen 75 appendix
  
  #everybody dies
  #l[ageints,,] = l[ageints-1,,] %*% matrix(c(rep(0,30), rep(1,6)),6,6)
    
  #assume no state changes, and rates of death across all categories equal to 2006 life table 
  #0.132531000 per 100000
  L[ageints,1:5,1:5] = l[ageints,1:5,1:5] %*% solve(diag(0.132531,5))
  
  #note scott discusses l(x) being diagonal, but l(x+1) as not (same with L(x))
  le = array(0,c(ageints,5,5)) 
  
  #see ken p. 307: premultiply
  for(a in 1:(ageints-1)){
    le[a,,] = solve(diag(colSums(l[a,1:5,1:5]))) %*% colSums(L[a:ageints,1:5,1:5])
  }
    le[ageints,,] = L[ageints,1:5,1:5] %*% solve(diag(colSums(l[a,1:5,1:5])))

  #write life expectancy estimates to file
  write.table(cbind(m,1:ageints,data.frame(le)),file=paste0(outdir,'le.csv',''),
              append=T, col.names=FALSE,sep=',',row.names=FALSE)
  #write.table(l,file=paste(outdir,'l.csv',''),append=T, col.names=FALSE,sep=',')
  #print(rowSums(le[1,,]))
} #close sample cycle
