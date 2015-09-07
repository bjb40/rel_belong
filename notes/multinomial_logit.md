---
author: Bryce Bartlett
date: 8/10/2015
title: Technical Memo for Estimates Using Multinomial Logistic (Softmax) Regression
csl: ../citations/asa-mod.csl
bibliography: ../citations/rel_belong.bib
---

#Overview

This memo is intended to outline the steps, procedures, equations, and code needed to estimate the life table supporting the religious belonging. It is written so that excerpts can be lifted and placed into a methods section and/or attached (with some revision) as a technical appendix.

```add the question/goal```

#Summary

Our analytic approach is based on Bayesian life table methods developed by Lynch and Brown [-@lynch_new_2005], with detailed descriptions and code available in the *Introduction to Applied Bayesian Statistics and Estimation for Social Scientists* [@lynch_introduction_2007] (cross-sectional analysis requires a similar but slightly different set of analyses based on the Sullivan method [@lynch_obtaining_2010]). The method employs a four step approach: (1) build a model to predict transition probabilities; (2) use Bayesian Markov Chain Monte Carlo (MCMC) methods to estimate the model, and draw $M$ samples from the posterior; (3) use the posterior samples to estimate $M$ life tables based upon predicted transition rates; and (4) compare and contrast life table calcualtions  [@lynch_new_2005]. Each step is discussed in detail below.

##Data

```needs some revision --- need to carry through in analytic discussion below (and fill out things like death) ```

The initial working model is described below. I estimate the log odds of the following outcomes for each individual at time $t$ relative to the reference of *evangelical*: *mainline*, *other*, *catholic*, and *none*. The key explanatory variable is a dummy variable series of the same $k$ outcomes, but at $t-1$. Other covariates are measured at time $t$ and include $age$ and $age^2$,*education*, *female* (dummy), *race* (dummy), *married* (dummy), and number of *kids*.

##Model for Transition Probabilities

The key for life table construction is the accurate estimates of transition probabilities. The key feature is to model the probability of transitioning from one state to another conditional on the individual's current state and some set of predictor variables. The necessary input for lifetable calculations envisioned in step 3 is a matrix of transition probabilities, $T$. In this case, the matrix is a $K \times K$ matrix covering for all possible states describing the individual's self-described religious tradition, or death (each a unique $k$ state). The columns of $\Phi$ represent the state at time $t$, and the rows of $\Phi$ represent the probability of transition to another state at time $t+1$. More formally, the properties of $\Phi$ are as follows:

$$
\Phi =
\begin{bmatrix}
  \phi_{1,1}&\phi_{1,2}&\cdots&\phi_{1,K} \\
  \phi_{2,1}&\phi_{2,2}&\cdots&\phi_{2,K} \\
  \vdots & \vdots & \ddots & \vdots \\
  \phi_{K,1} & \phi_{K,2} & \cdots & \phi_{K,K}
\end{bmatrix}
$$

The form of $\Phi$ is limited in two respects: (1) the probabilities ($\phi$) in each row, $r$  must sum to 1  ($\sum_{k=1}^K \phi_{r,k} = 1; \, where \, r \in K$). This means that that each individual must begin in some one state at time $t$, and end in some state at $t+1$. (2) For absorbing states, like death, the probability of remaining in the state is 1, with all other cells 0. This indicates no possiblity of transitioning out of absorbing states (*e.g.*, from dead to alive).

Estimating $\Phi$ requires a model which can estimate probabilities across numerous states. Common multinomial models, such as the probit and logit, are well-suited to estimating these transitions as predicted probabilities based upon some covariate structure. Applying such a model in panel data allows for direct estimation of transition probabilities (like a hazard model), and smooths transition probabilities with smaller cells than other methods [@land_estimating_1994]. 

We use a multinomial logistic model to esimate $\Phi$. The classical expression sets a set of latent propensity ($\eta$) across each dimension ($k$) and across each individual $i$ using a matrix of explanatory variables ($x$) and a matrix of estimates ($\beta$) which is different for each of the $k$ outcomes. 

$$
\eta_{k} =  \beta_k x
$$

The latent propensity is translated into probabilities ($\phi$) using the softmax fucntion.

$$
\phi_{k} = \frac{exp(\eta_{k})} {\sum_{k=1}^K exp(\eta_{k})}
$$

```you use an s_i below, need to fill it out using the likelihood function --- pull from stan manual...or use prior version```

As written, the equation is not identifiable, so one of the response categories is arbitrarily chosen to stand as the reference category, $c$. For the reference category, all coefficients $\beta_k$ are fixed at 0. Because the coefficients for $\beta_C$ are constrained to 0, the denominator on the right side of the equation becomes 1, and the expression reduces to the numerator, making $\beta_k$ an expression of log odds for outcome $k$ relative to the reference category $c$. The reduced expression forms the basis of the likelihood function for the multinomial logit.

Following a strategy similar to Lynch and Brown [-@lynch_new_2005], we predict the probability of the state at the next wave ($\phi_{kt+1}$ based upon the covariates ($x$) and a dummy variable series representing the current state $s$ (again, with an arbitrary state left out for identifiability). These two modifications provide the following model:

$$
log\Bigg( \frac{\phi_{kt+1}} {\phi_{ct+1}} \Bigg)
= \sum_{k=2}^K \gamma_k s_{kt} +  \beta_k x_{t} 
$$

Given the foregoing, we can estimate a complete transition matrix ($\Phi$) using predicted probabilities conditional on the covariate profile $x$ and estimates, iterating through each value in the dummy variable series of $s$ to calculate the probabilities as follows:

$$
\hat{\Phi} =
\begin{bmatrix}
  \hat{\phi}_{1t+1}; \,where \, s_k = 1 &\hat{\phi}_{1t+1}; \, where \, s_k  = 2 &\cdots&\hat{\phi}_{1t+1}; \, where \, s_k  = K \\
  \hat{\phi}_{2t+1}; \, where \, s_k  = 1&\hat{\phi}_{2t+1}; \, where \, s_k  = 2&\cdots&\hat{\phi}_{2t+1}; \, where \, s_k  = K \\
  \vdots & \vdots & \ddots & \vdots \\
\end{bmatrix}
$$

##MCMC Estimation and Sampple from the Posterior Distribution

Bayesian estimation takes advantage of Bayes rule in probability, to estimate the posterior probability distribution of parameters. Bayes rule provides a simple equation that the posterior is proportional to the likelihood times the priors [@lynch_introduction_2007]. For the multinomial, the likelihood is described above. For all prior estimates of $\beta$, we use weakly informative normal priors with mean zero and variance of 10 (large on the log scale), which provide little information and are dominated by the fit of the data as described in the likelihood function. I estimate my Bayesian models in Stan 2.7 using the No U-turn Sampler algorithm, a species of a Hamiltonian Monte Carolo. MCMC samplers operate under the same theories as a hill-climbing algorithm, with the exception that the goal is not to simply find the maximum of the function, but to explore the entire function by producing multiple samples of the distribution. Simple models confirm that estimates of $beta$ from the posterior are very close to the frequentest estimates from Stata. Final models will provide an appendix comparing the estimated posterior to an equivalent model from Stata for comparison.

```you are here```

To produce the probabilities form the PPD, I generate 1000 posterior predicted estimates for each sample member, I slice the posterior predictive estimates by *sending* dummy variables, and calculate the mean expected value of the log odds. I translate this into the transition matrix $T$, by ...

##Sample Life Tables



##Life Table Comparisons


