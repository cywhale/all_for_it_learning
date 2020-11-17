import { useRef, useState, useEffect, useMemo } from 'preact/hooks';
import BaseLayerPicker from 'cesium/Source/Widgets/BaseLayerPicker/BaseLayerPicker';
import createDefaultImageryProviderViewModels from 'cesium/Source/Widgets/BaseLayerPicker/createDefaultImageryProviderViewModels';
import createDefaultTerrainProviderViewModels from 'cesium/Source/Widgets/BaseLayerPicker/createDefaultTerrainProviderViewModels';
import buildModuleUrl from 'cesium/Source/Core/buildModuleUrl';
import UrlTemplateImageryProvider from 'cesium/Source/Scene/UrlTemplateImageryProvider';
import ProviderViewModel from 'cesium/Source/Widgets/BaseLayerPicker/ProviderViewModel';
import knockout from 'cesium/Source/ThirdParty/knockout.js';
//import 'cesium/Source/Widgets/widgets.css';
import style from './style_basemapPicker';

const BasemapPicker = (props) => {
  const {scene, basePick, onchangeBase} = props;
  const [basemap, setBasemap] = useState({
    picker: null,
    selectedImagery: null,
    selectedTerrain: null,
  });
  const [state, setState] = useState(false);
  const baseContainer = useRef(null);

  useEffect(() => {
    if (!state) {
      console.log('Initialize BasemapModels');
      initBasemap();
    } else {
      setBasemap((preState) => ({
        ...preState,
        selectedImagery: bindSelImagery(),
      }));
      setBasemap((preState) => ({
        ...preState,
        selectedTerrain: bindSelTerrain(),
      }));
    }
  }, [state]);

  const initBasemap = () => {
    //if (scene) { //Now globe.loaded detect in Earth
      const getImgModels = () => {
        const defModels = createDefaultImageryProviderViewModels();
        let imgModels = [];
        imgModels.push(new ProviderViewModel({
           name : 'NOAA ETOPO\u00a0I',
           iconUrl : buildModuleUrl('../../assets/etopo1_64x64.png'),
            tooltip : 'NOAA Etopo',
            category: "Other",
            creationFunction : function() {
              return new UrlTemplateImageryProvider({
                url : buildModuleUrl('https://gis.ngdc.noaa.gov/arcgis/rest/services/web_mercator/etopo1_hillshade/MapServer/tile/{z}/{y}/{x}?blankTile=True'),
                credit : '© NOAA etopo1 hillshade',
              });
            }
        }));
//https://github.com/CesiumGS/cesium/blob/1.74/Source/Widgets/BaseLayerPicker/createDefaultImageryProviderViewModels.js
//https://github.com/CesiumGS/cesium/issues/9211
//0 "Bing Maps Aerial","Bing Maps Aerial with Labels","Bing Maps Roads",
//3 "ESRI World Imagery", "ESRI World Street Map", "ESRI National Geographic",
//6 "Open\u00adStreet\u00adMap","Stamen Watercolor", "Stamen Toner",
//9 "Sentinel-2","Blue Marble","Earth at night", "Natural Earth\u00a0II",
        [6,8,9,10,11,12].map(i => imgModels.push(defModels[i]));
        return imgModels;
      };

      setBasemap((preState) => ({
        ...preState,
        picker: new BaseLayerPicker(baseContainer.current, {
          globe: scene.globe,
          imageryProviderViewModels: getImgModels(),
          terrainProviderViewModels: createDefaultTerrainProviderViewModels()
        })
      }));
      setState(true);
    //}
  };

  const bindSelImagery = () => {
    const {viewModel} = basemap.picker;
    knockout
      .getObservable(viewModel, 'selectedImagery')
      .subscribe(function() {
        const baseImg = viewModel.selectedImagery.name;
        if (baseImg !== basePick.name && baseImg !== basemap.selectedImagery) {
          onchangeBase({ name: baseImg });
        }
        return ({ selectedImagery: baseImg });
      });
  }

  const bindSelTerrain = () => {
    const {viewModel} = basemap.picker;
    knockout
      .getObservable(viewModel, 'selectedTerrain')
      .subscribe(function() {
        const baseTerrain = viewModel.selectedTerrain.name;
        if (baseTerrain !== basePick.name && baseTerrain !== basemap.selectedTerrain) {
          onchangeBase({ name: baseTerrain });
        }
        return ({ selectedTerrain: baseTerrain });
      });
  }

  return useMemo (() => {
    return(
      <div style="display:flex;">
        <div id="baseLayerPickerContainer" 
          ref = {baseContainer} 
          class={style.baseContainer} />
      </div>
    );
  }, [state]);
};
export default BasemapPicker;
