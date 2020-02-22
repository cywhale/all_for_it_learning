# https://data.unep-wcmc.org/datasets/38
# Marine Ecoregions and Pelagic Provinces of the World (2007, 2012)
# Spalding MD, Fox HE, Allen GR, Davidson N, Ferdaña ZA, Finlayson M, Halpern BS, Jorge MA, Lombana A, Lourie SA, Martin KD, McManus E, Molnar J, Recchia CA, Robertson J (2007). Marine Ecoregions of the World: a bioregionalization of coast and shelf areas. BioScience 57: 573-583. doi: 10.1641/B570707. Data URL: http://data.unep-wcmc.org/datasets/38
# Spalding MD, Agostini VN, Rice J, Grant SM (2012). Pelagic provinces of the world): a biogeographic classification of the world’s surface pelagic waters. Ocean and Coastal Management 60: 19-30. DOI: 10.1016/j.ocecoaman.2011.12.016. Data URL: http://data.unep-wcmc.org/datasets/38
# js/html version: https://github.com/cywhale/all_for_it_learning/blob/master/js/js_leaflet_wms_meow.html

library(sf)
library(ggplot2)
library(rnaturalearth)
br <- st_read("D:/backup/env/MEOW_PPOW_2007_2012/01_Data/WCMC-036-MEOW-PPOW-2007-2012-NoCoast.shp") %>%
  st_as_sf(crs=4326)

ggplot(br) + geom_sf() +
  geom_sf(data = ne_coastline(scale = "large", returnclass = "sf"), color = 'darkgray', size = .3) +
  labs(x="Longitude",y="Latitude") +
  coord_sf() + 
  xlim(90, 140) + ylim(10, 40)
  

## try WMS
## https://gis.unep-wcmc.org/arcgis/rest/services/marine/WCMC_036_MEOW_PPOW_2007_2012/MapServer/
## Legend
## https://gis.unep-wcmc.org/arcgis/rest/services/marine/WCMC_036_MEOW_PPOW_2007_2012/MapServer/legend?f=json
library(leaflet)
library(leaflet.extras)

leaflet() %>%
  setView(118, 25, zoom = 5) %>%
  addTiles(
    "https://gis.unep-wcmc.org/arcgis/rest/services/marine/WCMC_036_MEOW_PPOW_2007_2012/MapServer/tile/{z}/{y}/{x}"
  ) 
  
leaflet() %>%
  setView(118, 25, zoom = 5) %>%
  addWMSTiles(
    "https://gis.unep-wcmc.org/arcgis/services/marine/WCMC_036_MEOW_PPOW_2007_2012/MapServer/WMSServer?",
    layers = 0, #"MEOW-PPOW-Combined2015",  #,Legend", 
    group = "WMS",
    options = WMSTileOptions(format = "image/png", transparent = TRUE),
    attribution = "Spalding MD, Fox HE, Allen GR, Davidson N, Ferdaña ZA, Finlayson M, Halpern BS, Jorge MA, Lombana A, Lourie SA, Martin KD, McManus E, Molnar J, Recchia CA, Robertson J (2007). Marine Ecoregions of the World: a bioregionalization of coast and shelf areas. BioScience 57: 573-583. URL: http://bioscience.oxfordjournals.org/content/57/7/573.abstract; http://data.unep-wcmc.org/"
  ) %>% 
  addLayersControl(baseGroups = c("WMS")) #, "Legend")) #overlayGroups = c("")


