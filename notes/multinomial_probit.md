---
author: Bryce Bartlett
date: 7/26/2015
title: Technical Memo for Estimates
bibliography:
csl: 
tags: bayesian, probit, multinomial
---

#Overview

This memo is intended to outline the steps, procedures, equations, and code needed to estimate the life table supporting the religious belonging. Excerpts will likely find their way into the methods section.

#Summary

The method is based on Bayesian life table methods developed by Lynch and Brown [-@lynch_new_2005], with detailed descriptions and code available in the *Introduction to Applied Bayesian Statistics and Estimation for Social Scientists" [@lynch_introductin_2007] (cross-sectional analysis requires a similar but slightly different set of analyses based on the Sullivan method [@lynch_obtaining_2010]). The method employs a four step approach: (1) build a model to predict transition probabilities; (2) use Bayesian Markov Chain Monte Carlo (MCMC) methods to estimate the model, and keep sample estimates from the posterior; (3) use the sample estimates to sample life tables from the posterior predictive distribution; and (4) compare and contrast the life tables  [@lynch_new_2005]. Each step is discussed in detail below.

##Model for Transition Probabilities

The key for life table construction of step 3 is the accurate estimates of transition probabilities. The key feature is to model the probability of transitioning from one state to another conditional on the individual's current state and some set of predictor variables. The necessary input for step 3 is a matrix of probabilities, *T*. In this case, the matrix is a $j+1 x j+1$ matrix covering for all possible states describing the individual's self-described religious tradition ( $j$) and death.

These probabilities requires a multinomial model, which can output predicted probabilities. We prefer a multinomial probit, because unlike the multinomial logistic model, it allows correlation among the $j$ probabilities (*i.e.* it allows some relationship between transitioning out of the Christian denominations exclusive of the other possiblities). The basic form of the model 

##MCMC Estimation and Posterior Predictive Distribution



##Sample Life Tables



##Life Table Comparisons


