setwd("/home/adam/Dokumenty/DANE")

library(dplyr)
library(sf)
library(tmap)

dojazdy <- read.csv("macierz_przeplywow_ludnosci_zwiazanych_z_zatrudnieniem.csv", colClasses = c("Kod.gminy.zamieszkania.Gmina.of.residence...territorial.code"="character"))
gminy <- st_read("./00_jednostki_administracyjne/granice_jednostek_poprawione.gpkg")

gminy$JPT_KOD_JE <- gsub("_", "", gminy$JPT_KOD_JE)

municipality <- "Poznań"

names(dojazdy)[names(dojazdy) == "Dojeżdżający..Commuters."] <- "commuters"

dojazdy_select <- dojazdy %>%
  subset(Nazwa.gminy.pracy.Gmina.of.labour...name == municipality) %>% 
  group_by(Kod.gminy.zamieszkania.Gmina.of.residence...territorial.code) %>% 
  summarise(commuters <- sum(commuters))

dojazdy_select$Kod.gminy.zamieszkania.Gmina.of.residence...territorial.code <- as.character(dojazdy_select$Kod.gminy.zamieszkania.Gmina.of.residence...territorial.code)
by <- join_by(JPT_KOD_JE == Kod.gminy.zamieszkania.Gmina.of.residence...territorial.code)

commuter_map <- left_join(gminy, dojazdy_select, by)
commuter_map <- st_make_valid(commuter_map)


tmap_mode("view")
tm_shape(commuter_map) + tm_polygons(col = "commuters <- sum(commuters)", style = "jenks", palette = "viridis")
