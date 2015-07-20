#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#Dev R 3.1.3 "Smooth Sidewalk"; x86_64-w64-mingw32/x64
#Script sets universal configuration and objects
#Bryce Bartlett
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


#@@
#options

#turn off sicentific notation for display
options(scipen=999, digits=3)

#@@
#Directories

#datasource
rawdir = "C:/Users/bjb40/Dropbox/Projecting Religious Belonging/1.Data/"
#parent directory
projdir = "H:/projects/rel_belong/"
#directory for output
outdir = "H:/projects/rel_belong/output/"

#@@
#Files and temp folders

#test for and create private~ output folder
if(file.exists(paste(outdir, "private~", sep=''))== F)
{dir.create(paste(outdir,"private~",sep=''))}

#test for and create draft_img~ folder
if(file.exists(paste(projdir,'draft_img~',sep=''))==F)
{dir.create(paste(projdir,'draft_img~',sep=''))}

finalimg = 'C:/Users/bjb40/Dropbox/Projecting Religious Belonging/7.Diagrams/'
draftimg = paste(projdir,'draft_img~',sep='')