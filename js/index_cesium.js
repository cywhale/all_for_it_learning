import { ionConfig } from './.setting.js';
Cesium.Ion.defaultAccessToken = ionConfig.token;
const evlay01url = 'https://neo.sci.gsfc.nasa.gov/servlet/RenderData?si=1787328&cs=rgb&format=PNG&width=3600&height=1800';

var showBase = true;
var showImg = true;
var showData= false;
var coarCoast = null;
var fineCoast = null;
var imageryViewModels = [];

imageryViewModels.push(new Cesium.ProviderViewModel({
    name : 'Natural Earth\u00a0II',
    iconUrl : Cesium.buildModuleUrl('Widgets/Images/ImageryProviders/naturalEarthII.png'),
    tooltip : 'Natural Earth II, darkened for contrast.\nhttp://www.naturalearthdata.com/',
    creationFunction : function() {
        return new Cesium.TileMapServiceImageryProvider({
            url : Cesium.buildModuleUrl('Assets/Textures/NaturalEarthII')
        });
    }
}));

imageryViewModels.push(new Cesium.ProviderViewModel({
    name : 'Open\u00adStreet\u00adMap',
    iconUrl : Cesium.buildModuleUrl('Widgets/Images/ImageryProviders/openStreetMap.png'),
    tooltip : 'OpenStreetMap (OSM) is a collaborative project to create a free editable map of the world.\nhttp://www.openstreetmap.org',
    creationFunction : function() {
        return new Cesium.OpenStreetMapImageryProvider({
            url : 'https://a.tile.openstreetmap.org/'
        });
    }
}));

const terrainModels = Cesium.createDefaultTerrainProviderViewModels();
  /*
   imageryViewModels.push(new Cesium.ProviderViewModel({
       name : 'Earth at Night',
       iconUrl : Cesium.buildModuleUrl('Widgets/Images/ImageryProviders/blackMarble.png'),
       tooltip : 'The lights of cities and villages trace the outlines of civilization \
  in this global view of the Earth at night as seen by NASA/NOAA\'s Suomi NPP satellite.',
       creationFunction : function() {
           return new Cesium.IonImageryProvider({ assetId: 3812 });
       }
   }));
  */
  //Create a CesiumWidget without imagery, if you haven't already done so.
var viewer = new Cesium.Viewer('cesiumContainer',{
  //  imageryProvider: sTileImg,
      //Start in Columbus Viewer
      //sceneMode : Cesium.SceneMode.COLUMBUS_VIEW,
      //baseLayerPicker : false,
      //imageryProvider : new Cesium.OpenStreetMapImageryProvider({
      //    url : 'https://a.tile.openstreetmap.org/'
      //}),
      /*
      skyBox : new Cesium.SkyBox({
          sources : {
            positiveX : 'stars/TychoSkymapII.t3_08192x04096_80_px.jpg',
            negativeX : 'stars/TychoSkymapII.t3_08192x04096_80_mx.jpg',
            positiveY : 'stars/TychoSkymapII.t3_08192x04096_80_py.jpg',
            negativeY : 'stars/TychoSkymapII.t3_08192x04096_80_my.jpg',
            positiveZ : 'stars/TychoSkymapII.t3_08192x04096_80_pz.jpg',
            negativeZ : 'stars/TychoSkymapII.t3_08192x04096_80_mz.jpg'
          }
      }),
      */
    timeline: true,
    animation: true,
    geocoder: true,
    baseLayerPicker: false, //baseLayerPicker,
    imageryProvider: false,
    mapProjection : new Cesium.WebMercatorProjection(),
    //terrainProvider: baseLayer //Cesium.createWorldTerrain()
});

  /*
    const tms = new Cesium.UrlTemplateImageryProvider({
        url : 'https://gis.ngdc.noaa.gov/arcgis/rest/services/web_mercator/etopo1_hillshade/MapServer/tile/{z}/{y}/{x}?blankTile=True',
        credit : '© NOAA etopo1 hillshade',
        tilingScheme : new Cesium.GeographicTilingScheme()
        //maximumLevel : 5
      });
    //tms.alpha = 0.7;
    //viewer.imageryLayers.addImageryProvider(tms);
  */
//var cesiumWidget = new Cesium.CesiumWidget('cesiumContainer', { imageryProvider: false });
const layers = viewer.imageryLayers; //cesiumWidget
const baseLayerPicker = new Cesium.BaseLayerPicker('baseLayerPickerContainer', {
    globe : viewer.scene.globe, //cesiumWidget
    imageryProviderViewModels: imageryViewModels,
    terrainProviderViewModels: terrainModels,
});

var baseLayer = layers.get(0);
const updateBasemap = () => {
  baseLayer = layers.get(0);
  if (!showBase) { //&& layers._layers[0] === baseLayer) {
    baseLayer.show = false;
    //layers.remove(baseLayer, false);
  }
  if (showBase) { // && layers._layers[0] !== baseLayer) {
    //layers._layers.splice(0, 1, baseLayer);
    baseLayer.show = true;
  }
}
//baseLayer.colorToAlpha = new Cesium.Color(0.0, 0.016, 0.059);
//baseLayer.colorToAlphaThreshold = 0.2;

const loadCoastline = () => {
  const dataSourcePromise = viewer.dataSources.add(
          //new Cesium.GeoJsonDataSource.load(dataurl, {
          Cesium.IonResource.fromAssetId(200042).then(function (resource) { //20032 Geojson
          //return Cesium.GeoJsonDataSource.load(resource, {
            return Cesium.KmlDataSource.load(resource, {
// for kml
              camera: viewer.scene.camera,
              canvas: viewer.scene.canvas,
// for Geojson
              //crsNames: 'EPSG:4326',
              //clampToGround: true,
              //stroke: Cesium.Color.WHITE,
              //strokeWidth: 2
            });
          })
    );
  return(dataSourcePromise);
}

const toggleBase = document.getElementById("togglebasex");

const toggleBaseFun = (evt) => {
  if (showBase) { //&& !baselayer.isDestroyed()
//  if (layers._layers[0] === baseLayer) {
    baseLayer.show = false;
//  layers.remove(baseLayer, false);
//  }
    viewer.scene.globe.baseColor = Cesium.Color.BLACK;
    if (coarCoast === null) {
      loadCoastline()
        .then(data => {
// for kml
          let entities = data.entities.values;
/* not work
          for (let i =0; i < entities.length; i++) {
            entities[i].polyline.material.color.setColor(new Cesium.Color.WHITE.withAlpha(0.2)); //wall.outlineColor
          }
*/
          viewer.dataSources.add(data);
          coarCoast = data;
        })
        .otherwise(err => console.log("Fetching coarse coastline got load err: ", err));
    } else if (!viewer.dataSources.contains(coarCoast)) {
      viewer.dataSources.add(coarCoast);
      coarCoast.show = true;
    } else {
      coarCoast.show = true;
    }
  } else {
    if (coarCoast && coarCoast.show) { coarCoast.show = false; }
    //if (layers._layers[0] !== baseLayer) {
    //layers._layers.splice(0, 1, baseLayer);
    baseLayer.show = true;
    //}
  }
  showBase = !showBase;
};

toggleBase.addEventListener("click", toggleBaseFun.bind(null), false); //null, baseLayer

const viewModel = baseLayerPicker.viewModel;//.selectedImagery
const bindSelImagery = () => {
  Cesium.knockout
    .getObservable(viewModel, 'selectedImagery') //baseLayerPicker.viewModel
    .subscribe(function() {
      //if (baseLayer !== viewModel.selectedImagery) { //.name;
      //layers.remove(baseLayer, true);
      //baseLayer = viewModel.selectedImagery;
      updateBasemap();
    });
}
const bindSelTerrain = () => {
  Cesium.knockout
    .getObservable(viewModel, 'selectedTerrain') //baseLayerPicker.viewModel
    .subscribe(function() {
      //if (baseLayer !== viewModel.selectedTerrain) { //.name;
      //  layers.remove(baseLayer, true);
      //  baseLayer = viewModel.selectedTerrain;
      updateBasemap();
    });
}

bindSelImagery();
bindSelTerrain();

var sTileImg;
//var simgIdx = -1;
const showImgLayer = () => {
  sTileImg = layers.addImageryProvider(
    new Cesium.SingleTileImageryProvider({
        url: evlay01url,
        //rectangle: new Cesium.Rectangle(bnds[0], bnds[1], bnds[2], bnds[3]),
        rectangle: Cesium.Rectangle.fromDegrees(-180.0, -90.0, 180.0, 90.0),
        //numberOfLevelZeroTilesX: 1,
        //numberOfLevelZeroTilesY: 1,
        //alpha: 0.5,
    //  parameters: {transparent : 'true',
    //               format : 'image/png'
    //              },
        proxy : new Cesium.DefaultProxy('/proxy/') //https://github.com/CesiumGS/EarthKAMExplorer/blob/master/server/server.js
    })
  );
  //sTileImg.colorToAlpha = new Cesium.Color(0.0, 0.0, 0.0, 1.0);
  //sTileImg.colorToAlphaThreshold = 0.1;
  sTileImg.alpha = 0.5
}
//init
if (showImg) {
  showImgLayer();
  //simgIdx = layers.indexOf(sTileImg);
}
const toggleImg = document.getElementById("togglesimgx");

const toggleImgFun = (imglayer, evt) => {
  if (showImg) {
    imglayer.show = false;
  } else {
    imglayer.show = true;
  }
  showImg = !showImg;
};

toggleImg.addEventListener("click", toggleImgFun.bind(null, sTileImg), false);

var dataLayer = null;
const showDataLayer = () => {
  const wsurl = 'https://ecodata.odb.ntu.edu.tw/pub/icon/windpower_blue01s.png';
  const siteurl = 'https://odbwms.oc.ntu.edu.tw/odbintl/rasters/getcplan/?name=bio_r0043'
  const sitecrs = 'EPSG:4326' 
  const dataSourcePromise = viewer.dataSources.add(
    Cesium.GeoJsonDataSource.load(siteurl, {
        crsNames: sitecrs,
        clampToGround: true,
        //verticalOrigin : Cesium.VerticalOrigin.BOTTOM
        //stroke: Cesium.Color.fromBytes(127, 127, 127, 10),
        //markerColor: Cesium.Color.fromHsl(0, 0, 0, 0.01) //https://github.com/CesiumGS/cesium/issues/6307
    })
  );

  dataSourcePromise.then(function (dataSource) {
    const pixelRange = 15;
    const minimumClusterSize = 3;
    const enabled = true;

    dataSource.clustering.enabled = enabled;
    dataSource.clustering.pixelRange = pixelRange;
    dataSource.clustering.minimumClusterSize = minimumClusterSize;

    const entities = dataSource.entities.values;
    let entity;
    entities.forEach(entity => {
      entity.billboard.image = wsurl; //https://groups.google.com/forum/#!topic/cesium-dev/Nc0EO5IUN4o
    });

    var removeListener;

    const pinBuilder = new Cesium.PinBuilder();
    const pin50 = pinBuilder
      .fromText("50+", Cesium.Color.RED, 48)
      .toDataURL();
    const pin40 = pinBuilder
      .fromText("40+", Cesium.Color.ORANGE, 48)
      .toDataURL();
    const pin30 = pinBuilder
      .fromText("30+", Cesium.Color.YELLOW, 48)
      .toDataURL();
    const pin20 = pinBuilder
      .fromText("20+", Cesium.Color.GREEN, 48)
      .toDataURL();
    const pin10 = pinBuilder //Cesium.when(
      .fromText("10+", Cesium.Color.BLUE, 48)
      .toDataURL();

    let singleDigitPins = new Array(8);
    for (var i = 0; i < singleDigitPins.length; ++i) {
        singleDigitPins[i] = pinBuilder
            .fromText("" + (i + 2), Cesium.Color.VIOLET, 48)
            .toDataURL();
    }

    function customStyle() {
      if (Cesium.defined(removeListener)) {
        removeListener();
        removeListener = undefined;
      } else {
        removeListener = dataSource.clustering.clusterEvent.addEventListener(
          function (clusteredEntities, cluster) {
            cluster.label.show = false;
            cluster.billboard.show = true;
            cluster.billboard.id = cluster.label.id;
            cluster.billboard.verticalOrigin =
              Cesium.VerticalOrigin.BOTTOM;

            if (clusteredEntities.length >= 50) {
              cluster.billboard.image = pin50;
            } else if (clusteredEntities.length >= 40) {
              cluster.billboard.image = pin40;
            } else if (clusteredEntities.length >= 30) {
              cluster.billboard.image = pin30;
            } else if (clusteredEntities.length >= 20) {
              cluster.billboard.image = pin20;
            } else if (clusteredEntities.length >= 10) {
              cluster.billboard.image = pin10;
            } else {
              cluster.billboard.image =
                singleDigitPins[clusteredEntities.length - 2];
            }
          }
        );
      }

      // force a re-cluster with the new styling
      var pixelRange = dataSource.clustering.pixelRange;
      dataSource.clustering.pixelRange = 0;
      dataSource.clustering.pixelRange = pixelRange;
    }

    // start with custom style
    customStyle();

    const viewModel = {
      pixelRange: pixelRange,
      minimumClusterSize: minimumClusterSize,
      threshold: sTileImg.alpha, //colorToAlphaThreshold,
    };
    Cesium.knockout.track(viewModel);

    const toolbar = document.getElementById("toolbar");
    Cesium.knockout.applyBindings(viewModel, toolbar);

    function subscribeParameter(name) {
      Cesium.knockout
        .getObservable(viewModel, name)
        .subscribe(function (newValue) {
          dataSource.clustering[name] = newValue;
        });
    }

    subscribeParameter("pixelRange");
    subscribeParameter("minimumClusterSize");

    //https://sandcastle.cesium.com/?src=Imagery%20Color%20To%20Alpha.html
    Cesium.knockout
    .getObservable(viewModel, "threshold")
    .subscribe(function (newValue) {
      sTileImg.alpha = parseFloat( //colorToAlphaThreshold
        viewModel.threshold
      );
    });

    viewer.flyTo(dataSource, {
        offset: new Cesium.HeadingPitchRange(0, (-Math.PI / 2)+0.0000001, 8000000) //-Cesium.Math.PI_OVER_FOUR, 20000000)
    })
    dataLayer = dataSource
    //viewer.zoomTo(dataSource);
    //viewer.dataSources.remove(dataSource);
  });
};

//init
if (showData) {
  showDataLayer();
  //simgIdx = layers.indexOf(sTileImg);
}
const toggleData = document.getElementById("toggledatax");

const toggleDataFun = (evt) => {
  if (showData) {
    dataLayer.show = false;
  } else {
    if (dataLayer === null) {
      showDataLayer();
    } else {
      dataLayer.show = true;
    }
  }
  showData = !showData;
};

toggleData.addEventListener("click", toggleDataFun.bind(null), false);


