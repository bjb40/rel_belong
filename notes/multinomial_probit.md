---
author: Bryce Bartlett
date: 8/3/2015
title: Technical Memo for Estimates
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

One way of estimating $T$ is utilizing a multinomial model. The basic form of the model is based upon the likelihood of the multinomial distribution, as follows:

```not sure this likelihood is accurate; came from scott's book on the ordinal probit; do I even need to set this up...?```

$$
L(P|Y) \propto
\prod_{i=1}^n \Bigg ( \prod_{k=1}^K p_{ik}^{I(y_i=k)} \Bigg )
$$

Each element from $T$ is flattened into a $k$ dimensional row-vector, $p$ for $n$ individuals, $i$. $Y$ is similarly a dummy variable series vector of indicators for each of th $k$ options.  There are a number of ways to estimate $y$, including the multinomial logistic, mixed logistic, and multinomial probit. In this case, a multinomial probit is a preferred model where there are correlations between the probabilities, because unlike the multinomial logistic model, the probit allows correlation among the $k$ probabilities (*e.g.* it allows some relationship between transitioning out of the Christian denominations exclusive of the other possiblities).

One conception of the multinomial is the latent variable or augmented data process. This way of viewing the model proposes that the $y$ are observed indicators for a vector of latent continuous variables, $y^*$, along with a matrix of individual-specific explanatory variables ($z$) and a matrix of coefficients $\alpha$ to provide the following linear equaiton:

$$
y^*_{ik} = z_i\alpha_k + \xi_{i}
$$

Classically, the stochastic portion of the model is distributed multivariate normal with a mean vector of 0, and covariance $\Sigma$. The observed choice $y$ for individual $i$ the highest value among the vector of latent variables $y^*_{ik}$,such that.

$$
y_{ik} = \begin{cases}
1,& \mbox{iff } y^*_{ik} = \mathrm{max}(y^*_{i1},y^*_{i2},y^*_{i3},...y^*_{iK}) \\
0, & \mbox{otherwise}
\end{cases}
$$

```cite ross```


This allows an expression of rthe probability of choosing one choice ($c$) among the option ($k$) as follows:



$$
pr(y_{ic} = 1) = pr(y^*_{ic} > y^*_{ik}, \forall k \ne c)
$$


Algebraeically rearranging, gives the following:

$$
z_i \alpha_c + \xi_{ci} > z_i \alpha_k + \xi_{ki} \\
z_i (\alpha_c - \alpha_k)  >  \xi_{ki} - \xi_{ci} \\
$$

Because $\x_{ik}$ and $\xi_{ic}$ are normally distributed with mean 0, the difference $\xi_{ik} - \xi_{ic}$ is also distributed mean 0, subject ot a covariance matrix that is a funciton of the covariance of $\xi_{ik}$. Accoridngly, the above expression can be identified as integrating the probability from a standard normal multivariate distribution, or:



$$
\int_{z_i(\alpha_c - \alpha_k)}^\infty ... \int_{z_i(\alpha_c - \alpha_K)}^\infty \phi d \tilde{\Sigma} \\
\phi \sim MVN(0,\tilde{\Sigma})
$$


The solution suffers fro two drawbacks: (1) it is underidentified, and (2) there is no analytic solution and it is difficult to estimate.

To identify and estimate the model, an arbitrary base category ($l$) is chosen, and subtracted from all others; this results in the following equation for relative, latent utilities ($u$): 

$$
u_{il} = 0 \\
u_{ik} = z_i(\alpha_k - \alpha_l) + (\epsilon_{ik} - \epsilon_{il}) 
$$

Therea are now $k-1$ parameters to estimate, and Substituting again for simplicity,

$$
u_{ik} = z_i \beta_k + \tilde{\epsilon}_{ik} \\
\mbox{where } k>1
$$

Because $\epsilon$ was distributed normally, the difference $\tilde{\epsilon}$ is also normally distributed with mean 0 and some covariance matrix $\tilde{\Sigma}$ (which is a funciton of $\Sigma$). (For purposes of simplicity in the non IIA case in stata, $\tilde{\Sigma}$ diagonal matrix of 2s with 1s on the off-diagonals; I will use this specification to test the algorithm against stata results).

Substituting, the probability that $y_{ik} = 1$ is a function of the differences ($u_{ik}$)



This reduces to the following multivariate normal integral:

$$

\int^1_0 x dx

$$

##MCMC Estimation and Posterior Predictive Distribution



##Sample Life Tables



##Life Table Comparisons


