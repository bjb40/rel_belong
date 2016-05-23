#dev R 3.2.3; Rstan 2.8.2; RStudio 0.99.0467; Stan 2.8.0
#General functions for (1) presentation and (2) use with Stan/Rstan
#Bryce Bartlett
#2/2016

#@@@@@@@@@@@@@@@@@@@@@
#Presentation Functions
#@@@@@@@@@@@@@@@@@@@@@

rnd = function(db,rd){
  # rounds input to preserve leading zeros
  #
  # Args:
  #   db: an object with numeric types
  #   rd: length to round (including leading zeros, default=3)
  #
  # Returns:
  #   an object of of db translated to characters with leading zeros
  
  if(missing(rd)){rd=3}
  rdl=paste0('%.',rd,'f')
  return(sprintf(rdl,round(db,digits=rd)))
}

sig = function(pv){
  # returns stars based on pvalue
  #
  # Args:
  #   pv: a p-value
  #
  # Returns:
  #   a string with stars for values * <.05 **<.01 *** < .001
  s='   '
  if(length(pv)>0){
    if(pv<.001){s='***'} else if(pv<.01){s='** '} else if (pv<.05){s='*  '} else if (pv<.1){s='+  '}
  }
  return(s)
  
}

#@@@@@@@@@@@@@@@@@@@
#Bayesian Analysis fucntions 
#@@@@@@@@@@@@@@@@@@@

#helper function for tables
eff = function(s,c,usemean){
  # calculates mean effect from posterior sample and 95%CI
  #
  # Args:
  #   s: a series of posterior samples
  #   c: a number betwen 0 and 1 for confidence; .95 is default
  #   usemean: TRUE or FALSE statement to use mean; default is median
  #
  # Returns:
  #   a named vector including mean, lower ci, upper ci
  
  if(missing(usemean)){usemean=FALSE}
  
  if(usemean == TRUE){
    e = mean(s)
    names(e)='mean'
  }
  else{
    e = median(s)
    names(e) = 'median'
  }
  
  
  #calculate probs
  if(missing(c)){c=.95}
  l=(1-c)/2
  u=1-((1-c)/2)
  
  interval = quantile(s,prob=c(l,u))
  return(c(e,interval))
}


#helper function for printing
printeff = function(s,c){
  #returns string of the form "mean posterior [lower post,upper post]"
  #Input: s = a series of posterior samples,c = confidence pval (0-1)
  #see function (eff) for more info
  #output is string
  e = rnd(eff(s,c))
  return(cat(e[1],'<br>[',paste(e[2],e[3],sep=','),']',sep=''))
}



#@@@@@@@@@@@@@@@@@@@
#Bayesian Analysis fucntions for use with STan
#@@@@@@@@@@@@@@@@@@@



#function to calculate WAIC
#from gelman example in sta users list

# Little function to calculate posterior variances from simulation
colVars <- function (a){
  diff <- a - matrix (colMeans(a), nrow(a), ncol(a), byrow=TRUE)
  vars <- colMeans (diff^2)*nrow(a)/(nrow(a)-1)
  return (vars)
}

waic <- function (stanfit){
  loglik <- extract (stanfit, "loglik")$loglik
  lppd <- sum (log (colMeans(exp(loglik))))
  p_waic_1 <- 2*sum (log(colMeans(exp(loglik))) - colMeans(loglik))
  p_waic_2 <- sum (colVars(loglik))
  waic_2 <- -2*lppd + 2*p_waic_2
  return (list (waic=waic_2, p_waic=p_waic_2, lppd=lppd, p_waic_1=p_waic_1))
}

#vehtari and Gelman + stan user group
#note that there are 2 different scales here -- should also be 2 scales for DIC

waic2 <- function(stanfit){
  colVars <- function(M){
    vars <- M[1, ]
    for (n in seq_along(vars)) vars[n] <- var(M[, n])
    return(vars)
  }
  log_lik <- extract (stanfit, "loglik")$loglik
  dim(log_lik) <- if (length(dim(log_lik)) == 1) c(length(log_lik), 1) else
    c(dim(log_lik)[1], prod(dim(log_lik)[2:length(dim(log_lik))]))
  S <- nrow(log_lik)
  n <- ncol(log_lik)
  lpd <- log(colMeans(exp(log_lik)))
  p_waic <- colVars(log_lik)
  elpd_waic <- lpd - p_waic
  waic <- -2 * elpd_waic
  loo_weights_raw <- 1 / exp(log_lik - max(log_lik))
  loo_weights_normalized <- loo_weights_raw/
    matrix(colMeans(loo_weights_raw), nrow=S, ncol=n, byrow=TRUE)
  loo_weights_regularized <- pmin(loo_weights_normalized, sqrt(S))
  elpd_loo <- log(colMeans(exp(log_lik) * loo_weights_regularized) /
                    colMeans(loo_weights_regularized))
  p_loo <- lpd - elpd_loo
  pointwise <- cbind(waic, lpd, p_waic, elpd_waic, p_loo, elpd_loo)
  total <- colSums(pointwise)
  se <- sqrt(n * colVars(pointwise))
  return(list(waic=total["waic"], elpd_waic=total["elpd_waic"],
              p_waic=total["p_waic"], elpd_loo=total["elpd_loo"], p_loo=total["p_loo"],
              pointwise=pointwise, total=total, se=se))
}


#function to calculate DIC--not sure why this works; need to investigate
#to make sure params are okay
dic = function(stanfit){
  dev = extract(stanfit,'dev')$dev
  ldev = mean(dev)
  pdic = .5*var(dev)
  dic = ldev + pdic
  elpd_dic = dic/-2
  
  return(list (dic=dic, elpd_dic=elpd_dic,logdev=ldev, pdic=pdic))
}


