#from https://groups.google.com/forum/#!topic/stan-users/0qdtaoAl1us

library(MASS);

K <- 8;
D <- 4;
N <- 500;

# stick breaking construction to generate a random correlation matrix
L_Omega <- matrix(0,D,D);
L_Omega[1,1] <- 1;
for (i in 2:D) {
  bound <- 1;
  for (j in 1:(i-1)) {
    L_Omega[i,j] <- runif(1, -sqrt(bound), sqrt(bound));
    bound <- bound - L_Omega[i,j]^2;
  }
  L_Omega[i,i] <- sqrt(bound);
}

Omega <- L_Omega %*% t(L_Omega);

x <- matrix(rnorm(N * K, 0, 1), N, K);

beta <- matrix(rnorm(D * K, 0, 1), D, K);

z <- matrix(NA, N, D);
for (n in 1:N) {
  z[n,] <- mvrnorm(1, x[n,] %*% t(beta), Omega);
}

#wrong - not z score --- need the marginal integral (if integral is greater????)
y <- matrix(0, N, D);
for (n in 1:N) {
  for (d in 1:D) {
    if(max(z[n,]) < 0){y[n,d] = 0}
    else if(max(z[n,]) == z[n,d]){y[n,d] = 1} else{y[n,d]=0}
  }
}

# stan is not quite an option on the integration because it doesn't have a gibbs sampler
# the gibbs is just as easy to implement in R; will spend my time doing that
#library(rstan);
#fit <- stan("probit-multi.stan", data=c("K", "D", "N", "y", "x"))
