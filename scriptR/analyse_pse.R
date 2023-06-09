library(tidyverse)
library(ggforce)
library(plotly)
rm(list = ls())


setwd("~/github/real-tree-model/data/")
pse.df <- read.csv("results_pse/population33200.csv", header = T)

sel <- pse.df$evolution.samples > 4


ggplot()+
  geom_point(data = pse.df[sel,], aes(x = objective.om_stockMil, y = objective.om_charette, 
                 size = evolution.samples, colour =  nbProTGMax))+
  geom_rect(data=mtcars[1,], aes(xmin=51200, xmax=52300, ymin=24,ymax=28), colour = "#252525",fill="#d9d9d9", alpha=0.1)+
  geom_rect(data=mtcars[1,], aes(xmin=41800, xmax=43000, ymin=41.5,ymax=45), colour = "#252525",fill="#d9d9d9", alpha=0.1)+
  annotate( "text", label = "1", x = 52500, y = 29, size = 8, colour = "#252525")+
  annotate( "text", label = "2", x = 43000, y = 47, size = 8, colour = "#252525")+
  labs(title = "Pattern Space Exploration",
       x = "Prod. de mil", 
       y = "Prod. bois de chauffe")+
  xlim(40000,55000)+
  ylim(0,50)+
  theme_bw()

ggsave("../img/om_pse.png", width = 8)
ggsave("../img/om_pse.svg", width = 8)

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

# columns_to_remove <- grep(".1", names(pse.df))
# pse.df <- pse.df[,-columns_to_remove]

# pse.df <- read.table(path_right, sep = ",",header = TRUE)
# pse.df$id <- seq.int(nrow(pse.df))
# 
# 
# 
# pse.df_selected <- pse.df %>% 
#   mutate(clean_deltaMil = str_replace_all(pse.df$objective.om_delatMil, "[\\[\\]]", "")) %>%
#   mutate(clean_om_trees = str_replace_all(pse.df$objective.om_trees, "[\\[\\]]", "")) %>%
#   mutate(clean_om_charette = str_replace_all(pse.df$om_charette, "[\\[\\]]", "")) %>%
#   mutate(clean_caughhtC = str_replace_all(pse.df$om_caughtCutter, "[\\[\\]]", "")) %>%
#   select(-objective.om_delatMil, -objective.om_trees, -om_charette,-om_caughtCutter) %>% 
#   separate_rows(c(clean_deltaMil,clean_om_trees,clean_om_charette,clean_caughhtC), sep = ',', convert = TRUE ) %>%  
#   group_by(id) %>%
#   mutate(step=row_number()) %>%
#   gather(param,value,clean_deltaMil,clean_om_trees,clean_om_charette,clean_caughhtC) %>%
#   mutate(exp="right")

ggplot(data = pse.df[sel,])+
  geom_point(aes(x = objective.om_stockMil/10, y = objective.om_charette, size = evolution.samples ), colour = "#bdbdbd")+
  labs(title = "Pattern Space Exploration",
       subtitle = "viability threshold",
       x = "Prod. de mil", 
       y = "Prod. bois de chauffe")+
  geom_hline(yintercept=56)+   # 12 charette pour 20 personnes -> 56 pour 94
  geom_vline(xintercept=5400)+ # 600 kg pour une famille de 10 -> 5460 kg pour 94 
  theme_bw()
ggsave("../img/om_pse_base.svg", width = 8)

## dans netlogo show length remove-duplicates [id-parcelle] of patches with [culture = "mil"]
## 66 donc 66 parcelles arachide
## robert dit 4 parcelle pour une famille de 10 --> donc 66 parcelles pour une population de 165 personnes 
## 600 kg mini  de mil par ans pour 10 -> 60 kg par personnes et par ans 
## 

pse.df_selected <- pse.df_selected[,-c(1:28)]
