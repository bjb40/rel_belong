#Dev R 3.02
#Cleaning data to set up Bayesian estimation of transition matricies
#Bryce Bartlett
#NOTE v1.0: LIMITED TO ARBITRARY SUBSET OF  INDIVIDUALS WITH NO MISSING FOR DEVELOPMENT

#@@@@@@@@@@@@@@
#Generals
#@@@@@@@@@@@@@@
#load universals configuration file

st = proc.time()[3]

source("H:/projects/rel_belong/code/config.R",
       echo =T, print.eval = T, keep.source=T)

#@@@@@@@@@@@@@@
#Load Data and subset
#@@@@@@@@@@@@@@

#see readme for source
library(foreign)
rawpanel = read.dta(paste(outdir,'private~/cypanel.dta',sep=''),  convert.factors = FALSE)

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

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#join subset for t-1 in reltrad
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

lastwave = subset(subpanel,select=c(idnum,panelwave,reltrad),panelwave > 1)
lastwave$panelwave = lastwave$panelwave - 1

#remove wave 1 from subpanel and reltrad--need t and t-1 only
subpanel = subset(subpanel, panelwave < 3)

subpanel$reltrad_last = as.numeric(NA)

for(i in unique(subpanel$idnum)){
  for(w in 1:2){
    last = lastwave$reltrad[lastwave$idnum == i & lastwave$panelwave == w]    
    #print(c(i,w,last))
    subpanel$reltrad_last[subpanel$idnum == i & subpanel$panelwave == w] = last
  }
}
rm(lastwave)

#@@@@@@@@@@@@@@@@
#recodes
#write tables for checking
#@@@@@@@@@@@@@@@

#create matrix of indicator variables for reltrad_last
reldum = matrix(0,nrow(subpanel),unique(subpanel$reltrad_last))
for(ob in 1:nrow(reldum)){reldum[ob,subpanel$reltrad_last[ob]]=1}
colnames(reldum) = paste('reltrad_last',1:ncol(reldum),sep='')
subpanel= cbind(subpanel,reldum)
rm(reldum)

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
subpanel$black[subpanel$race == 2] = 1
subpanel$black[subpanel$race %in% c(1,3)] = 0

#hold variables to drop later
dropvar = c('race','sex','marital')

#check recodes
sink(paste(outdir,'dat-transform.txt',sep=''))
  print(Sys.Date(),quote="F")
  cat('\n\n@@@@@@@@@@@@@@@@@@@\ncHECK RECODES ')
  cat('\n@@@@@@@@@@@@@@@@@@@@@\n\n')

  cat('\nReligious tradition recodes for first ten observations\n')
  print(head(subpanel[,c('idnum','reltrad_last','reltrad_last1','reltrad_last2',
              'reltrad_last3','reltrad_last4','reltrad_last5')],n=10))
  cat('\n\nTables overviewing recodes \n')
  
    
  attach(subpanel)
  table(female,sex)
  cat('\n')
  table(married,marital)
  cat('\n')
  table(white,race)
  cat('\n')
  table(black,race)
  detach(subpanel)

cat('\n\n@@@@@@@@@@@@@@@@@@@\nFULL SUBPANEL DESCRIPTIVES')
cat('\n@@@@@@@@@@@@@@@@@@@@@\n\n')

  summary(subpanel)


cat('\n\n@@@@@@@@@@@@@@@@@@@\nINFO ON LIMITING TO RANDOM SUBSAMPLE OF 300 INDIVIDUALS')
cat('\n@@@@@@@@@@@@@@@@@@@@@\n\n')

samp=na.omit(subpanel)
cat('\n                             \t\tPersons\t\tObservations')
cat('\nTotals                      ',length(unique(subpanel$idnum)),nrow(subpanel),sep='\t\t')
cat('\nListwise Delete             ',length(unique(samp$idnum)),nrow(samp),sep='\t\t')

#create random subsample of 300 from remaining
keepid = sample(unique(samp$idnum),size=300,replace=F)
samp=samp[samp$idnum %in% keepid,]
cat('\n300 random sample (person)  ',length(unique(samp$idnum)),nrow(samp),sep='\t\t')

#drop extraneous (recoded variables)
samp = samp[,!names(samp) %in% dropvar]


cat('\n\n@@@@@@@@@@@@@@@@@@@\nSAMPLE DESCRIPTIVES')
cat('\n@@@@@@@@@@@@@@@@@@@@@\n\n')

desc = apply(samp,2,FUN=function(x) 
  c(mn=mean(x),sdev=sd(x),min=min(x),max=max(x),n=length(x)))

print(round(t(desc),digits=2), row.names=F)
rm(desc)

sink()

subpanel=samp

rm(rawpanel,samp)
write.csv(subpanel,file=paste(outdir,'private~/subpanel.csv',sep=''))

#print minutes elapsed for code
(proc.time()[3] - st)/60
