#@@@@@@@@@@@@@@@@@@@
#basic logistic Regression
#dev Stan 2.8
#Bryce Bartlett
#@@@@@@@@@@@@@@@@@@@

data { 
  int<lower=0> N; //observations
  int<lower=1> D; //dimensions of predictors
  int<lower=0,upper=1> y[N]; 
  matrix[N,D] x; //x should include column of 1s for intercept 
  } 
  
parameters {
  vector[D] beta; 
  }

model { 
    beta ~ normal(0,10);
    y ~ bernoulli_logit(x*beta);
}

generated quantities {
  //for WAIC
  vector[N] loglik; // log pointwise predictive density
  //for DIC
  real dev;
  vector[N] yhat;
  
  yhat <- x*beta;
  dev <- 0;  
  for(n in 1:N){
    loglik[n] <- bernoulli_logit_log(y[n],yhat[n]);
    dev <- dev-(2*bernoulli_logit_log(y[n],yhat[n]));
  }

}
