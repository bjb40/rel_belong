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
#rpfactor = read.dta(paste(outdir,'private~/cypanel.dta',sep='')) #helps id coding

#select variables to retain
vars = c(
  #independant id variable - jeremy freeze flip code avail from GSS site?
  'idnum',
  
  #wave
  'panelwave','dateintv',
  
  #attrition variables (DV)
  #1: insamp, 2: attrit, 31=institutionalized, 32=moved out of us, 33=died
  'panstat_2','panstat_3',
  
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
  'income',
  
  # fertility variables
  'agekdbrn', #age at first birth
  'childs', #children born to you at any time
  'babies', #number of babies in the home ... (includes adoption)
  
  # weight variables
  'wtpan12','wtpannr12','wtpan123','wtpannr123'
  
)

subpanel = subset(rawpanel,select=vars)

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#join subset for t-1 in reltrad; add death as reltrad option
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

nextwave = subset(subpanel,select=c(idnum,panelwave,reltrad,panstat_2,panstat_3),panelwave >1)
nextwave$panelwave = nextwave$panelwave - 1 #take next wave back one

#remove wave 1 from subpanel and reltrad--need t and t+1 only
subpanel = subset(subpanel, panelwave < 3)

subpanel$nstate = as.numeric(NA)

for(i in unique(subpanel$idnum)){
  for(w in 1:2){
    nextstate = nextwave$reltrad[nextwave$idnum == i & nextwave$panelwave == w]    
    #print(c(i,w,last))
    subpanel$nstate[subpanel$idnum == i & subpanel$panelwave == w] = nextstate
  }
}

#panstat_2 and panstat_3 summarize elligibility
#1) sel, elligible, reinterview; 2) sel, elligible, not reinterview; 3) sel, not ell, not int
#more info about inelligibility 
#31=inelligible b/c lived outside use
#32=inelligible b/c instituionalized
#33=inelligible b/c died

#add death as a final option
subpanel$nstate[subpanel$panstat_2 == 33 & subpanel$panelwave==1] = 6
subpanel$nstate[subpanel$panstat_3 == 33 & subpanel$panelwave==2] = 6

rm(nextwave)

#@@@@@@@@@@@@@@@@
#recodes
#write tables for checking
#@@@@@@@@@@@@@@@

#create matrix of indicator variables for reltrad
reldum = matrix(0,nrow(subpanel),unique(subpanel$reltrad))
for(ob in 1:nrow(reldum)){reldum[ob,subpanel$reltrad[ob]]=1}
colnames(reldum) = paste('reltrad',1:ncol(reldum),sep='')
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
dropvar = c('race','sex','marital','panstat_2','panstat_3')

#check recodes
sink(paste(outdir,'dat-transform.txt',sep=''))
  print(Sys.Date(),quote="F")
  cat('\n\n@@@@@@@@@@@@@@@@@@@\ncHECK RECODES ')
  cat('\n@@@@@@@@@@@@@@@@@@@@@\n\n')

  cat('\nReligious tradition recodes for first ten observations\n')
  print(head(subpanel[,c('idnum','reltrad','reltrad1','reltrad2',
              'reltrad3','reltrad4','reltrad5')],n=10))
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

  
  cat('\n\n@@@@@@@@@@@@@@@@@@@\nCHECK DEATH RECODES')
  cat('\n@@@@@@@@@@@@@@@@@@@@@\n\n')
  
  cat('Wave 1 -> Wave 2\n')
  table(subpanel$nstate[subpanel$panelwave==1],subpanel$panstat_2[subpanel$panelwave==1])
  
  cat('\nWave 2 -> Wave 3\n')
  table(subpanel$nstate[subpanel$panelwave==2],subpanel$panstat_3[subpanel$panelwave==2])
  
  cat('\n\n NOTE.\n
     ROW: (1) evangelical; (2) mainline; (3) other; (4) catholic; (5) none; (6) death\n
     COL: (1) elligible for panel and inerviewed; (2) elligible not interviewed; (31) left US; (32) instutionalized; (33) died'
      )
  
  
cat('\n\n@@@@@@@@@@@@@@@@@@@\nFULL SUBPANEL DESCRIPTIVES')
cat('\n@@@@@@@@@@@@@@@@@@@@@\n\n')

  summary(subpanel)


cat('\n\n@@@@@@@@@@@@@@@@@@@\nINFO ON ANALYTIC SAMPLE')
cat('\n@@@@@@@@@@@@@@@@@@@@@\n\n')

nomiss = apply(is.na(subpanel[,c('reltrad','nstate','age','educ','female','married','white','black')])==F,1,all)

samp=subpanel[nomiss,]
cat('\n                             \t\tPersons\t\tObservations')
cat('\nTotals                      ',length(unique(rawpanel$idnum)),nrow(rawpanel),sep='\t\t')
cat('\nRemoving 3d wave            ',length(unique(subpanel$idnum)),nrow(subpanel),sep='\t\t')
cat('\nListwise Delete             ',length(unique(samp$idnum)),nrow(samp),sep='\t\t')

#drop extraneous (recoded variables)
samp = samp[,!names(samp) %in% dropvar]

#limit to listwise delete
subpanel=samp

#create random subsample of 300 from remaining
#keepid = sample(unique(samp$idnum),size=300,replace=F)
#samp=samp[samp$idnum %in% keepid,]
#cat('\n300 random sample (person)  ',length(unique(samp$idnum)),nrow(samp),sep='\t\t')

cat('\n\n@@@@@@@@@@@@@@@@@@@\nTRANSITION CROSSTAB')
cat('\n@@@@@@@@@@@@@@@@@@@@@\n\n')

cx=table(subpanel$reltrad,subpanel$nstate)
print(cx)
cat('\n\n')
print(prop.table(cx))
rm(cx)

cat('\n\n NOTE: (1) evangelical; (2) mainline; (3) other; (4) catholic; (5) none; (6) death\n\n')

cat('\n\n@@@@@@@@@@@@@@@@@@@\nSAMPLE DESCRIPTIVES')
cat('\n@@@@@@@@@@@@@@@@@@@@@\n\n')

desc = apply(samp,2,FUN=function(x) 
  c(mn=mean(x),sdev=sd(x),min=min(x),max=max(x),n=length(x)))

print(round(t(desc),digits=2), row.names=F)
rm(desc)

rm(rawpanel,samp)
write.csv(subpanel,file=paste(outdir,'private~/subpanel.csv',sep=''))

cat('\n\n@@@@@@@@@@@@@@@@@@@\nNOTES')
cat('\n@@@@@@@@@@@@@@@@@@@@@\n\n')

cat('Written to ')
paste(outdir,'private~/subpanel.csv',sep='')
cat('\nFrom prep-data.R code\n\nProcessing time: ')

#print minutes elapsed for code
print((proc.time()[3] - st)/60)
cat(' minutes')

sink()

print((proc.time()[3] - st)/60)

