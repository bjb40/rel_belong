---
author: Bryce Bartlett
date: 9/6/2015
title: 'poor bayesian mixing using stan'
tags: bayes,mixing,hamiltonian monte carlo,metropolis hastings
---

#Overview

Working model for paramaters; fast estimation in stata, but slow mixing in Stan.

#Summary

Gelman has a good discussion in his book, HMC used by Stan is a 'particle' with weight and distance jumping along a slope. NUTS is a more localized adjustment for this (more advanced). It is supposed to work better, as in this case, when theere are clear correlations between the parameters. Should have 65% acceptance rate with HMC (as opposed to 25% with straight MH). Basic advice is to extend sample. Initial try with this makes it somewhat impractical with respect to time (don't want to tie up or push my computer that hard). Alternatives are to reparameterize the model.

The easiest reparameterization may be a rewieghting (like I did in the HLM class related to piecewise exponential logits).

Current model:

~~~~~{.numberLines .R}
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
    
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

250 draws on three chains provides nearly no convergence (there are 50 free parameters, though and 10 constrained to 0). Effective samples are 1 or 2 with autocorrelations. There appears to be convergence on some of the current statuses, but they fall off convergence when the other current statuses begin to move (from trace plots). Original diagnostics include:

~~~~{.numberLines .R}
> print(get_adaptation_info(fit))
[[1]]
[1] "# Adaptation terminated\n# Step size = 8.23676e-005\n# Diagonal elements of inverse mass matrix:\n# 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1\n"

[[2]]
[1] "# Adaptation terminated\n# Step size = 0.000135158\n# Diagonal elements of inverse mass matrix:\n# 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1\n"

[[3]]
[1] "# Adaptation terminated\n# Step size = 9.68041e-005\n# Diagonal elements of inverse mass matrix:\n# 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1\n"

> aparms = get_sampler_params(fit)
> for(col in 1:5){
+   for(c in 1:3){
+     print(paste(colnames(aparms[[c]])[col],mean(aparms[[c]][,col])))
+   }
+ }
[1] "accept_stat__ 0.814312176489083"
[1] "accept_stat__ 0.509299159863938"
[1] "accept_stat__ 0.763869889129774"
[1] "stepsize__ 0.0363427550734833"
[1] "stepsize__ 0.0684484392857549"
[1] "stepsize__ 0.0684116085345894"
[1] "treedepth__ 4.364"
[1] "treedepth__ 3.572"
[1] "treedepth__ 3.812"
[1] "n_leapfrog__ 68.532"
[1] "n_leapfrog__ 20.488"
[1] "n_leapfrog__ 36.264"
[1] "n_divergent__ 0.088"
[1] "n_divergent__ 0.244"
[1] "n_divergent__ 0.06"
~~~~~~~~~~~~~~~~~

Took about 13 minutes.

Things I tried (with results):

- Mean center age (no noticeable effect; may be slower; did not completley identify)
- Double normal prior on betas. No noticeable effect on time (although there appears to be a large variance in time for draws). No appreciable difference. Random seed produces the same thing.
- Reduce to 3 cores (i have 2 cores, but 4 logical processors) - no appreciable time difference, but can use computer for other things with much better results; may slow down results, however.
- Update random seed and double iters from 250 to 500; I turned on diagnostics so I can look at it. (Did not optomize cores correctly. Chain 2 took 3 minutes... Chain 1 took nearly 4 hours... No convergence, and effective N did not budge. Chain 2 (the fastest one) was stuck and worthless. The other 2 appear to have incomplete (but approaching) convergence. Values of these chains also appear to approach freqentest measures. Diagnostics:

~~~~{.numberLines .R}
> print(get_adaptation_info(fit))
[[1]]
[1] "# Adaptation terminated\n# Step size = 0.00586487\n# Diagonal elements of inverse mass matrix:\n# 5.0151e-005, 4.87564e-005, 4.8791e-005, 5.67722e-005, 5.11859e-005, 4.94068e-005, 5.06546e-005, 4.87618e-005, 5.26893e-005, 5.02865e-005, 5.03635e-005, 4.84297e-005, 4.82693e-005, 5.02426e-005, 4.82684e-005, 4.98413e-005, 5.18886e-005, 6.32725e-005, 4.93024e-005, 4.87972e-005, 4.87322e-005, 4.9e-005, 4.90538e-005, 4.84428e-005, 4.82675e-005, 4.95173e-005, 4.8502e-005, 5.0139e-005, 5.18425e-005, 5.29737e-005, 5.00068e-005, 4.92234e-005, 4.79057e-005, 5.0485e-005, 6.0286e-005, 4.86964e-005, 5.06876e-005, 5.0187e-005, 5.06689e-005, 5.23152e-005, 0.00888782, 0.000219669, 0.0144694, 0.0449211, 0.000579653, 5.81356e-005, 4.78022e-005, 6.90665e-005, 0.000142453, 0.000318221\n"

[[2]]
[1] "# Adaptation terminated\n# Step size = 0.00483079\n# Diagonal elements of inverse mass matrix:\n# 4.95345e-005, 4.96136e-005, 5.21142e-005, 5.61339e-005, 7.95878e-005, 6.01736e-005, 5.37608e-005, 4.86758e-005, 5.12942e-005, 5.37124e-005, 5.34154e-005, 4.87331e-005, 5.89848e-005, 7.4312e-005, 5.11734e-005, 4.88611e-005, 5.308e-005, 9.27193e-005, 8.70388e-005, 5.39162e-005, 5.03729e-005, 5.43273e-005, 5.22904e-005, 8.6096e-005, 4.83338e-005, 7.21933e-005, 5.67702e-005, 5.0799e-005, 5.5817e-005, 7.79233e-005, 5.02699e-005, 4.84216e-005, 4.90338e-005, 0.000112622, 5.59502e-005, 4.94094e-005, 4.94324e-005, 4.80894e-005, 7.93052e-005, 6.73019e-005, 0.0320609, 0.00301649, 0.00600041, 0.0607133, 0.00219205, 6.80383e-005, 5.4774e-005, 4.96105e-005, 0.000194103, 0.00297262\n"

[[3]]
[1] "# Adaptation terminated\n# Step size = 0.00133535\n# Diagonal elements of inverse mass matrix:\n# 0.00888244, 0.0163165, 0.00544326, 0.000140577, 0.000647989, 0.0025833, 9.31061e-005, 7.1813e-005, 0.00064431, 0.000116595, 0.0014593, 0.00155558, 0.000103488, 0.00030005, 5.56494e-005, 0.00273913, 0.00177336, 0.0234458, 0.000561221, 0.000158418, 0.000142523, 0.00239468, 0.000340325, 0.00405055, 9.29642e-005, 0.00506858, 0.00736564, 0.00313437, 8.89699e-005, 0.000331187, 0.00583827, 0.000279763, 0.00253342, 0.00817413, 0.000118855, 0.00397556, 0.0108098, 0.00497975, 0.000524381, 0.000155997, 0.0840434, 0.013334, 0.00485649, 0.0845291, 0.0437997, 0.00011602, 5.14715e-005, 5.10616e-005, 0.000119479, 0.00720346\n"

> aparms = get_sampler_params(fit)
> for(col in 1:5){
+   for(c in 1:3){
+     print(paste(colnames(aparms[[c]])[col],mean(aparms[[c]][,col])))
+   }
+ }
[1] "accept_stat__ 0.842632642703097"
[1] "accept_stat__ 0.471461528425954"
[1] "accept_stat__ 0.851714759930862"
[1] "stepsize__ 0.0399461222714926"
[1] "stepsize__ 0.0381567666712367"
[1] "stepsize__ 0.0145624289200988"
[1] "treedepth__ 6.976"
[1] "treedepth__ 3.652"
[1] "treedepth__ 8.028"
[1] "n_leapfrog__ 1001.172"
[1] "n_leapfrog__ 16.244"
[1] "n_leapfrog__ 1199.61"
[1] "n_divergent__ 0.068"
[1] "n_divergent__ 0.384"
[1] "n_divergent__ 0.094"
~~~~~~~~~~~~~~~~~~~~~~~~~~

- Try 250 draws with HMC algorithm (not NUTS) -- stopped after 15 minutes; only 10 draws; no good!
