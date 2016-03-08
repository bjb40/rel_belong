#@@@@@@@@@@@@@@@@@@@
#basic logistic Regression
#dev Stan 2.8
#Bryce Bartlett
#@@@@@@@@@@@@@@@@@@@

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

#not tranforming per se--just constraining 
#the first column to be 0
#will throw a warning about a jacobian
#but since there is no transformaiton, no adjustment
#is necessary

transformed parameters {
  matrix[K,D] beta; 
  beta <- append_row(zeros,beta_raw); 
  }

model { 
  to_vector(beta) ~ normal(0,10); 
  for (n in 1:N) 
    y[n] ~ categorical_logit(beta * xmat[n]);
    }
    
