library("dplyr")
library("ggplot2")

setwd("~/github/real-tree-model/")

df <- read.csv("data/M0-tree-model3-régénération eval_replication-table202206141229.csv", skip = 6)


# on va tirer 10 fois le même nombre de sample 
# créer des groupes dans un data frame
# et on plotera les boxplot correspondant par groupe

sample.v <- seq(from = 10, to = 100, by = 5) # vecteur du nombre de tirage

df.gp <- data.frame()
for(i in sample.v){
  for(j in 1:10){
    a <- df %>% slice_sample(n = i, replace = T)
    a$gp <- j
    df.gp <- rbind(df.gp, a)
  }
  ggplot(data = df.gp)+
    geom_boxplot(aes(x = as.factor(gp), y = coupeurs.attrapes))+
    labs(x  = "sample", title = paste("nombre de réplication:", i))
  ggsave(paste0("img/sample/sample",i,".png"))
}


