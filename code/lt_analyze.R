#@@@@@@@@@@@@@@@@@@@@@@@@@@
#dev R 3.2.1 "World-Famous Astronaut"
#analyzing increment-decrement tables produced in lifetable.R
#Bryce Bartlett
#@@@@@@@@@@@@@@@@@@@@@@@@@@

#load general info

#load universals configuration file
source("H:/projects/rel_belong/code/config.R",
       echo =T, print.eval = T, keep.source=T)

#@@@@@@@@@@@@@@@@@@@@@@@@
#Load life table samples
#@@@@@@@@@@@@@@@@@@@@@@@@

l = read.csv(paste(outdir,'l.csv',''), header=F)
#lar = array(unlist(read.csv(paste(outdir,'l.csv',''), header=F)[,2:26]),c(30,10000,25))
#confirm array is put together correctly
#View(l[1:30,2:26] == lar[,1,])
#rm(l)

le = read.csv(paste(outdir,'le.csv',''), header=F)

nm = c('Evangelical','Mainline', 'Other', 'Catholic','None')

#@@@@@@@@@@@@@@@@@@@@@@@@
#Generate summary table for life expectancy
#@@@@@@@@@@@@@@@@@@@@@@@@

#estimate
le.est = aggregate(le,by=list(le$V1),mean)
#95 percentile
le.lower = aggregate(le,by=list(le$V1),quantile, prob=0.025)
le.upper = aggregate(le,by=list(le$V1),quantile, prob=0.975)

colnames(le.lower)[3:7] = colnames(le.upper)[3:7] = colnames(le.est)[3:7] = nm 

sink(paste(outdir,'le-table.txt',sep=''))
  print(Sys.Date(),quote="F")
  cat('\n\n@@@@@@@@@@@@@@@@@@@\nFull Expectances (le0) ')
  cat('\n@@@@@@@@@@@@@@@@@@@@@\n\n')

  for(r in 1:5){
    cat(paste('\nExpeted time (with 95% intervals) in traditions for those starting as', nm[r]))
    cat('\n')
    print(rbind(round(le.est[r,3:7],3),
                round(le.lower[r,3:7],3),
                round(le.upper[r,3:7],3)
                ),
          row.names=c('estimate','lower','uppper'))
    }

sink()

#@@@@@@@@@@@@@@@@@@@@@@@@
#Plot lx (survival) curves
#@@@@@@@@@@@@@@@@@@@@@@@@

l.est = aggregate(l,by=list(l$V1),mean)
l.lims = aggregate(l,by=list(l$V1),quantile, prob=c(0.025,0.975))

#for later if something interesting comes up


