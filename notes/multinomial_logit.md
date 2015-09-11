---
author: Bryce Bartlett
date: 9/11/2015
title: Technical Memo for Estimates Using Multinomial Logistic (Softmax) Regression
csl: ../citations/asa-mod.csl
bibliography: ../citations/rel_belong.bib
---

#Overview

This memo is intended to outline the steps, procedures, equations, and code needed to estimate the life table supporting the religious belonging. It is written so that excerpts can be lifted and placed into a methods section and/or attached (with some revision) as a technical appendix.

In this study, we model changes in in religious tradition identification over time. Using rotating panel data from General Social Survey 2006-2012, we calculate increment-decrement life tables to project expected transitions across religious traditions. Life tables provide a simple and powerful way to summarize and compare transition trends in the population. Reported in terms of life expectancy across each of several states (in this case, religious traditions), increment-decrement tables summarize *both* the proclivity to cross traditions at each age combined with differential mortality rates, a cohort replacement methods.

Findings include:

1) Younger individuals are more likely to transition to None.
2) Transitions across religious traditions for younger adults (30+), and the oldest adults (70+) are conditional on religious tradition of origin. Mainline protestants are more likely to transition to Evangelical, and Other are more likely to transition to None.
3) Middle age adults (50-70) are more likely to transition to Evangelical, regardless of origin.
4) Catholic appears to be the most stable net of transition probabilities and mortality rates.
5) There are similar mortality rates across all traditions in young adulthood, but higher mortality rates for individuals who switch to None. As such, the higher proclivity to switch to None for young adults is partially offset by a higher mortality rate among individuals changing traditions to None.

#Summary

Our analytic approach is based on Bayesian life table methods developed by Lynch and Brown [-@lynch_new_2005], further detail is also outlined in the *Introduction to Applied Bayesian Statistics and Estimation for Social Scientists* [@lynch_introduction_2007]. The method employs a four step approach: (1) build a model to predict transition probabilities; (2) use Bayesian Markov Chain Monte Carlo (MCMC) methods to estimate the model, and draw $M$ samples from the posterior; (3) use the posterior samples to estimate $M$ life tables based upon predicted transition rates; and (4) compare and contrast life table calculations  [@lynch_new_2005]. Each step is discussed in detail below.

##Data

We use rotating panel data from the GSS 2006-2012. As described more fully below, the key Dependant variable is a vector *transition probabilities*, (*i.e.* the probability of moving from catholic to evangelical or from other to none). This requires (1) identification of an individual's *current state*, a dummy variable series including evangelical, mainline, other, catholic, and none, and (2) *next state*, which a dummy variable series with the same religious traditions, but also adds a dummy indicator for attrition by mortality.  Other covariates are measured at the same wave as *current state*, and include $age$ (years) *female* (dummy), *white* (dummy), and *married* (dummy).

##Model for Transition Probabilities

The key for life table construction is the accurate estimates of transition probabilities ($\phi$). More particularly the increment-decrement life lifetable calculations require a matrix of transition probabilities, $\Phi$. The matrix is a $K \times K$ matrix covering for all possible states describing the individual's self-described religious tradition, or death (each a unique $k$ state). The columns of $\Phi$ represent the state at time $t$, and the rows of $\Phi$ represent the probability of transition to another state at time $t+1$. More formally, the properties of $\Phi$ are as follows:

$$
\Phi =
\begin{bmatrix}
  \phi_{1,1}&\phi_{1,2}&\cdots&\phi_{1,K} \\
  \phi_{2,1}&\phi_{2,2}&\cdots&\phi_{2,K} \\
  \vdots & \vdots & \ddots & \vdots \\
  \phi_{K,1} & \phi_{K,2} & \cdots & \phi_{K,K}
\end{bmatrix}
$$

$\Phi$ is limited in two respects: (1) the probabilities ($\phi$) in each row, $r$  must sum to 1  ($\sum_{k=1}^K \phi_{r,k} = 1; \, where \, r \in \{1,2...K\}$). This means that that each individual must begin in some one state at time $t$, and end in some state at $t+1$. (2) For absorbing states, like death, the probability of remaining in this state is 1, with all other transition probabilities equal to 0. This indicates no possibility of transitioning out of absorbing states (*e.g.*, from dead to alive).

Estimating $\Phi$ requires the estimation of probabilities across numerous mutually exclusive categories. Common multinomial models, such as the probit and logit, are well-suited to estimating probabilities conditional on some model. Applying such a model in panel data allows for direct estimation of transition probabilities (like a hazard model), and smooths transition probabilities with smaller cells than other methods [@land_estimating_1994]. 

We use a multinomial logistic model to estimate $\Phi$. One interpretation of the multinomial model envisions a set of latent propensities ($\eta$) across each dimension ($k$). These propensities are linearly related to some matrix of explanatory variables ($x$) and vector of estimates ($\beta$), for a set of $K$ linear equations of the following form: 

$$
\eta_{k} =  \beta_k x
$$

The latent propensities ($\eta$) are translated into probabilities ($\phi$) using the softmax function.

$$
\phi_{k} = \frac{exp(\eta_{k})} {\sum_{k=1}^K exp(\eta_{k})}
$$

As written, the equation is not identifiable, so one of the response categories is arbitrarily chosen to stand as the reference category, $c$. For the reference category, all coefficients $\beta_k$ are fixed at 0. Because the coefficients for $\beta_c$ are constrained to 0, the denominator on the right side of the equation becomes 1, and the expression reduces to the numerator, making $\beta_k$ an expression of log odds for outcome $k$ relative to the reference category $c$. The reduced expression forms the basis of the likelihood function for the multinomial logit.

Following a strategy similar to Lynch and Brown [-@lynch_new_2005], we predict the probability of the state $s$ as a $K \times N$ matrix (one of the religious traditions or death) at the next wave ($s_k^{t+1}$) based upon the state at the current wave ($s_k^t$) and controls ($x$). The Evangelical ($k=1$) state is the reference category on the Dependant variable. A dummy variable series for the current state is included to predict the following state, but excluding Evangelical (1) and Death (6) for identifiability. With these modifications, the model estimates a vector of $K$ probabilities:

$$
log\Bigg( \frac{\phi_k(s_k^{t+1}=1)}
{\phi_k(s_1^{t+1}=1)} \Bigg)
= \sum_{j=2}^5 \gamma_k s_j^t +  \beta_k x^{t} 
$$

After estimating the $\gamma$ and $\beta$ effects, we can construct a complete transition matrix ($\Phi$) using predicted probabilities conditional on the covariate profile $x$ and estimates, iterating through each value in the dummy variable series. We can disaggregate into profiles by any of the modeled values (*e.g.* males vs. females; married vs. single) of $s$ to calculate the probabilities as follows. We construct a set of 33 age-specific transition matrix for each age from 18 to 84 across two year intervals, as follows.



$$
\hat{\Phi} =
\begin{bmatrix}
	\hat{\phi}_1 , \,where \, s_1^t = 1 & \hat{\phi}_2 , \,where \, s_1^t = 1 & \hat{\phi}_3 , \,where \, s_1^t = 1 & \hat{\phi}_4 , \,where \, s_1^t = 1 & \hat{\phi}_5 , \,where \, s_1^t = 1 & \hat{\phi}_6 , \,where \, s_1^t = 1 \\
	\hat{\phi}_1 , \,where \, s_2^t = 1 & \hat{\phi}_2 , \,where \, s_2^t = 1 & \hat{\phi}_3 , \,where \, s_2^t = 1 & \hat{\phi}_4 , \,where \, s_2^t = 1 & \hat{\phi}_5 , \,where \, s_2^t = 1 & \hat{\phi}_6 , \,where \, s_2^t = 1 \\
	\vdots & \vdots & \vdots & \vdots & \vdots & \vdots \\
	\hat{\phi}_1 , \,where \, s_5^t = 1 & \hat{\phi}_2 , \,where \, s_5^t = 1 & \hat{\phi}_3 , \,where \, s_5^t = 1 & \hat{\phi}_4 , \,where \, s_5^t = 1 & \hat{\phi}_5 , \,where \, s_5^t = 1 & \hat{\phi}_6 , \,where \, s_5^t = 1 \\
	0 & 0 & 0 & 0 & 0 & 1
\end{bmatrix}
$$


##MCMC Estimation and Sample from the Posterior Distribution

Bayesian estimation takes advantage of Bayes rule in probability, to estimate the posterior probability distribution of parameters. Bayes rule provides a simple equation that the posterior is proportional to the likelihood times the priors [@lynch_introduction_2007]. For the multinomial, the likelihood is described above. For all prior estimates of $\beta$, we use weakly informative normal priors with mean zero and variance of 10 (large on the log scale), which provide little information and are dominated by the fit of the data from the likelihood. [@lynch_introduction_2007]. We Stan 2.7 to produce our posterior estimates, using the No U-turn Sampler algorithm, a species of a Hamiltonian Monte Carlo. After a warm-up rum of 1,800 draws (which are discarded), we draw 1,800 random samples from the posterior (using 600 draws from three different starting chains to confirm convergence).

We report the mean and standard deviations of the posterior in table 1.

[Table 1]

The estimates in Table 1 report the log odds of a transition to a subsequent state *relative* to a transition to an evangelical religious tradition. Calculations of the predicted probabilities are more informative than these log odds. Figure 1 displays the calculated mortality probabilities in the top frame. These are statistically indistinguishable. The bottom frame displays the probability for staying in a particular tradition in a subsequent wave (the diagonals of $\hat{\Phi}$). These probabilities fall into two general groups, with lower probabilities of staying among those with None and Other religious traditions. All other religious traditions have high probabilities of staying that decline with age; although much of this decline appears related to mortality from the top frame (particularly for Catholics).

[Figure 1]

While there are a significant number of individuals staying, even small transition probabilities add up over time. For example, an annualized transition probability of 5% is equivalent to a transition probability of 40% over 10 years ($1-.95^{10}$). All transitions are not equally probable, of course. The two traditions with the largest gains are Evangelical and None. figure 2 calculates predicted probabilities of transition *into* these traditions conditional on the sending tradition.

[Figure 2]

Mainline is more likely to transition to Evangelical at most ages, but that they are increasingly likely to transition to None at older ages, with the probabilities becoming statistically indistinguishable around 60 years old. Other traditions are much more likely to transition to None than any other tradition across the entire life course.

##Sample Life Tables

For each of the 1,800 draws from the sample posterior, we calculate the predicted transition matrix ($\hat{\Phi}$). After constructing an arbitrary radix of 100,000 individuals (assigned to religious tradition categories into proportions observed in the GSS sample). For this step, we follow the procedures and equations outlined in Lynch and Brown [-@lynch_new_2005] with one exception, using a piecewise linear survival algorithm. We close out the table (individuals 84+) by assuming no religious tradition transitions until the end of life, and calculate person years lived in the oldest period $L_{84+}$ using the reported mortality rates in the 2006 U.S. standard life tables ($M_{85+}$) with the following equation $l_{84+} (I_6 M_{84+})^{-1}$. There was insufficient mortality at the oldest ages of the GSS to provide a stable observed rate, and this is an acceptable approach which has limited impact on the overall estimates across the other 66 years of life lived [*see* @land_mathematical_2005, p. 675; @lynch_obtaining_2010, p. 1068].

Life expectancies at ages 18, 30, 50, and 70 resulting from these calculations are reported in Table 2.

[Table 2]

The life table follows standard assumptions of a stable, synthetic cohort with constant age-specific transition rates. The life expectancies reported are relative to the age reported. Thus, life expectancies at age 18 are expected years of life in a particular tradition, given the tradition at age 18. Similarly, life expectancies at age 30 are expected years of life in a particular tradition, given the tradition at age 30, but irrespective of any past tradition. 

Notably, total life expectancies are in the mid to upper 80s, which are higher than expected. These higher expectancies have two probable causes. First, the GSS excludes the institutionalized population from its sample, including nursing homes and other critical care. By design, this sample will have a higher average life expectancy than population level counts. Second, the panel design follows individuals for only 3 years and despite a fairly large sample including 8,000 person-period observations, rates of death are small and more volatile among these samples, particularly at younger ages, where relativley small and expected random sampling disturbances can propogate to larger . Finally, it is impractical under this Bayesian framework to include weighted nonresponse adjustments. Based on GSS reports, responders are likely to have a better health profile (and lower mortality rate). Similar biases in transition rates among traditions  mean that the transition rates and years in particular traditions may be slightyly underestimated.

#Tables and Figures


Table 1. Bayesian Multinomial Logit Estimates; Reference Category=Evangelical.

|	| To Mainline |  To Other |  To Catholic |  To None |  To Death |
|:------|------------:|----------:|-------------:|---------:|----------:|
| Intercept |-4.004 | -4.204 | -4.281 | -1.916 | -7.669 |
|	|(0.208) |  (0.275) |  (0.25) |  (0.169) |  (0.485) | 
| From Mainline |4.211 | 0.587 | 1.751 | 1.300 | 1.285 |
|	|(0.11) |  (0.377) |  (0.256) |  (0.169) |  (0.278) | 
| From Other |1.181 | 6.059 | 1.819 | 3.225 | 2.319 |
|	|(0.357) |  (0.202) |  (0.472) |  (0.194) |  (0.395) | 
| From Catholic |1.886 | 2.089 | 7.240 | 2.946 | 2.786 |
|	|(0.248) |  (0.36) |  (0.192) |  (0.176) |  (0.296) | 
| From None |1.444 | 2.861 | 3.092 | 4.269 | 1.676 |
|	|(0.189) |  (0.197) |  (0.194) |  (0.112) |  (0.312) | 
| Female |0.122 | 0.118 | 0.040 | -0.366 | -0.821 |
|	|(0.104) |  (0.133) |  (0.122) |  (0.093) |  (0.202) | 
| Married |0.085 | 0.276 | 0.088 | -0.223 | -0.747 |
|	|(0.102) |  (0.14) |  (0.124) |  (0.094) |  (0.216) | 
| White |0.412 | -0.11 | 0.129 | 0.437 | -0.563 |
|	|(0.131) |  (0.154) |  (0.151) |  (0.106) |  (0.222) | 
| Age |0.016 | 0.005 | 0.003 | -0.015 | 0.083 |
|	|(0.003) |  (0.004) |  (0.004) |  (0.003) |  (0.007) | 

Note: Mean of posterior (1,800 draws) with standard deviations in parenthesis; n=8,422. -2LL Posterior=-5,948 (4.740)


Table 2. State-specific despendencies at selected ages.

|Religious Tradition at Age x| Evangelical | Mainline | Other | Catholic | None | 
|:---------------------------|------------:|---------:|------:|---------:|-----:|
|$e_{18}$: Expected years in Tradition (from age 18 )| | | | | |
| Evangelical |  56.8 |  12.2 |  6.0 |  2.4 |  7.4 |  
|	| [55.5, 58.1] | [10.7, 13.8] | [4.7, 7.4] | [1.9, 2.9] | [6.4, 8.4] | 
| Mainline |  3.6 |  50.6 |  1.3 |  1.0 |  2.2 |  
|	| [3.1, 4.2] | [48.3, 52.7] | [0.8, 1.9] | [0.7, 1.3] | [1.6, 2.7] | 
| Other |  1.0 |  0.4 |  44.1 |  0.3 |  2.3 |  
|	| [0.7, 1.2] | [0.2, 0.6] | [40.8, 47.2] | [0.2, 0.5] | [1.8, 2.8] | 
| Catholic |  1.0 |  1.3 |  0.7 |  60.7 |  3.0 |  
|	| [0.8, 1.3] | [0.9, 1.7] | [0.3, 1.2] | [59.2, 62.1] | [2.4, 3.6] | 
| None |  6.1 |  5.2 |  16.2 |  5.0 |  54.1 |  
|	| [5.3, 6.9] | [4.2, 6.2] | [13.8, 18.7] | [4.2, 5.8] | [52.5, 55.7] | 
|Total | 68.5  | 69.7  | 68.3  | 69.4  | 69  | 
|	| [65.4, 71.7] | [64.3, 75] | [60.4, 76.4] | [66.2, 72.6] | [64.7, 73.2] | 
|$e_{30}$: Expected years in Tradition (from age 30 )| | | | | |
| Evangelical |  47.7 |  13.0 |  7.1 |  2.2 |  4.4 |  
|	| [46.2, 49.1] | [10.7, 15.6] | [5.2, 9.2] | [1.7, 2.8] | [3.7, 5.1] | 
| Mainline |  3.3 |  57.4 |  1.6 |  1.0 |  1.4 |  
|	| [2.8, 3.9] | [54.3, 60.8] | [0.9, 2.5] | [0.7, 1.3] | [1.0, 1.7] | 
| Other |  0.9 |  0.4 |  52.2 |  0.3 |  1.4 |  
|	| [0.6, 1.1] | [0.2, 0.7] | [47.7, 57] | [0.2, 0.5] | [1.1, 1.7] | 
| Catholic |  0.9 |  1.4 |  0.9 |  55.6 |  1.8 |  
|	| [0.7, 1.1] | [1, 1.9] | [0.4, 1.4] | [54, 57.1] | [1.4, 2.2] | 
| None |  4.7 |  4.9 |  17.5 |  4.1 |  29.4 |  
|	| [4, 5.5] | [3.8, 6.2] | [13.6, 21.9] | [3.4, 5.0] | [27.9, 31] | 
|Total | 57.5  | 77.1  | 79.3  | 63.2  | 38.4  | 
|	| [54.3, 60.7] | [70, 85.2] | [67.8, 92] | [60, 66.7] | [35.1, 41.7] | 
|$e_{50}$: Expected years in Tradition (from age 50 )| | | | | |
| Evangelical |  31 |  6.5 |  4.1 |  1.4 |  3.8 |  
|	| [30.2, 31.8] | [5.3, 7.7] | [3, 5.3] | [1.1, 1.7] | [3.2, 4.5] | 
| Mainline |  2.5 |  33.5 |  1.1 |  0.7 |  1.3 |  
|	| [2, 2.9] | [32.3, 34.7] | [0.6, 1.6] | [0.5, 1] | [1, 1.7] | 
| Other |  0.6 |  0.2 |  31.3 |  0.2 |  1.2 |  
|	| [0.4, 0.7] | [0.1, 0.4] | [29.4, 33.1] | [0.1, 0.3] | [0.9, 1.5] | 
| Catholic |  0.6 |  0.7 |  0.5 |  35.6 |  1.6 |  
|	| [0.4, 0.8] | [0.5, 1] | [0.2, 0.9] | [34.9, 36.3] | [1.2, 2] | 
| None |  2.6 |  2.0 |  8.4 |  2.2 |  21.8 |  
|	| [2.2, 3] | [1.5, 2.5] | [6.5, 10.7] | [1.7, 2.7] | [20.9, 22.7] | 
|Total | 37.3  | 42.9  | 45.4  | 40.1  | 29.7  | 
|	| [35.2, 39.2] | [39.7, 46.3] | [39.7, 51.6] | [38.3, 42] | [27.2, 32.4] | 
|$e_{70}$: Expected years in Tradition (from age 70 )| | | | | |
| Evangelical |  15.3 |  2.5 |  1.8 |  0.7 |  2.4 |  
|	| [14.9, 15.7] | [2, 3] | [1.3, 2.4] | [0.5, 0.9] | [2.0, 3.0] | 
| Mainline |  1.4 |  14.9 |  0.5 |  0.4 |  1.0 |  
|	| [1.1, 1.7] | [14.5, 15.4] | [0.3, 0.8] | [0.3, 0.5] | [0.7, 1.3] | 
| Other |  0.3 |  0.1 |  14.4 |  0.1 |  0.8 |  
|	| [0.2, 0.4] | [0, 0.1] | [13.6, 15.1] | [0.1, 0.2] | [0.6, 1.1] | 
| Catholic |  0.3 |  0.3 |  0.2 |  17.3 |  1.0 |  
|	| [0.2, 0.4] | [0.2, 0.4] | [0.1, 0.4] | [17, 17.6] | [0.8, 1.3] | 
| None |  1.1 |  0.6 |  3.2 |  0.9 |  12.2 |  
|	| [0.9, 1.3] | [0.5, 0.8] | [2.3, 4.1] | [0.7, 1.1] | [11.7, 12.6] | 
|Total | 18.4  | 18.4  | 20.1  | 19.4  | 17.4  | 
|	| [17.3, 19.5] | [17.2, 19.7] | [17.6, 22.8] | [18.6, 20.3] | [15.8, 19.3] | 


NOTE: Mean posterior estimates with 84% intervals in brackets.



Figure 1. Predicted probabilities of death and staying in current religious tradition by age.

![Fig 1](../draft_img~/mort-stay-probs.png)

Note: Mean predicted probabilities with 84% Confidence Intervalbands. Calculated for white, married men.

Figure 2. Predicted probabilites of Transition Destination for Evangelical and None by age.

![Fig 2](../draft_img~/big-takers.png)