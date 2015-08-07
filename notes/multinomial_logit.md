---
author: Bryce Bartlett
date: 8/3/2015
title: Technical Memo for Estimates Using Multinomial Logistic (Softmax) Regression
csl: ../citations/asa-mod.csl
bibliography: ../citations/rel_belong.bib
---

#Overview

This memo is intended to outline the steps, procedures, equations, and code needed to estimate the life table supporting the religious belonging. Excerpts will likely find their way into the methods section.

#Summary

The method is based on Bayesian life table methods developed by Lynch and Brown [-@lynch_new_2005], with detailed descriptions and code available in the *Introduction to Applied Bayesian Statistics and Estimation for Social Scientists* [@lynch_introduction_2007] (cross-sectional analysis requires a similar but slightly different set of analyses based on the Sullivan method [@lynch_obtaining_2010]). The method employs a four step approach: (1) build a model to predict transition probabilities; (2) use Bayesian Markov Chain Monte Carlo (MCMC) methods to estimate the model, and keep sample estimates from the posterior; (3) use the sample estimates to sample life tables from the posterior predictive distribution; and (4) compare and contrast the life tables  [@lynch_new_2005]. Each step is discussed in detail below.

##Model for Transition Probabilities

The key for life table construction of step 3 is the accurate estimates of transition probabilities. The key feature is to model the probability of transitioning from one state to another conditional on the individual's current state and some set of predictor variables. The necessary input for step 3 is a matrix of probabilities, $T$. In this case, the matrix is a $j+1 \times j+1$ matrix covering for all possible states describing the individual's self-described religious tradition ( $j$) and death (the plus 1). The columns of $T$ represent the state at time $t$, and the rows of $T$ represent the state at rime $t+1$. The form of $T$ is limited by the transition possiblities in two respects: (1) the sum of the each row must equal 1, indicating that each individual at $t$ is in some state at $t+1$. Similarly, death is an absorbing state, such that the row indicating death has zero on all cells but death. More formally, $T$ must meet the following conditions:

$$
T = 
$$

One way of estimating $T$ is utilizing a multinomial model. The basic form of the model is based upon the the probability that some set of outcomes ($y$) is determined by some set of probability ($\lambda$); the discrete function is usually expressed as follows.

```not sure this likelihood is accurate; came from scott's book on the ordinal probit; do I even need to set this up... could use Stan manual, p. 377?```

$$
L(P|Y) \propto
\prod_{i=1}^n \Bigg ( \prod_{k=1}^K \phi_{ik}^{I(y_i=k)} \Bigg )
$$

Each element from $T$ is flattened into a $k$ dimensional row-vector, $\phi$ probabilitiy for $n$ individuals, $i$. $Y$ is similarly a dummy variable series vector of indicators for each of th $k$ options.  There are a number of ways to estimate $y$, including the multinomial logistic, mixed logistic, and multinomial probit. 

The classical expression of the multinomial logistic is a linear transformation using the softmax link as follows.

$$
\lambda_k =  \beta_k x_i \\
\phi_k = \frac{exp(\lambda_k)} {\sum_{k=1} exp(\lambda)}
$$

$\beta$ is a vector of coefficients and $x$ is a matrix of explanatory variables. The link is by the 'softmax' function relating all the probabilities to a funciton of the sum of probabilities [@kruschke_doing_2015]. ```aren't these odds/?``` As written, the equation is not identifiable, so one of the response categories is arbitrarially chosen to stand as the reference category, $r$. For the reference category, all coefficients $\beta_k$ are fixed at 0, and the odds of each remaining outcome, $k$ is estimated relative to the reference category, $r$, by dividing the logged equation expressed above.


$$
log\Bigg( \frac{\phi_k}{\phi_r} \Bigg) = log \Bigg( \frac{exp(\beta_k x_i)} {exp(\beta_r x_i)} ]Bigg)
$$


Because the coefficients for $\beta_r$ are constrained to 0, the denominator on the right side of the equation becomes 1, and the expression reduces to the numerator, making $\beta_k$ an expression of log odds for outcome $k$ relative to the reference category $r$. The reduced expression forms the basis of the likelihood function for the multinomial logit.

##MCMC Estimation and Posterior Predictive Distribution

Bayesian estimatation takes advantage of Bayes rule in probability, to estimate the posterior probability distrubution of parameters. Bayes rule provides a simple equation that the posterior is proportional to the likelihood times the priors [@lynch_introduction_2007]. For the multinomial, the likelihood is described above. For all prior estimates of $\beta$, I use weakly informative normal priors with mean zero and variance of 5 (large on the log scale), which provide little information and are dominated by the fit of the data as described in the likelihood function. I estimate my Bayesian models in Stan 2.7 using a no U-turn MCMC sampler. MCMC samplers operate under the same theories as a hill-climbing algorithm, with the excpetion that the goal is not to simply find the maximum of the function, but to explore the entire function with multiple samples. Simple models confirm that estimates of $beta$ from the posterior are very close to the frequentist estimates from Stata. Final models will provide an appendix comparing the estimated posterior to an equivalent model from Stata for comparison.

```you are here```

The initial working model is described below. I estimate the log odds of the following outcomes for each individual at time $t$ relative to the reference of *evangelical*: *mainline*, *other*, *catholic*, and *none*. The key explanatory variable is a dummy variable series of the same $k$ outcomes, but at $t-1$. Other covariates are measured at time $t$ and include $age$ and $age^2$,*education*, *female* (dummy), *race* (dummy), *maried* (dummy), and number of *kids*.

```need to figure out what to do with weights, if anything---will need it if I put in a random effect---actually, I should probably just do a first difference model...
don't see death even in the panel...will have to impute with a strong prior..., and do some coding related to attrition with missingness (i.e., if I see them, they  did not die)```

The goal of the Bayesian estimates is to produce posterior predictive distributions (PPD). PPD are a common and powerful application in Bayesian statistics for exploring, comparing, and understanding the data generation process implied by the model relative to the observed data; they are particularly useful in comparing complex and nonnested models, like hierarchical models [@lynch_bayesian_2004]. The PPD is a simulation of hypothetical values of the dependent variable, in this case, the probability (transformed form the log odds) of transitioning from one religious tradition to another. This produces a microsimulation of the data based on the probability density of transition probabilities implied by the model.

To produce the probabilities form the PPD, I generate 1000 posterior predicted estimates for each sample member, I slice the posterior predictive estimates by *sending* dummy variables, and calculate the mean expected value of the log odds. I translate this into the transiction matrix $T$, by ...

##Sample Life Tables



##Life Table Comparisons


