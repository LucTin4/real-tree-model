library(tidyverse)
library(ggforce)
library(plotly)
rm(list = ls())


setwd("~/github/real-tree-model/data/")
pse.df <- read.csv("results_pse_sPop//population33200.csv", header = T)

sel <- pse.df$evolution.samples > 4


ggplot()+
  geom_point(data = pse.df[sel,], aes(x = objective.om_stockMil, y = objective.om_charette, 
                 size = evolution.samples, colour =  nbProTGMax))+
  geom_rect(data=mtcars[1,], aes(xmin=51200, xmax=52300, ymin=24,ymax=28), colour = "#252525",fill="#d9d9d9", alpha=0.1)+
  geom_rect(data=mtcars[1,], aes(xmin=41800, xmax=43000, ymin=41.5,ymax=45), colour = "#252525",fill="#d9d9d9", alpha=0.1)+
  annotate( "text", label = "1", x = 52500, y = 29, size = 8, colour = "#252525")+
  annotate( "text", label = "2", x = 43000, y = 47, size = 8, colour = "#252525")+
  labs(title = "Pattern Space Exploration",
       subtitle = "Community-based surveillance",
       x = "Millet prod.", 
       y = "Firewood prod.",
       colour="Nb of saplings\nprotected", 
       size="GA. samples")+
  xlim(40000,55000)+
  ylim(0,50)+
  theme_bw()

ggsave("../img/om_pse_sPop.png", width = 8)
ggsave("../img/om_pse_sPop.svg", width = 8)

## Test de ploty

fig <- plot_ly(pse.df[sel,], x = ~objective.om_stockMil, y = ~objective.om_charette,
               text = ~paste('TempChamps:', tpsAuChamp, 
                             '<br>probaDiscu.1:', probaDiscu,
                             '<br>fréquenceRéu',fréquenceRéu,
                             '<br>probaDenonce',probaDenonce,
                             '<br>nbProTGMax',nbProTGMax)
               , type = 'scatter', mode = 'markers',
               marker = list(size = ~evolution.samples*2, opacity = 0.5))
fig



## PSE sur la surveillance centralisé ###

pse_sr.df <- read.csv("results_pse_sReprez_mil_bois_obj3/population20000.csv", header = T)

sel <- pse_sr.df$evolution.samples > 4


ggplot()+
  geom_point(data = pse_sr.df[sel,], aes(x = objective.om_stockMil, y = objective.om_charette, 
                                      size = evolution.samples, colour =  nbProTGMax))+
  # geom_rect(data=mtcars[1,], aes(xmin=51200, xmax=52300, ymin=24,ymax=28), colour = "#252525",fill="#d9d9d9", alpha=0.1)+
  # geom_rect(data=mtcars[1,], aes(xmin=41800, xmax=43000, ymin=41.5,ymax=45), colour = "#252525",fill="#d9d9d9", alpha=0.1)+
  # annotate( "text", label = "1", x = 52500, y = 29, size = 8, colour = "#252525")+
  # annotate( "text", label = "2", x = 43000, y = 47, size = 8, colour = "#252525")+
  labs(title = "Pattern Space Exploration",
       subtitle = "Delegated surveillance",
       x = "Millet prod.", 
       y = "Firewood prod.",
       colour="Nb of saplings\nprotected", 
       size="GA. samples")+
  xlim(40000,55000)+
  ylim(0,50)+
  theme_bw()

ggsave("../img/om_pse_sReprez.png", width = 8)
ggsave("../img/om_pse_sReprez.svg", width = 8)




small.dfA <- subset(pse.df, select = c('objective.om_stockMil', 'objective.om_charette', 'evolution.samples', 'nbProTGMax'))
small.dfB <- subset(pse_sr.df, select = c('objective.om_stockMil', 'objective.om_charette', 'evolution.samples', 'nbProTGMax'))

combined_df <- bind_rows(
  small.dfA %>% mutate(surveillance = "community"),
  small.dfB %>% mutate(surveillance = "delegated")
)

combined_df <- combined_df[combined_df$evolution.samples > 4, ]



ggplot()+
  geom_point(data = combined_df, aes(x = objective.om_stockMil, y = objective.om_charette, 
                                         size = evolution.samples, colour =  nbProTGMax, shape = surveillance))+
  scale_colour_gradient(low = "blue", high = "red", name = "Nb ProTGMax") +
  # geom_rect(data=mtcars[1,], aes(xmin=51200, xmax=52300, ymin=24,ymax=28), colour = "#252525",fill="#d9d9d9", alpha=0.1)+
  # geom_rect(data=mtcars[1,], aes(xmin=41800, xmax=43000, ymin=41.5,ymax=45), colour = "#252525",fill="#d9d9d9", alpha=0.1)+
  # annotate( "text", label = "1", x = 52500, y = 29, size = 8, colour = "#252525")+
  # annotate( "text", label = "2", x = 43000, y = 47, size = 8, colour = "#252525")+
  labs(title = "Pattern Space Exploration",
       x = "Millet prod.", 
       y = "Firewood prod.",
       colour="Nb of saplings\nprotected", 
       size="GA. samples")+
  xlim(40000,55000)+
  ylim(0,50)+
  theme_bw()
ggsave("../img/om_pse_bothSurveillance.png")
