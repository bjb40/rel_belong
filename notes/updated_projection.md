---
author: Bryce Bartlett
date: 5/25/2016
title: Updated Projections with Parity Fertility Model
tags: fertility, gss, child measures
bibliography: citations/rel_belong.bib
csl: citations/asa-mod.csl
---

#Introduction

Our study provides demographic projections of future proportions of religious belonging in the United States. Unlike a forecast--which is intended to predict a future state of the world--projections are not necessarily related to a real population. Rather, they are well-suited to addressing counterfactuals, and playing out the implications of population processes [@preston_demography:_2001, p. 118]. We use the the cohort component method of demographic projection. The fundamental process for this method is to begin with an age-specific population distribution; age the population across some discrete interval using age-specific mortality rates; and add new population members (through birth) using age-specific fertility rates [@preston_demography:_2001, p. 120].

Because of data limitations, demographic studies of religious belonging in the past have been unable to analyze differential mortality rates or fertility rates by religious denomination together [@hout_demographic_2001]. Among when studies do include these differential rates, they rely on pooled cross-sectional data from censuses and other sources [@hackett_future_2015]. In this case, we use the GSS panel to estimate age-specific mortality, religious switching rates, and fertility rates; all of which we allow to vary by self-identified religious affiliation. In addition, the panel data allows us to estimate observed *within-person* change over repeated two-year observations instead of relying on assumptions about observed changes in population proportions. Finally, by employing Bayesian methods, we are able to identify uncertainty around the projections, which are otherwise generated deterministically with a single point estimate [@lynch_new_2005].

In this context, we are able to answer a number of questions. Assuming the observed demographic rates between 2008 and 2014 hold constant, what is the stable distribution of religious affiliation? How long would it take for affiliation to stabilize(if ever) if observed demographic rates were to continue unchanged? And, finally, we can address a number of questions regarding differences by religious affiliation, such as, are there different life-expectancies among different religious affiliations, and are there different age-specific rates of mortality and/or fertility among different self-identified religious affiliation

#Data

As outlined more fully below, our strategy relies on basic--and fairly obvioius observation that populations in the future depend on current populaiton values, and vital rates. While the concept is simple, estimating the rates underlying these changes is more complicated. For the past several decades, however, demographers have linked the estimation of statistical models that produce probabilities (like the logit and the probit) to the hazard rates used in demographic calculation. Moreover, for the past ten years, Bayesian methods, and bootstrapping have provided the ability to better capture uncertainty around demographic rates and estimates. These advances have made possible more sophisticated estimates, including probabilistic projections adopted by the UN this decade ```citation```. To estimate transition probabilities, mortality, and fertility rates, we estimate two types of models: one for simultaneous estimation of transition across religitons and mortality, and one for fertility by religious affiliation.

For both models, we use three GSS panels from the recently intorduced rotating paneldesign 2006-2014.

##Transition and Mortality Model

As described more fully below, the key Dependant variable is a vector *transition probabilities*, (*i.e.* the probability of moving from catholic to evangelical or from other to none). This requires (1) identification of an individual's *current state*, a dummy variable series including evangelical, mainline, other, catholic, and none, and (2) *next state*, which a dummy variable series with the same religious traditions, but also adds a dummy indicator for attrition by mortality.  Other covariates are measured at the same wave as *current state*, and include $age$ (years) *female* (dummy), *white* (dummy), and *married* (dummy).

##Data for Fertility Model

##Data Structure for Fertility

The panel GSS has sufficient information to create age-specific fertility rates (or at least get some relevant differences), or loosen the assumption of simple transfer. There are a number of child variables, including the following (names are GSS conventions from codebook):

* childs: "How many children have you ever had?  Please count all that were born alive at any time (including any you had from a previous marriage)." (top coded by GSS at 8).

The simplest strategy is to use the "childs" variable to get age-specific fertility. Limit the panel to women, and take the difference between childs at wave $t$ and $t+1$. The number should always be positive and increasing, and should count fertility rate across two years. This seems to work OK, *but* there are seriously confusing tabulations. Absent multiple births, 2 should be the maximum and 0 should be the minimum, but the tabulation for the 2006, 2008, and 2010 female panels for this difference is as follows:

#Method

For our projection, we use a modified version of the demographic balancing equation [@hout_demographic_2001], as follows:

$$
_x\tilde{P}_{yj} = _x\tilde{P}_{y-1 j} + _{x=1}\tilde{B}_{yj} + _x\tilde{C}_{yj} - _x\tilde{A}_{yj} - _x\tilde{D}_{yj} 
$$

Where a tilde ($\tilde{ }$) identifies draws from a (Bayesian) posterior predictive distribution. The posterior predictive is not a deterministic predicted value, but rather, integrates over the uncertainty in *both* the estimated parameters and the observed data [@lynch_bayesian_2004; @gelman_bayesian_2014, p.145-152]. We report 95% C.I. for our projections, which, unlike frequentist estimates, has a probabilistic interpretation: conditional on the model and assumptions, there is a 95% probability of the population proportions falling within this band.  In the equation above, $P$ stands for the population proportion for the religious tradition $j$ in year $y$ for age-group $x$. We use six-year age intervals (0-6, 7-12 ...). The model provides that the population six years later is based upon the prior population with adjustments, including births ($B$), constituting the posterior predictive distribution from the fertility model. Converts ($C$), apostates ($A$), and deaths ($D$) are posterior predictive densities from the multinomial transition model. For our initial population distribution ($P_{0j}$), we use the proportional age-distribution calculated from the observed distribution at the initial wave of the 2006, 2008, and 2010 GSS panels. This is the only $_xP_{yj}$ for which we employ a deterministic assumption, instead of a posterior predictive distribution.

##Religious Transitions and Mortality

Our analytic approach is based on Bayesian life table methods developed by Lynch and Brown [-@lynch_new_2005], further detail is also outlined in the *Introduction to Applied Bayesian Statistics and Estimation for Social Scientists* [@lynch_introduction_2007]. The method employs a four step approach: (1) build a model to predict transition probabilities; (2) use Bayesian Markov Chain Monte Carlo (MCMC) methods to estimate the model, and draw $M$ samples from the posterior; (3) use the posterior samples to estimate $M$ life tables based upon predicted transition rates; and (4) compare and contrast life table calculations  [@lynch_new_2005]. Each step is discussed in detail below.

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

##Fertility

For our projections, we assume that the observed rates of fertility and mortality remain constant and unchanged. Because the GSS does not include children under the age of 18 as respondents, we employ a few assumptions about these age-groups. First, we follow convention by assuming that children inherit the religious affiliation of their mothers [@hackett_future_2015]. In addition, we apply the 2010 mortality rates published by the U.S. National Vital Statistics System ```[need citation]``` equally to all children regardless of religious affiliation.  



##Fertility Method

Following standard projection procedure, we model female fertility from the GSS. Following the multinomial logistic, we use a univariate logit to produce smoothed age-conditional estimates for female fertility taking advantage of the panel design of the GSS. We limit the sample to women at risk of childbirth (between the ages of 18 and 45; although there are fertility events before and after these events, we treat them as negligible). At each wave of the GSS, the a woman is asked how many children she's given birth to. The change over two years of the panel wave indicates a birth event (1), and no change indicates no birth (0). We exclude women who report having birthed fewer children in subsequent waves (as they likely result from misreports/misunderstanding), and do not adjust for multiple birth events. There are a few women who report two or more births over the period, but the numbers are relatively small. This means that our estimated fertility probabilities are likely to generate slight underestimates. We adjust using *age* and *age-squared* (unlike mortality, fertility rates are not increasing functions of age) and mean center age to aid convergence, *education*, *marital status* (married=1), *religious tradition* in current wave, and a dummy to indicate whether respondent *switched religious affiliation* (switching=1). As before, we estimate the models in Stan and draw 1,800 samples (600 from 3 chains) from the posterior distribution after discarding an equivalent sized warm-up sample.

##Results and Discussion 

**Transition and Mortality Model**

The population proportions move quickly toward stability from current population proportions. In general, all of the affiliations lose adherents except for nones, as described in figure 1 below.

![Predicted proportion of adherents.](../draft_img~/project-bar.png)

The age-specific distributions provide some interesting contrasts. For example, as described in the transition probabilities, Nones remain the youngest religious tradition, declining in old age as the probability of staying "None" decreases with age. Second, evangelicals maintain a fairly robust proportion throughout, as identified below. Notably, there is still some shifting to occur, because the oldest in the graph below were not subject to the same demographic rates.

![Age-specific distribution of adherents.](../draft_img~/2040_prop.png)

**Fertility Model**

Descriptive statistics show a few irregulatities ...

The negatives are completely erroneous (*i.e.* impossible answers), and amount to 2% of the sample. The positive fertility amounts to 5.92% of the sample, 0 amounts to 57.3% of the sample, and missing amounts to 34.7% of the sample.

Limiting solely to women at risk of childbirth (45 or younger), the negative increase is 1.14% of the sample; 0 is 42.8% of the sample, new births amounts to 7.91% of the sample, and the NA amounts to 48.1% of the sample. Here is the distribution:

|$childs_t$ - $childs_{t-1}$ | freq |
|:----|---:|
| -8 | 0 |
| -7 | 1 |
| -6 | 0 |
| -5 | 0 |
| -4 | 1 |
| -3 | 1 |
| -2 | 9 |
| -1 | 36 |
| 0 | 1803 |
| 1 | 288 |
| 2 | 38 |
| 3 | 5 |
| 4 | 1 |
| 5 | 0 |
| 6 | 0 |
| 7 | 1 |
| 8 | 0 |
|NA | 2028 |

Given the foregoing, I will recode negative values to missing, and calculate age-specific fertility rates using a Bayesian hierarchical survival model, under listwise deletion. This is consistent with the multinomial strategy, and is different from prior projections which use pooled cross-sectional data. We can highlight the errors in a footnote, and suggest the need for further research. To the extent necessary, we can build this into a missing data model.

**Projection**


**Works Cited**

