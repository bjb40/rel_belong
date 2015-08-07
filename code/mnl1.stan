#from https://groups.google.com/forum/#!searchin/stan-users/categorical_logit/stan-users/CRMyv2ylD84/dlVLe6zzrz4J

data {
  int<lower=2> C;   # categories of y
  int<lower=0> N;   # observations
  int<lower=1> K;   # no. explanatory variables
  int<lower=1,upper=C> y[N];    # outcome indicator
  vector[K] xmat[N];
}

parameters {
  matrix[C-1,K] beta_free;
}

transformed parameters {
  matrix[C,K] beta;

  for (k in 1:K)
    for (c in 2:C)
      beta[c,k] <- beta_free[c-1,k];
  
  #enforce restriction that all variables sum to 1/see stan manual
  for (k in 1:K)
    beta[1,k] <- -sum(beta[,k]);

}

model {
  for (c in 2:C)
    for (k in 1:K)
      beta[c,k] ~ normal(0,10);
  for (n in 1:N)
    y[n] ~ categorical_logit(beta * xmat[n]);
}