#Korben Van Der Vendt
#clear working environment
rm(list = ls())

#installing packages 
library(rinat)
library(magrittr)
library(sf)
library(leaflet)
library(htmltools)
library(leaflet.extras)

#calling and inspecting data from iNaturalist
beetle_obs <- get_inat_obs(taxon_name = "Anthia decemguttata",
                           maxresults = 1000)
head(beetle_obs)
colnames(beetle_obs)

#filtering list by availability of location data 
beetle_obs <- subset(beetle_obs, !is.na(latitude))

#creating a list of GPS locations for study sites 
#the following line stores the original location data in Degrees, Minutes & Seconds
original_location_data <- c('32º 10,682’S 18º 18,858’E', '32º 16,598’S 18º 31,799’E', '32º 20,518’S 18º 59,491’E',
                            '32º 21,067’S 19º 00,417’E', '32º 24,471’S 19º 05,079’E', '32º 25,445’S 19º 09,970’E',
                            '32º 27,581’S 19º 14,459’E', '32º 26,100’S 19º 13,969’E', '32º 21,435’S 19º 08,753’E',
                            '32º 21,310’S 19º 08,938’E', '32º 21,305’S 19º 09,695’E', '32º 21,241’S 19º 10,018’E',
                            '32º 20,888’S 19º 10,213’E', '32º 20,340’S 19º 10,899’E', '32º 20,140’S 19º 11,623’E',
                            '32º 19,637’S 19º 12,086’E', '32º 16,674’S 19º 13,161’E')

#converting site locations into decimal degrees by manually typing in locations and converting 
#using formula degrees + (minutes/60) + (seconds/3600)
site_lat <- c(-32+(10/60)+(682/3600), -32+(16/60)+(598/3600), -32+(20/60)+(518/3600),
              -32+(21/60)+(067/3600), -32+(24/60)+(471/3600), -32+(25/60)+(445/3600),
              -32+(27/60)+(581/3600), -32+(26/60)+(100/3600), -32+(21/60)+(435/3600), 
              -32+(21/60)+(310/3600), -32+(21/60)+(305/3600), -32+(21/60)+(241/3600),
              -32+(20/60)+(888/3600), -32+(20/60)+(340/3600), -32+(20/60)+(140/3600), 
              -32+(19/60)+(637/3600), -32+(16/60)+(674/3600))

site_long <- c(18+(18/60)+(858/3600), 18+(31/60)+(799/3600), 18+(59/60)+(491/3600),
               19+(00/60)+(417/3600), 19+(05/60)+(079/3600), 19+(09/60)+(970/3600),
               19+(14/60)+(459/3600), 19+(13/60)+(969/3600), 19+(08/60)+(753/3600), 
               19+(08/60)+(938/3600), 19+(09/60)+(695/3600), 19+(10/60)+(018/3600),
               19+(10/60)+(213/3600), 19+(10/60)+(899/3600), 19+(11/60)+(623/3600), 
               19+(12/60)+(086/3600), 19+(13/60)+(161/3600))

#creating data frame for study sites locations 
site_locations <- data.frame( description= rep('Study site', 17), place_guess= rep('The Cederberg Mountaints', 17),
                              latitude= site_lat, longitude= site_long)

#cropping beetle observations for only description, place_guess, lat & long
beetles_sub <- subset(beetle_obs, select = c("description", "place_guess", 'latitude', 'longitude'))

#merging site locations with beetle observations into one data frame 
combined_data <-rbind(beetles_sub, site_locations)

#Adding point types 
combined_data$Point_type = ifelse(combined_data$description != 'Study site', 'Observation','plot')

#converting dataframe into a spatial object 
combined_data <- st_as_sf(combined_data, coords = c("longitude", "latitude"), crs = 4326)
class(combined_data)

#creating leaflet with different colours for different point types 

leaflet() %>%
  # Add default OpenStreetMap map tiles
  addTiles(urlTemplate = "https://tile.opentopomap.org/{z}/{x}/{y}.png") %>% 
  # Add our points
  addCircleMarkers(data = combined_data,
                   group = "Protea cynaroides",
                   radius = 3, 
                   color = ifelse(combined_data$Point_type == 'plot', "black", "red"))
