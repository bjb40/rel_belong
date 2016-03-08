#Bryce Bartlett
#Makes fertility rates
#Dev R ""



#@@@@@
#Preliminaries and load data
#@@@@@


#@@@@
#assign variables
#@@@@

#listwise delete
print(c(nrow(fertpanel),length(unique(fertpanel$idnump))))
fertpanel = na.omit(fertpanel)
print(c(nrow(fertpanel),length(unique(fertpanel$idnump))))

#mean center age
fertpanel$c_age = fertpanel$age - mean(fertpanel$age)
fertpanel$age2 = fertpanel$age^2
fertpanel$c_age2 = fertpanel$c_age^2

  
y=fertpanel$birth
fertpanel$intercept = 1
x=fertpanel[,c('intercept','c_age','c_age2','married','educ',paste0('reltrad',1:5))]

#@@@@@@
#call stan and sample
#@@@@@@



#@@@@
#print table and graph of preicted probabilities
#@@@@

#@@@@@@
#save posterior
#@@@@@@
