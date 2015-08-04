*load data
import delimited /home/utopia3/bjb40/lanhome/projects/rel_belong/output/private~/subpanel.csv

*prepare log
capture log close
log using "/misc/utopia3/bjb40/lanhome/projects/rel_belong/output/mnorm_probit_log.txt", replace text


*basic model
mprobit reltrad female
