#Dev R 3.02
#Cleaning data to set up Bayesian estimation of transition matricies
#Bryce Bartlett

#@@@@@@@@@@@@@@
#Generals
#@@@@@@@@@@@@@@
#load universals configuration file

source("H:/projects/rel_belong/code/config.R",
       echo =T, print.eval = T, keep.source=T)

#@@@@@@@@@@@@@@
#Load Data and subset
#@@@@@@@@@@@@@@

#see readme for source
rawpanel = read.csv(paste(outdir,'private~/cypanel.csv',sep=''))

#select variables to retain

vars = c(
  #independant id variable
  'idnum',
  
  #wave
  'panelwave','dateintv',
  
  #tradition (DV)
  #cyrus stata code : 1) evangelical; 2) mainline; 3)other; (4) catholic; (5) none
  'reltrad',
  
  #time variables
  'age','year',
  
  # controls
  'sex', #gender: 1) male; 2) female
  'educ', #years
  'race', #1)white; 2)black; 3)other
  'marital', #1) married; 2) widowed; 3) divorced; 4) sep; 5) nevermarried
  'income'
  
)

subpanel = subset(rawpanel,select=c(vars))

#@@@@@@@@@@@@@@@@
#recodes
#write tables for checking
#@@@@@@@@@@@@@@@


#gender
subpanel$female = as.numeric(subpanel$sex) - 1

#marital
subpanel$married = as.numeric(NA)
subpanel$married[subpanel$marital == 1] = 1
subpanel$married[subpanel$marital %in% c(seq(2,5))] = 0

#race
subpanel$white = as.numeric(NA)
subpanel$white[subpanel$race == 1] = 1
subpanel$white[subpanel$race > 1] = 0

subpanel$black = as.numeric(NA)
subpanel$black[subpanel$race == 2] = 2
subpanel$black[subpanel$race %in% c(1,3)] = 0

#check recodes
sink(paste(outdir,'dat-transform.txt',sep=''))
  print(Sys.Date(),quote="F")
  cat('\n\n@@@@@@@@@@@@@@@@@@@\ncHECK RECODES ')
  cat('\n@@@@@@@@@@@@@@@@@@@@@\n\n')

  table(subpanel$female,subpanel$sex)

sink()



rm(rawpanel)
write.csv(subpanel,file=paste(outdir,'private~/subpanel.csv',sep=''))

#@@@@@@@@@@@@@@
#Output 
#@@@@@@@@@@@@@@