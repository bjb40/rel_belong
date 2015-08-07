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
  vector[D] xmat[N]; 
  } 
  
#assign reference category for identifiability
transformed data{
  row_vector[D] zeros;
  zeros <- rep_row_vector(0,D);
}

parameters {
  matrix[K-1,D] beta_raw; 
  }

transformed parameters {
  matrix[K,D] beta; 
  beta <- append_row(zeros,beta_raw); 
  }

model { 
  to_vector(beta) ~ normal(0,5); 
  for (n in 1:N) 
    y[n] ~ categorical_logit(beta * xmat[n]);
    }
    
