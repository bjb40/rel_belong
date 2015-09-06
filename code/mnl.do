*load data
import delimited /home/utopia3/bjb40/lanhome/projects/rel_belong/output/private~/subpanel.csv

*prepare log
capture log close
log using "/misc/utopia3/bjb40/lanhome/projects/rel_belong/output/mnl_log.txt", replace text


*code age squared
gen age2 = age*age
gen femalexage = female*age
gen whitexage = white*age

*basic models
mlogit nstate reltrad2 reltrad3 reltrad4 reltrad5  
estat ic

mlogit nstate reltrad2 reltrad3 reltrad4 reltrad5 female married white age
estat ic

mlogit nstate reltrad2 reltrad3 reltrad4 reltrad5 female married white age age2
estat ic


*interaction models
mlogit nstate reltrad2 reltrad3 reltrad4 reltrad5 female femalexage married ///
	white whitexage age
estat ic
