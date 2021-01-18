use test
show collections
#data
#layerprops
db.layerprops.insert([{ "value": "Himawari_AHI_Band13_Clean_Infrared", "label": "Himawari AHI Band13 Infrared", "type": "wmts", "format": "image/png", "resolution": "2km", "metagroup": "GIBS"},  { "value": "MODIS_Terra_CorrectedReflectance_TrueColor", "label": "MODIS Terra TrueColor","type": "wmts", "format": "image/jpg", "resolution": "250m", "metagroup": "GIBS"} ])
db.layerprops.insert([{ "value": "onshorewind", "label": "Onshore wind-power stations", "type": "sitecluster", "format": "geojson", metagroup:"taiwanwindfarm" },{ "value": "offshorewindpowerplan", "label": "Offshore wind-power plan", "type": "region", "format": "geojson", "metagroup": "taiwanwindfarm" },{ "value": "offshorewindpotential", "label": "Offshore wind-power potential", "type": "region", "format": "geojson", "metagroup": "taiwanwindfarm" }])
db.layerprops.insert([{ "label": "Demography", "children": [{ "value": "population909500", "label": "Population 1990-2000", "type": "cube", "format": "json" }], "value": "demography",   "metagroup": "socioeconomics" }])
db.layerprops.insert([{ "label": "Flows", "disabled": false, "children": [{ "label": "Windy","value": "gfs_", "format": "json", "type": "flows" }], "value": "flows", "metagroup":"GFS"}])

#metagroup
db.metagroup.insert( [{metagroup:"GIBS", layertype:"satellite", scope:"global", accessibility:"open",   keyword: ["GIS layers","地理圖資","遙測", "衛星圖層", "EOSDIS", "MODIS", "HIMAWARI", "WMTS", "WMS"],    datasource: "https://wiki.earthdata.nasa.gov/display/GIBS/",   citation: "NASA Global Imagery Browse Services (GIBS)",   layerprops: {pseudo_label: { "label": "-------- Satellite --------", "disabled": true, "value": "satellite"},           label: "Global Imagery Browse Services (GIBS)",           value: "GIBS"},   children:["Himawari_AHI_Band13_Clean_Infrared","MODIS_Terra_CorrectedReflectance_TrueColor"] }] )
db.metagroup.insert( [{metagroup:"taiwanwindfarm", layertype:"geojson", scope:"Taiwan", accessibility:"open",   keyword: ["GIS layers","地理圖資","Taiwan", "風力發電 風機", "綠色能源 再生能源", "wind power", "green energy", "renewable energy", "geojson"],    datasource: "https://pro.twtpo.org.tw/GIS/",   citation: "https://pro.twtpo.org.tw/GIS/",   layerprops: {pseudo_label: { "label": "-------- Socioeconomics --------", "disabled": true, "value": "socioeconomics"},           label: "Wind farm, Taiwan",           value: "taiwanwindfarm"},   children:["onshorewind","offshorewindpowerplan","offshorewindpotential"] }] )
db.metagroup.insert( [{metagroup:"GFS", layertype:"json", scope:"global", accessibility:"open",   keyword: ["GIS layers","地理圖資","Flow field", "流場", "NOAA", "NCEP", "Winds", "atomosphere", "風場"],    datasource: "https://www.ncdc.noaa.gov/data-access/model-data/model-datasets/global-forcast-system-gfs",   citation: "National Oceanic and Atmospheric Administration (NOAA)",   layerprops: {pseudo_label: { "label": "-------- Flows --------", "disabled": true, "value": "GFS"},           label: "Global Forecast System (GFS)",           value: "GFS"},   children:["flows"] }] )
db.metagroup.update({"_id": ObjectId("60010de2c7bdd7e886afe675")}, {$push: {keyword: "socioeconomics"}})

#index
#layerprops
db.layerprops.createIndex({"value":"text", "label":"text", "metagroup":"text"})

#metagroup
db.metagroup.getIndexes()
#db.metagroup.dropIndexes("value_text_label_text_keyword_text")
db.metagroup.createIndex({"value":"text", "label":"text", "keyword":"text", "scope":"text"})

#query
db.layerprops.find({$or:[{value: {$regex:"off shore", $options:"ix"}}, {label: {$regex:"off shore", $options:"ix"}}]})
db.layerprops.find({$text: { $search: "potential"}})

db.metagroup.find({$or:[{value: {$regex:"social", $options:"ix"}}, {label: {$regex:"social", $options:"ix"}}]})
db.metagroup.find({$text: { $search: "geojson"}})

#remove
db.metagroup.remove({"children": {$exists: false}})
