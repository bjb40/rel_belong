#@@@@@@@@@@@@@@@@@@@
#basic logistic Regression
#dev Stan 2.8
#Bryce Bartlett
#@@@@@@@@@@@@@@@@@@@

data { 
  int<lower=0> N; //observations
  int<lower=1> D; //dimensions of predictors
  int<lower=0,upper=1> y[N]; 
  matrix[N,D] x; //inlcudes column of 1s for intercept 
  } 
  
parameters {
  vector[D] beta; 
  }

model { 
    beta ~ normal(0,10);
    y ~ bernoulli_logit(x*beta);
}
