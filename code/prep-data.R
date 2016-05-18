#Dev R 3.02
#Cleaning data to set up Bayesian estimation of transition matricies
#Bryce Bartlett

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

#ids are repeated for each sample with idnum, samptype is the year, but for some reason 2008 is NA
#idnump is the unique identifier across panels
View(rawpanel[,c('year','samptype','idnum','idnump')])
print(table(rawpanel[,c('year','samptype')],useNA='always'))

#select variables to retain
vars = c(
  #independant id variable - jeremy freeze flip code avail from GSS site?
  'idnump',
  
  #wave
  'panelwave','dateintv','samptype',
  
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
  'preteen',
  'teens',
  
  # weight variables
  'wtpan12','wtpannr12','wtpan123','wtpannr123'
  
)

subpanel = subset(rawpanel,select=vars)

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#join subset for t-1 in reltrad; add death as reltrad option
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

nextwave = subset(subpanel,select=c(idnump,panelwave,reltrad,babies,childs,panstat_2,panstat_3),panelwave >1)
nextwave$panelwave = nextwave$panelwave - 1 #take next wave back one

#remove wave 1 from subpanel and reltrad--need t and t+1 only
subpanel = subset(subpanel, panelwave < 3)

#initialies hodlervariables
subpanel$nstate = as.numeric(NA)
subpanel$nbabies = as.numeric(NA)
subpanel$nchilds = as.numeric(NA)
count=0

for(i in unique(subpanel$idnump)){
  for(w in 1:2){
    lim=subpanel$idnump==i & subpanel$panelwave==w
    nextstate = nextwave$reltrad[nextwave$idnump == i & nextwave$panelwave == w]
    nextbabies = nextwave$babies[nextwave$idnump ==i & nextwave$panelwave ==w]
    nextchilds = nextwave$childs[nextwave$idnump==i & nextwave$panelwave == w]
    #print(c(i,w,last))
    subpanel$nstate[lim] = nextstate
    subpanel$nbabies[lim] = nextbabies - subpanel$babies[lim]
    subpanel$nchilds[lim] = nextchilds - subpanel$childs[lim]
  }
  count=count+1
  
  if(count%%1000 == 0){
    cat('\n\nsubpanel\n')
    print(subpanel[subpanel$idnump==i,c('idnump','reltrad','nstate','babies','nbabies','childs','nchilds','panelwave')])
    cat('\nnextwave\n')
    print(nextwave[nextwave$idnum==i,c('idnump','reltrad','babies','childs','panelwave')])
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
  print(head(subpanel[,c('idnump','reltrad','reltrad1','reltrad2',
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
cat('\nTotals                      ',length(unique(rawpanel$idnump)),nrow(rawpanel),sep='\t\t')
cat('\nRemoving 3d wave            ',length(unique(subpanel$idnump)),nrow(subpanel),sep='\t\t')
cat('\nListwise Delete             ',length(unique(samp$idnump)),nrow(samp),sep='\t\t')

#drop extraneous (recoded variables)
samp = samp[,!names(samp) %in% dropvar]

#limit to listwise delete
subpanel=samp

#create random subsample of 300 from remaining
#keepid = sample(unique(samp$idnump),size=300,replace=F)
#samp=samp[samp$idnump %in% keepid,]
#cat('\n300 random sample (person)  ',length(unique(samp$idnump)),nrow(samp),sep='\t\t')

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

cat('\n\n@@@@@@@@@@@@@@@@@@\nFERTILITY DATASET')
cat('\n@@@@@@@@@@@@@@@@@@@@@\n\n')

cat('\nLimit to women 45 and under')
fertpanel = subpanel[subpanel$female == 1 & subpanel$age<46,]
cat('Individuals:',length(unique(fertpanel$idnump)),' Obs: ',nrow(fertpanel),'\n')

cat('\nExclude women with negative change\n')
fertpanel = fertpanel[fertpanel$nchilds >= 0,]
cat('Individuals:',length(unique(fertpanel$idnump)),' Obs: ',nrow(fertpanel),'\n')

cat('\n\ncode for births\n')
fertpanel$birth = NA
fertpanel$birth[fertpanel$nchilds==0] = 0
fertpanel$birth[fertpanel$nchilds>0] = 1

print(table(fertpanel[,c('nchilds','birth')],useNA='always'))
print(table(fertpanel[,c('reltrad','birth')],useNA='always'))


cat('\n\ncode dummy for religious switching\n')
fertpanel$rswitch = NA
fertpanel$rswitch[fertpanel$reltrad == fertpanel$nstate] = 0
fertpanel$rswitch[fertpanel$reltrad != fertpanel$nstate] = 1

print(table(fertpanel[,c('birth','rswitch')],useNA='always'))
print(table(fertpanel[,c('reltrad','rswitch')],useNA='always'))

fertpanel=fertpanel[,c('idnump','childs','birth','educ','married',paste0('reltrad',1:5),'rswitch','age','white','reltrad')]

write.csv(fertpanel,paste0(outdir,'private~/fertpanel.csv'))

cat('Written to ')
paste(outdir,'private~/fertpanel.csv',sep='')
cat('\nFrom prep-data.R code\n\nProcessing time: ')


sink()

print((proc.time()[3] - st)/60)

