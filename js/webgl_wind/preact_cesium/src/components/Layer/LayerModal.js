import { useEffect, useState, useRef } from 'preact/hooks';
import Color from 'cesium/Source/Core/Color.js';
import DefaultProxy from 'cesium/Source/Core/DefaultProxy';
import Rectangle from 'cesium/Source/Core/Rectangle';
//import ImageryLayer from 'cesium/Source/Scene/ImageryLayer';
//import ImageryLayerCollection from 'cesium/Source/Scene/ImageryLayerCollection';
import SingleTileImageryProvider from 'cesium/Source/Scene/SingleTileImageryProvider';
//import GridImageryProvider from 'cesium/Source/Scene/GridImageryProvider';
//import WebMapServiceImageryProvider from 'cesium/Source/Scene/WebMapServiceImageryProvider';
import TileCoordinatesImageryProvider from 'cesium/Source/Scene/TileCoordinatesImageryProvider';
import knockout from 'cesium/Source/ThirdParty/knockout.js';
import style from './style_layermodal';
import '../../style/style_layerctrl.scss';

const LayerModal = (props) => {
  const { viewer, baseName, userBase } = props;
  const { imageryLayers } = viewer;
  const layerctrlRef = useRef(null);

  const [viewModel, setModel] = useState({
    loaded: false,
    layers: [],
    sImg: [],
    selectedLayer: null,
    selbase: userBase,
    baselayer: imageryLayers.get(0),
    upLayer: null,
    downLayer: null,
    isSelectableLayer: function (layer) {
        return this.sImg.indexOf(layer.imageryProvider) >= 0;
    },
    raise: function (layer, index) {
        imageryLayers.raise(layer);
        viewModel.upLayer = layer;
        viewModel.downLayer = viewModel.layers[Math.max(0, index - 1)];
        updateLayerList(this.selbase, this.baselayer); // call from here will lost other states outside viewModel
        window.setTimeout(function () {
          viewModel.upLayer = viewModel.downLayer = null;
        }, 10);
    },
    lower: function (layer, index) {
        imageryLayers.lower(layer);
        viewModel.upLayer =
          viewModel.layers[
            Math.min(viewModel.layers.length - 1, index + 1)
          ];
        viewModel.downLayer = layer;
        updateLayerList(this.selbase, this.baselayer);
        window.setTimeout(function () {
          viewModel.upLayer = viewModel.downLayer = null;
        }, 10);
    },
    canRaise: function (index) {
        return index > 0;
    },
    canLower: function (index) {
        return index >= 0 && index < imageryLayers.length - 1;
    },
  });

  const updateBaseLayer = () => { //BaseLayer changed from BasemapPicker, so need update viewModel
    if (baseName!==null && baseName!=viewModel.selbase && viewModel.layers.length) {
      let vlay = viewModel.layers;
      let blay = imageryLayers.get(0);
      let bidx = vlay.indexOf(viewModel.baselayer);
      blay.name = baseName;
      //blay.show = vlay[bidx].show;
      //blay.alpha= vlay[bidx].alpha;
      vlay.splice(bidx, 1, blay);
      setModel((preMdl) => ({
        ...preMdl,
        selbase: baseName,
        baselayer: blay,
        layers: vlay,
      }));
    }
  };
  //if add a new layer...
  const add_gbloverlay = (url, name, alpha, show, rectangle) => {
    const lay = //new ImageryLayer(name, //imageryLayers.addImageryProvider(
      new SingleTileImageryProvider({
          url: url,
          rectangle: rectangle, //| Rectangle.fromDegrees(-180.0, -90.0, 180.0, 90.0),
          defaultAlpha: alpha | 0.5,
          proxy : new DefaultProxy('/proxy/')
      });
    //);
    lay.alpha= alpha| 0.5;
    lay.show = show | false;
    lay.name = name;

    let layt;
    let simg = viewModel.sImg;
    if (!simg.length) {
      layt = imageryLayers.addImageryProvider(lay);
      layt.name = name;
      layt.show = show | false;
      layt.alpha = alpha | 0.5;
      simg.push(lay);
      setModel((preMdl) => ({
        ...preMdl,
        sImg: simg,
        selectedLayer: lay
      }));
    } else {
      simg.push(lay);
      setModel((preMdl) => ({
        ...preMdl,
        sImg: simg,
      }));
    }
  }

  const addAdditionalLayerOption = (name, imageryProvider, alpha, show) => {
    const layer= imageryLayers.addImageryProvider(imageryProvider);
    layer.show = show | false;
    layer.alpha= alpha| 0.5;
    layer.name = name;
    knockout.track(layer, ["alpha", "show", "name"]);
  }

  useEffect(() => {
    if (!viewModel.loaded) {
      knockout.track(viewModel);
      knockout.applyBindings(viewModel, layerctrlRef.current);
      setupLayers();
      updateLayerList(viewModel.selbase, viewModel.baselayer);
      setModel((preMdl) => ({
        ...preMdl,
        ...bindSelLayer(),
        loaded: true,
      }));
    } else {
      updateBaseLayer();
    }
  }, [viewModel.loaded, baseName]);

  const updateLayerList = (selBase, baseLayer) => {
    const nlayers = imageryLayers.length;
    let vlay = viewModel.layers;
    let blay, bidx;
    if (!vlay.length) {
      blay = imageryLayers.get(0);
      blay.name = selBase;
      vlay.splice(0, vlay.length);
      for (var i = nlayers - 1; i >= 1; --i) {
        vlay.push(imageryLayers.get(i));
      }
      vlay.push(blay);
    } else {
      bidx = imageryLayers.indexOf(baseLayer);
      vlay.splice(0, vlay.length);
      for (var i = nlayers - 1; i >= 0; --i) {
        blay = imageryLayers.get(i);
        if (i===bidx) { blay.name = selBase }
        vlay.push(blay);
      }
    }
    setModel((preMdl) => ({
        ...preMdl,
        layers: vlay,
    }));
  }

  const bindSelLayer = () => {
      knockout
        .getObservable(viewModel, "selectedLayer")
        .subscribe(function (selLayer) {
          let activeLayerIndex = 0;
          let nlayers = viewModel.layers.length;
          for (var i = 0; i < nlayers; ++i) {
            if (viewModel.isSelectableLayer(viewModel.layers[i])) {
              activeLayerIndex = i;
              break;
            }
          }
          const activeLayer = viewModel.layers[activeLayerIndex];
          const show = activeLayer.show;
          const alpha = activeLayer.alpha;

          const selidx = viewModel.sImg.indexOf(selLayer); // === 0;
          activeLayer.show = false;
          activeLayer.alpha = 0;
          imageryLayers.remove(activeLayer, false);
          let nowLayer;
          //if (selLayer.constructor.name === "SingleTileImageryProvider") {
            nowLayer = imageryLayers.addImageryProvider(selLayer, nlayers - activeLayerIndex - 1);
          //} else {
          //  imageryLayers.add(selLayer, nlayers - activeLayerIndex - 1);
            nowLayer = imageryLayers.get(activeLayerIndex);
          //}
          nowLayer.show = show;
          nowLayer.alpha = alpha;
          nowLayer.name = selLayer.name;

          updateLayerList(viewModel.selbase, viewModel.baselayer);
          return ({ selectedLayer: nowLayer, });
        });
  };

  const setupLayers = () => {
    const grect = Rectangle.fromDegrees(-180.0, -90.0, 180.0, 90.0);
    add_gbloverlay('https://neo.sci.gsfc.nasa.gov/servlet/RenderData?si=1799657&cs=rgb&format=JPEG&width=3600&height=1800',
                   'NASA_false_color', 0.5, false, grect);

    add_gbloverlay('https://neo.sci.gsfc.nasa.gov/servlet/RenderData?si=1787328&cs=rgb&format=PNG&width=3600&height=1800',
                   'NASA_NEO_Chla_origin', 0.5, false, grect);

    addAdditionalLayerOption(
      "Tile Coordinates",
      new TileCoordinatesImageryProvider(),
      1.0, false
    );
  }

  return (
    <div id="layerctrl" ref={layerctrlRef}>
      <table class={style.thinx}>
        <tbody data-bind="foreach: layers">
          <tr data-bind="css: { up: $parent.upLayer === $data, down: $parent.downLayer === $data }">
            <td class={style.smalltd}><input class={style.laychkbox} type="checkbox" data-bind="checked: show" /></td>
            <td class={style.smalltd}>
              <span data-bind="text: name, visible: !$parent.isSelectableLayer($data)"></span>
              <select class={style.simgsel} data-bind="visible: $parent.isSelectableLayer($data), options: $parent.sImg, optionsText: 'name', value: $parent.selectedLayer"></select>
            </td>
            <td class={style.mediumtd}><span class="ctrlrange-wrap2">
              <input type="range" class="range" style="height:20px;" min="0" max="1" step="0.01" data-bind="value: alpha, valueUpdate: 'input'" />
              <output class="bubble" style="font-size:9px;position:relative;top:-6px;" /></span>
            </td>
            <td class={style.smalltd}>
              <button type="button" class={style.modalbutton} data-bind="click: function() { $parent.raise($data, $index()); }, visible: $parent.canRaise($index())">
                ▲
              </button>
            </td>
            <td class={style.smalltd}>
              <button type="button" class={style.modalbutton} data-bind="click: function() { $parent.lower($data, $index()); }, visible: $parent.canLower($index())">
                ▼
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  )
}
export default LayerModal;
