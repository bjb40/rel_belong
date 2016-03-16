---
author: Bryce Bartlett
date: 3/16/2016
title: "Analysis of Projections"
tags: demography, projections, bayesian
bibliography: citations/rel_belong.bib
csl: citations/asa-mod.csl
---

#Overview

This describes the methodology and results of our projection analyses.

#Summary

##Projections

Our study provides demographic projections of future proportions of religious belonging in the United States. Unlike a forecast--which is intended to predict a future state of the world--projections are not necessarily related to a real population. Rather, they are well-suited to addressing counterfactuals, and playing out the implications of population processes [@preston_demography:_2001, p. 118]. We use the the cohort component method of demographic projection. The fundamental process for this method is to begin with an age-specific population distribution; age the population across some discrete interval using age-specific mortality rates; and add new population members (through birth) using age-specific fertility rates [@preston_demography:_2001, p. 120].

Because of data limitations, demographic studies of religious belonging in the past have been unable to analyze differential mortality rates or fertility rates by religious denomination together [@hout_demographic_2001]. Among when studies do include these differential rates, they rely on pooled cross-sectional data from censuses and other sources [@hackett_future_2015]. In this case, we use the GSS panel to estimate age-specific mortality, religious switching rates, and fertility rates; all of which we allow to vary by self-identified religious affiliation. In addition, the panel data allows us to estimate observed *within-person* change over repeated two-year observations instead of relying on assumptions about observed changes in population proportions. Finally, by employing Bayesian methods, we are able to identify uncertainty around the projections, which are otherwise generated deterministically with a single point estimate [@lynch_new_2005].

In this context, we are able to answer a number of questions. Assuming the observed demographic rates between 2008 and 2014 hold constant, what is the stable distribution of religious affiliation? How long would it take for affiliation to stabilize(if ever) if observed demographic rates were to continue unchanged? And, finally, we can address a number of questions regarding differences by religious affiliation, such as, are there different life-expectancies among different religious affiliations, and are there different age-specific rates of mortality and/or fertility among different self-identified religious affiliation

##Method

For our projection, we use a modified version of the demographic balancing equation [@hout_demographic_2001], as follows:

$$
_x\tilde{P}_{yj} = _x\tilde{P}_{y-1 j} + _{x=1}\tilde{B}_{yj} + _x\tilde{C}_{yj} - _x\tilde{A}_{yj} - _x\tilde{D}_{yj} 
$$

Where a tilde ($\tilde{ }$) identifies the posterior predictive values. The posterior predictive is not a deterministic predicted value, but rather, we calculate posterior predictive distributions which integrate over the uncertainty in *both* the estimated parameters and the observed data [@lynch_bayesian_2004; @gelman_bayesian_2014, p.145-152]. We report 95% C.I. for our projections, which, unlike frequentist estimates, has a probabilistic interpretation: conditional on the model and assumptions, there is a 95% probability of the population proportions falling within this band.  In the equation above, $P$ stands for the population proportion for the religious tradition $j$ in year $y$ for age-group $x$. We use six-year age intervals (0-6, 7-12 ...). The model provides that the population in the next year are based upon $B$ are births conditioned no rates estimated from the fertility model. Converts ($C$), apostates ($A$), and deaths ($D$) for each are simulated from the multinomial transition model. For our initial population distribution ($P_{0j}$), we use the proportional age-distribution calculated from the observed distribution at the initial wave of the 2006, 2008, and 2010 GSS panels. This is the only $_xP_{yj}$ for which we employ a deterministic assumption, instead of a posterior predictive predictive distribution.

For our projections, we assume that the observed rates of fertility and mortality remain constant and unchanged. Because the GSS does not include children under the age of 18 as respondents, we employ a few assumptions about these age-groups. First, we follow convention by assuming that children inherit the religious affiliation of their mothers [@hackett_future_2015]. In addition, we apply the 2010 mortality rates published by the U.S. National Vital Statistics System ```[need citation]``` equally to all children regardless of religious affiliation.  

##Results and Discussion 



**Citations**
