---
author: Bryce Bartlett
date: 6/1/2016
title: Updated Projections with Parity Fertility Model
tags: fertility, gss, child measures
bibliography: citations/rel_belong.bib
csl: citations/asa-mod.csl
---

#Introduction

Our study provides demographic projections of future proportions of religious belonging in the United States. Unlike a forecast--which is intended to predict a future state of the world--projections are not necessarily related to a real population. Instead, they explore population change based upon certain assumptions of vital rates. Projections are well-suited to addressing counterfactuals and to playing out the implications of population processes [@preston_demography:_2001, p. 118]. In this study, we estimate rates of fertility and mortality by religious tradition. We also estimate rates of apostasy and conversion. Using these rates together, we use Bayesian methods to estimate probabilistic population projections for religious traditions through 2070--assuming that the estimated rates remain constant over this time interval. While this assumption is not likely to hold true, it is a useful way of assessing current empirical facts. For example, this is the assumption used by the National Vital Statistics System to calculate and report life expectancy. While we anticipate further work will loosen this assumption, this study is the first to our knowledge which (1) directly estimates age-specific fertility rates by religious tradition, (2) estimates rates of conversion, apostasy, and fertility from panel data (showing individual changes), and (3) uses Bayesian probabilistic population projections.

Because of data limitations, past studies of religious belonging have been unable to analyze differential mortality rates or fertility rates by religious denomination [@hout_demographic_2001]. When studies do include these differential rates, they rely on pooled cross-sectional data from censuses and other sources [@hackett_future_2015]. In this case, we use General Social Survey rotating panels (implemented in 2006) to estimate age-specific mortality, religious switching rates, and fertility rates; all of which we allow to vary by self-identified religious affiliation. In addition, the panel data allows us to estimate observed *within-person* change over repeated two-year observations instead of relying on assumptions about observed changes in population proportions. Finally, by employing Bayesian methods, we are able to identify uncertainty around the projections, which are otherwise generated deterministically with a single point estimate [@lynch_new_2005].

In this context, we are able to address a number of open questions. Assuming the observed demographic rates between 2008 and 2014 hold constant, what is the stable distribution of religious affiliation? How long would it take for affiliation to stabilize(if ever) if observed demographic rates were to continue unchanged? And, finally, we can address a number of questions regarding differences by religious affiliation, such as, are there different life-expectancies among different religious affiliations, and are there different age-specific rates of mortality and/or fertility among different self-identified religious affiliation.

#Data

As outlined more fully below, our strategy relies on the basic demographic balancing equation: the fact that populations in the future depend on current population values together with vital rates. While the concept is simple, estimating the rates underlying these changes is more complicated. For the past several decades, however, demographers have linked the estimation of statistical models that produce probabilities (like the logit and the probit) to the hazard rates used in demographic calculation. Moreover, for the past ten years, Bayesian methods have provided the ability to better capture uncertainty around demographic rates and estimates. These advances have made possible more sophisticated estimates, including probabilistic projections recently adopted by the United Nations  ```citation```. To estimate transition probabilities, mortality, and fertility rates, we estimate two types of models: one for simultaneous estimation of transition across religions and mortality, and one for fertility by religious affiliation.

For both models, we use discrete time event history models estimated from from three GSS panels from the recently introduced rotating panel design (2006-2014). These event history models ```cite scott and van hook```.

##Transition and Mortality Model

As described more fully below, the key Dependant variable is a dummy variable series, *next state* identifying a respondent's future religious status and mortality: indicating whether he or she is evangelical, mainline, other, catholic, none, or dead. The GSS panel keeps detailed information on attrition, include reasons for attrition (such as death), making estimation of these probabilities possible. The key control to produce the transition probabilities is the respondent's *current state*, a dummy variable series including evangelical, mainline, other, catholic, and none.  Other covariates are measured at the same wave as *current state*, and include $age$ (years) *female* (dummy), *white* (dummy), and *married* (dummy). Because the GSS interviews span two years, these esitmates provide two-year rates.

##Data for Fertility Model

Following well-accepted demographic models and methods employed in prior projections, we limit the fertility models to women, and presume all children follow the religion of their mother until adulthood at age 18 [@hout_demographic_2001]. Accordingly, the data is limited to women in the GSS between the ages of 18 and 46. The key Dependant variable is whether the respondent experienced a birth between waves. While such births are not directly reported in the data, the GSS asks in each wave "[h]ow many children have you ever had," and directs the respondent to "count all that were born alive at any time" ```codebook citation```. To determine whether a woman experienced a birth between waves, we take the within-person difference of responses on these variables. A little over 1% of the sample report decreases in the number of children (-1 or -2), we exclude these women from the analysis.  

Because the two-year period can include multiple births (approximatley 2% of the sample includes multiple births), we treat the individuals as observed twice (once each year) and distribute single births evenly across the beginning and end of the period. Key dependant variables inlcude a dummy variable series for number of children, including *zero*, *one*, and *two or more*, dummy variables spanning four years each for *age*, a dummy variable series for *religious tradition* consistent with the scheme outlined above, race (*white*), *married or cohabiting*, and *education* (years). As described by Van Hook and Altman [-@van_hook_using_2013], a multiple decrement process can be constructed based on expected probabilities from a discrete time hazard including the age dummy and birth number (partity).

#Method

We use the the cohort component method of demographic projection. The fundamental process for this method is to begin with an age-specific population distribution; age the population across some discrete interval using age-specific mortality and transition rates; and add new population members (through birth) using age-specific fertility rates [@preston_demography:_2001, p. 120].

For our projection, we use a modified version of the demographic balancing equation [@hout_demographic_2001], as follows:

$$
_x\tilde{P}_{yj} = _x\tilde{P}_{y-1 j} + _{x=1}\tilde{B}_{yj} + _x\tilde{C}_{yj} - _x\tilde{A}_{yj} - _x\tilde{D}_{yj} 
$$

Where a tilde ($\tilde{ }$) identifies draws from a (Bayesian) posterior predictive distribution. The posterior predictive is not a deterministic predicted value, but rather, integrates over the uncertainty in *both* the estimated parameters and the observed data [@lynch_bayesian_2004; @gelman_bayesian_2014, p.145-152]. We report 95% C.I. for our projections, which, unlike frequentist estimates, has a probabilistic interpretation: conditional on the model and assumptions, there is a 95% probability of the population proportions falling within this band.  In the equation above, $P$ stands for the population proportion for the religious tradition $j$ in year $y$ for age-group $x$. We use six-year age intervals (0-6, 7-12 ...). The model provides that the population six years later is based upon the prior population with adjustments, including births ($B$), constituting the posterior predictive distribution from the fertility model. Converts ($C$), apostates ($A$), and deaths ($D$) are posterior predictive densities from the multinomial transition model. For our initial population distribution ($P_{0j}$), we use the proportional age-distribution calculated from the observed distribution at the initial wave of the 2006, 2008, and 2010 GSS panels. This is the only $_xP_{yj}$ for which we employ a deterministic assumption, instead of a posterior predictive distribution.

```better reference to markov transition process```

##Transition Probabilities and Multistate Stochastic Processes

```Modified steps, now:
Our analytic approach is based on Bayesian life table methods developed by Lynch and Brown [-@lynch_new_2005], further detail is also outlined in the *Introduction to Applied Bayesian Statistics and Estimation for Social Scientists* [@lynch_introduction_2007]. The method employs a four step approach: (1) build a model to predict transition probabilities; (2) use Bayesian Markov Chain Monte Carlo (MCMC) methods to estimate the model, and draw $M$ samples from the posterior; (3) use the posterior samples to estimate $M$ life tables based upon predicted transition rates; and (4) compare and contrast life table calculations  [@lynch_new_2005]. Each step is discussed in detail below.```

The key for producing our projections is the accurate estimates of transition probabilities ($\phi$). More particularly, for processes envisioning multiple states (an increment-decrement or multiple decrement process) are efficiently represented using a matrix of transition probabilities, $\Phi$. The matrix is a $K \times K$ matrix covering for all possible states (such as an individual's religious tradition, death, or number of children). The rows of $\Phi$ represent the state at time $t$, and the columns of $\Phi$ represent the probability of transition to another state at time $t+1$. More formally, the properties of $\Phi$ are as follows:

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

##Apostasy, Conversion, and Mortality Transition

Estimating $\Phi$ for religious transition requires the estimation of probabilities across numerous mutually exclusive categories. Common multinomial models, such as the probit and logit, are well-suited to estimating probabilities conditional on some model. Applying such a model in panel data allows for direct estimation of transition probabilities (like a hazard model), and smooths transition probabilities with smaller cells than other methods [@land_estimating_1994]. 

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
	\hat{\phi}_1|s_1^t = 1 & \hat{\phi}_2|s_1^t = 1 & \hat{\phi}_3|s_1^t = 1 & \hat{\phi}_4| s_1^t = 1 & \hat{\phi}_5 |s_1^t = 1 & \hat{\phi}_6 |s_1^t = 1 \\
	\hat{\phi}_1 |s_2^t = 1 & \hat{\phi}_2 |s_2^t = 1 & \hat{\phi}_3 |s_2^t = 1 & \hat{\phi}_4 |s_2^t = 1 & \hat{\phi}_5 |s_2^t = 1 & \hat{\phi}_6 |s_2^t = 1 \\
	\vdots & \vdots & \vdots & \vdots & \vdots & \vdots \\
	\hat{\phi}_1 |s_5^t = 1 & \hat{\phi}_2 |s_5^t = 1 & \hat{\phi}_3 |s_5^t = 1 & \hat{\phi}_4 |s_5^t = 1 & \hat{\phi}_5 |s_5^t = 1 & \hat{\phi}_6 |s_5^t = 1 \\
	0 & 0 & 0 & 0 & 0 & 1
\end{bmatrix}
$$


Because the GSS does not include children under the age of 18 as respondents, we employ a few simplifying assumptions about these age-groups. First, we follow convention by assuming that children inherit the religious affiliation of their mothers [@hackett_future_2015]. In addition, we apply the 2010 mortality rates published by the U.S. National Vital Statistics System ```[need citation]``` equally to all children regardless of religious affiliation.  

##Fertility Method

We also model fertility as a multiple decrement process. In particular, we follow Van Hook and Anderson's method [@van_hook_using_2013] to model fertility probabilites based upon a woman's parity (number of children). Modeling as a multiple decrement process showed much better fit than models which exlcude birth parity. Unlike the increment-decrement transition matrix for conversion, apostasy and mortality, women may progress *through* decrements, but may not return to a lower birth parity. As such, and as more fully explained by Van Hook and Anderson, we can model the discrete time hazard with a simple logistic regression, including interactions of the dummy variable series for age, and the dummy variable series for religious traditions (to capture the possibility of differential fertility across religious traditions). This reduces to the following latent propensity of having a birth, conditional on prior births ($p$) as follows:

```this is crap -- need to fix```

$$
\eta|p,x = \alpha p + \beta_x A_x + \gamma_{px} (A_x) + \rho_j R_j + \lambda_j R_j p
$$

Where there is a base level of fertility for each age dummy ($A_x$) and each of the each of the five religious traditioons ($R_j$), but each level of partiy ($p$) has a different baseline level, and an adjusted age-specific effect ($\gamma$) and effect by religious tracditon ($\lambda$).

These latent propensities can be translated into probabilities ($\phi$) using the logit function:

$$
\phi_p = \frac{exp(\eta_p)}{1+exp(\eta_p)}
$$

Once again, we generate a matrix of transition probabilities across decrements of births including *no births*, *1 birth*, and *2 or more births*. The rows and cells of the transition matrix are the conditional expectations based on parity over the above equation. To allow for differential fertility across, we generate a transition matrix for each of the religious traditions, and across age groups 18-46 (we treat births before 18 as negligible). Because women cannot return to lower parities, a number of cells in the transition matrix are structurally zero:


$$
\hat{\Phi} =
\begin{bmatrix}
	1-\hat{\phi}_1|p = 0 &  \hat{\phi}_1|p = 0  & 0 \\
	0 & 1-\hat{\phi}_2|p = 1 &  \hat{\phi}_2|p = 1 \\
	0 & 0 & \hat{\phi}_3|p = 2  \\
\end{bmatrix}
$$

As before, we estimate the models in Stan and draw 1,800 samples (600 from 3 chains using the Hamiltonian Monte Carlo algorithm) from the posterior distribution after discarding an equivalent sized warm-up sample.

##Projection

Finally, we use estimates from the fertility and transition model to project changes in religious belonging. First, we produce a sample of 500 mean age-specific transition matricies from the Bayesian models estimated above for the probability of transitioning or dying over the next six years. Similarly, we produce mean age-specific fertility matricies for women between the ages of 18 and 46 by parity and religion. ```discuss what you hold at means???```

Second, we generate a baseline population proportion from the pooled, observed proportions of religious traditions in the initial wave of each GSS panel (2006, 2008, and 2010) sliced by religion, gender, birth parity for women (0, 1, or 2+ births) and six-year age groups. For consistency with the fertility model, the three youngest age groups (comprising of individuals 17 and under) are imputed from the number of children reported by women respondents. We divide men and women by imputing given a sex ratio of 1.06. We rescale this population proportion to represent a radix of 100,000 individuals.

Third, using a linear assumption for matrix life-table calculations, we make 500 random draws of religious apostasy/conversion or mortality from the baseline population, given the sample of age-specific transition matricies. ```cite scott and schoen```. Fourth, using a linear assumption for matrix life-table calculations, for women between ages 18 and 46, we make 500 random draws from the age and parity specific to estimate births and parity transitions for a six-year interval.

Fourth, from the results of the life-table calculations, we keep the sample of 500 posterior-predicted populations, aged one year, and include the sum of new births as the first age interval. As before, we randomly assign gender to the new births using a sex ratio of 1.06. Finally, we reiterate the process 10 times to produce a sample of 500 projections of religious change across 60 years.

##Results 

**Transition and Mortality Model**

We report the mean and standard deviations of the posterior for the multinomial transition model in table 1.

[Table 1]

The estimates in Table 1 report the log odds of a transition to a subsequent state *relative* to a transition to an evangelical religious tradition. Calculations of the predicted probabilities are more informative than these log odds. Figure 1 displays the calculated mortality probabilities in the top frame. These are statistically indistinguishable. The bottom frame displays the probability for staying in a particular tradition in a subsequent wave (the diagonals of $\hat{\Phi}$). These probabilities fall into two general groups, with lower probabilities of staying among those with None and Other religious traditions. All other religious traditions have high probabilities of staying that decline with age; although much of this decline appears related to mortality from the top frame (particularly for Catholics).

[Figure 1]

While there are a significant number of individuals staying, even small transition probabilities add up over time. For example, an annualized transition probability of 5% is equivalent to a transition probability of 40% over 10 years ($1-.95^{10}$). All transitions are not equally probable, of course. The two traditions with the largest gains are Evangelical and None. figure 2 calculates predicted probabilities of transition *into* these traditions conditional on the sending tradition.

[Figure 2]

Mainline is more likely to transition to Evangelical at most ages, but that they are increasingly likely to transition to None at older ages, with the probabilities becoming statistically indistinguishable around 60 years old. Other traditions are much more likely to transition to None than any other tradition across the entire life course.

**Fertility Model**

We report the mean and standard deviations of the posterior for the logistic fertility model in table 2.

[Table 2]

The estimates in Tble 2 report the log odds of birth conditional on the covariates. 

[Figure 3]

**Projection**

[Table 3]

The population proportions move quickly toward stability from current population proportions. In general, all of the affiliations lose adherents except for nones, as described in figure 1 below.

```need fixed```

The age-specific distributions provide some interesting contrasts. For example, as described in the transition probabilities, Nones remain the youngest religious tradition, declining in old age as the probability of staying "None" decreases with age. Second, evangelicals maintain a fairly robust proportion throughout, as identified below. Notably, there is still some shifting to occur, because the oldest in the graph below were not subject to the same demographic rates.

[Figure 4]

**Works Cited**

