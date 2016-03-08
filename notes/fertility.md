---
author: Bryce Bartlett
date: 3/8/2016
title: Fertility measures in gss
tags: fertility, gss, child measures
---

#Overview

Trying to calculate religion specific fertility rates from GSS.

#Summary

##Literature

Earlier studies use GSS self-reports of numbers of children to get mean fertility rates (and assume that the mother transfers religious belonging to child). Examples are cited below (especially Hout et al. 2001). 

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

**Citations**
Hackett, Conrad, Marcin Stonawski, Michaela Potančoková, Brian J. Grim, and Vegard Skirbekk. 2015. “The Future Size of Religiously Affiliated and Unaffiliated Populations.” Demographic Research 32:829–42.
Hout, Michael, Andrew Greeley, and Melissa J. Wilde. 2001. “The Demographic Imperative in Religious Change in the United States.” American Journal of Sociology 107(2):468–500.
McQuillan, Kevin. 2004. “When Does Religion Influence Fertility?” Population and Development Review 30(1):25–56.
Skirbekk, Vegard, Eric Kaufmann, and Anne Goujon. 2010. “Secularism, Fundamentalism, or Catholicism? The Religious Composition of the United States to 2043.” Journal for the Scientific Study of Religion 49(2):293–310.
Street, 1615 L., NW, Suite 800 Washington, and DC 20036 202 419 4300 |. Main 202 419 4349 |. Fax 202 419 4372 |. Media Inquiries. 2015. “The Future of World Religions: Population Growth Projections, 2010-2050.” Pew Research Center’s Religion & Public Life Project. Retrieved March 7, 2016 (http://www.pewforum.org/2015/04/02/religious-projections-2010-2050/).
