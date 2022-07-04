library(ggplot2)

setwd("~/Téléchargements/results_nsga2(1)/results_nsga2/")

## Openfiles 
l.file <- list.files(path = ".")

data.df <- data.frame()
for(i in l.file){
  tps <- read.csv(i, header = T)
  data.df <- rbind(data.df, tps)
}

## les deux objectif sont maximisé 
data.df$objective.om_stockMil <- data.df$objective.om_stockMil * -1
data.df$objective.om_trees <- data.df$objective.om_trees * -1 

ggplot(data = data.df)+
  geom_point(aes(x = objective.om_trees, y = objective.om_stockMil, colour = evolution.generation))+
  labs(x = "nombre d'arbres", y = "Stock de Mil", 
       title = "Evolution de l'optimum sur un double objectif", subtitle = "Algorithme NSGA2", 
       colour = "Génération NSGA2")+
  theme_bw()
  
             