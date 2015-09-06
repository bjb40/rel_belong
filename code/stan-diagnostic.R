#@@@@@
#Temporary Script for Stan Diagnostics
#@@@@@

#load chains (note diagnostic and samples seem to load the same)
#chain.1 = read.csv(paste0(outdir,'stand-diagnostic.txt1'),skip=26)
#chain.2 = read.csv(paste0(outdir,'stand-diagnostic.txt2'),skip=26)
#chain.3 = read.csv(paste0(outdir,'stand-diagnostic.txt3'),skip=26)

#native diagnostic tools

print(get_elapsed_time(fit))
print(get_adaptation_info(fit))
aparms = get_sampler_params(fit)
for(col in 1:5){
  for(c in 1:3){
    print(paste(colnames(aparms[[c]])[col],mean(aparms[[c]][,col])))
  }
}

plot(aparms[[1]][,'accept_stat__'], type='l')
lines(aparms[[2]][,'accept_stat__'], type='l', lty=2)
lines(aparms[[2]][,'accept_stat__'], type='l', lty=3)
