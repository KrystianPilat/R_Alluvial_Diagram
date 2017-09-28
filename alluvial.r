library(alluvial)
library(dplyr)

mydata=read.csv("Skills_data4.csv")
tit <- as.data.frame(mydata, stringsAsFactors = FALSE)
head(tit)

pal <- colorRampPalette(c("blue", "red", "green", "yellow", "black"))( 60) 
 
tit %>%
    mutate(
        ss = paste(Employer,Team,MajorProject,Responsibilities,Skills,SkillsAllocation,Time,Year2),
        k = pal[ match(ss, sort(unique(ss))) ]
    ) -> tit

alluvial(tit[,c(1:6)], freq=tit$Time,
         hide = tit$Time == 0,
         col = tit$k,
         border = tit$k
)
#export plot with 3000 / 1500
#trzeba dodać tytół i czytelność do tych zestawień, nauczyć się GITA
#wrzucić na githuba
#git na dropboxie
#dupalupa

