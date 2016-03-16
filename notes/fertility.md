---
author: Bryce Bartlett
date: 3/8/2016
title: Fertility Measures from GSS Panel
tags: fertility, gss, child measures
bibliography: citations/rel_belong.bib
csl: citations/asa-mod.csl
---

#Overview

Trying to calculate religion specific fertility rates from GSS.

#Summary

##Literature

Earlier studies use GSS self-reports of numbers of children to get mean fertility rates (and assume that the mother transfers religious belonging to child). Examples are cited below; especially Hout, Greeley, and Wilde [-@hout_demographic_2001]. 

##Available Variables

The panel GSS should have sufficient information to create age-specific fertility rates (or at least get some relevant differences), or loosen the assumption of simple transfer. There are a number of child variables, including the following (names are GSS conventions from codebook):

* childs: "How many children have you ever had?  Please count all that were born alive at any time (including any you had from a previous marriage)." (top coded by GSS at 8)
* evkid: "Have you ever (given birth to [IF FEMALE]/fathered [IF MALE]) a child?"
* agekdbrn: " How old were you when your first child was born?" (younger age at first birth is generally related to more kids)
* babies: household members under 6 (Appendix D)
* preteen: household members 6-12 (Appendix D)
* teen: household members 13-17 (Appendix D)
* kd#relig (where # indicates integer for 1-8; 2008 panel only) "In what religion is (CHILD’S NAME) being raised? Is it Protestant, Catholic, Jewish, some other religion, or no religion?"

##Simplest strategy

The simplest strategy is to use the "childs" variable to get age-specific fertility. Limit the panel to women, and take the difference between childs at wave $t$ and $t+1$. The number should always be positive and increasing, and should count fertility rate across two years. This seems to work OK, *but* there are seriously confusing tabulations. Absent multiple births, 2 should be the maximum and 0 should be the minimum, but the tabulation for the 2006, 2008, and 2010 female panels for this difference is as follows:

|$childs_t$ - $childs_{t-1}$ | freq |
|:----|---:|
| -8 | 1 |
| -7 | 1 |
| -6 | 0 |
| -5 | 3 |
| -4 | 7 |
| -3 | 10 |
| -2 | 27 |
| -1 | 101 |
| 0 | 4262 |
| 1 | 360 |
| 2 | 56 |
| 3 | 14 |
| 4 | 5 |
| 5 | 2 |
| 6 | 2 |
| 7 | 1 |
| 8 | 0 |
|NA | 2581 |

(Note that the NA is generally attrition across panel waves; there should be two observations per individual in the table, and this includes females of all ages, but should probably be limited to 45 and younger, *i.e.* those at risk of fertility).

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

##Model excerpt

Following standard projection procedure, we model female fertility from the GSS. Following the multinomial logistic, we use a univariate logit to produce smoothed age-conditional estimates for female fertility taking advantage of the panel design of the GSS. We limit the sample to women at risk of childbirth (between the ages of 18 and 45; although there are fertility events before and after these events, we treat them as negligible). At each wave of the GSS, the a woman is asked how many children she's given birth to. The change over two years of the panel wave indicates a birth event (1), and no change indicates no birth (0). We exclude women who report having birthed fewer children in subsequent waves (as they likely result from misreports/misunderstanding), and do not adjust for multiple birth events. There are a few women who report two or more births over the period, but the numbers are relatively small. This means that our estimated fertility probabilities are likely to generate slight underestimates. We adjust using *age* and *age-squared* (unlike mortality, fertility rates are not increasing functions of age) and mean center age to aid convergence, *education*, *marital status* (married=1), *religious tradition* in current wave, and a dummy to indicate whether respondent *switched religious affiliation* (switching=1). As before, we estimate the models in Stan and draw 1,800 samples (600 from 3 chains) from the posterior distribution after discarding an equivalent sized warm-up sample.

##Results and Findings 

Bayesian logistic estimates for log odds of having a child in the next two years (women 18-45).

|  |  |
|:----|----:|
| Intercept |**-1.393**<br>[-2.078,-0.738]|
| Age |**-0.081**<br>[-0.114,-0.050]|
| Age^2^ |-0.001<br>[-0.005,0.003]|
| Married |**0.709**<br>[0.447,0.965]|
| Education |**-0.059**<br>[-0.101,-0.015]|
| *Religion* (ref=Evangelical) | |
| Mainline |0.297<br>[-0.390,0.894]|
| Other |0.622<br>[-0.050,1.259]|
| Catholic |**0.594**<br>[0.197,1.017]|
| None |0.399<br>[-0.058,0.861]|
| *Interactions with Age and Religion*| |
| AgexMainline |-0.002<br>[-0.073,0.068]|
| AgexOther |-0.093<br>[-0.234,0.017]|
| AgexCatholic |0.017<br>[-0.038,0.069]|
| AgexNone |-0.003<br>[-0.070,0.058]|
| Age^2^xMainline |-0.007<br>[-0.016,0.003]|
| Age^2^xOther |**-0.016**<br>[-0.033,-0.003]|
| Age^2^xCatholic |**-0.007**<br>[-0.014,-0.001]|
| Age^2^xNone |-0.004<br>[-0.011,0.003]|
| Switched Affiliation |-0.114<br>[-0.432,0.197]|

Note: Mean estimates with 95% C.I. Bold indicates different from 0 at p<.05 (two-tailed). To aid convergence, age was mean centered.

The table above shows a number of expected effects. Generally, the fertility rate falls with age and higher eduction, but is higher among the married. With respect to religious affiliation, there are a few effects which meet classical levels of significance. In particular, Catholics have different base rates and quadratic curves from Evangelicals, and the Other religionists have different quadratic effects from Evangelicals. The precise meaning of these differences is difficult to intuit from the numbers alone, and the table itself does not present multiple hypothesis testing for group-level differences or for differences between non-evangelical religious groups (such as None and Other). The simplest presentation is in the form of predicted probabilities, presented below.

![Age-specific Fertility Probabilities](../draft_img~/age-fertilitypub.png)

The age-specific fertility rates converge closest to equality at older ages, with Other and Nones experiencing the lowest fertility levels, and Catholics and Evangelicals experiencing the highest levels; although Catholics maintain the highest fertility levels at the older end of the range, from ages 35 to 45. Two-year fertility probabilities for women of all religious traditions, except Evangelicals, begin with lower age-specific fertility at age 18, and then peak between the mid-twenties and early thirties. Evangelicals start with highest fertility probabilities at age 18, which slowly decline with age. Because of lacking data, most projections rely on total fertility rates, and assumptions [@hout_demographic_2001]. Because the GSS panel design allows us to observe fertility differences by *both* age and religious affiliation, we are better able to parse out differences in denominations from births. This appears to be particularly important for Catholics (who have more births toward later ages) and Evangelicals (who have more births at younger ages).

**Citations**

