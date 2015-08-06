#@@@@@@@@@@@@@@@@@@@
#basic multinomial logistic Regression
#dev Stan 2.7.0
#See Stan Manual, Section 5.5, 'multi-logit regression'
#Bryce Bartlett
#@@@@@@@@@@@@@@@@@@@

#need to constrain so that the options sum to 1 and double check priors, etc.


data { 
  int<lower=2> K; //categories in y
  int<lower=0> N; //observations
  int<lower=1> D; //dimensions of predictors
  int<lower=1,upper=K> y[N]; 
  vector[D] x[N]; 
  } 
  
#assign reference category for identifiability
transformed data{
  vector[D] zeros;
  zeros <- rep_vector(0,D);
}

parameters {
  matrix[K-1,D] beta_raw; 
  }

transformed parameters {
  matrix[K, D] beta; 
  beta <- append_col(beta_raw, zeros); 
  }

model { 
  for (k in 1:K) 
    beta[k] ~ normal(0,5); 
  for (n in 1:N) 
    y[n] ~ categorical_logit(beta * x[n]);
    }
    
