import Viewer from 'cesium/Source/Widgets/Viewer/Viewer';
import SceneMode from 'cesium/Source/Scene/SceneMode';
import WebMercatorProjection from 'cesium/Source/Core/WebMercatorProjection';
import { render, Fragment } from 'preact';
import { useState, useEffect, useCallback } from 'preact/hooks';
//import Wind3D from '../Wind3D';
import Windgl from 'async!../Windgl';
import BasemapPicker from 'async!./BasemapPicker';
import Layer from 'async!../Layer';
import style from './style';
import 'cesium/Source/Widgets/widgets.css';

const Earth = (props, ref) => {
  const [userScene, setUserScene] = useState({ baseLayer: "" });
  const [globe, setGlobe] = useState({
    loaded: false,
    baseLoaded: false,
    viewer: null
  });
  const [basePick, setBasePick] = useState({ name: "" });
  const [model3d, setModel3d] = useState({
  //wind: null,
    initScene3D: false,
  });
/* It works for Wind3D, commited by git 15b8dc8 HEAD@{0}: commit: a Wind-3D submodule added on preactjs
  const handleWind3D = async () => {
    const {scene} = globe.viewer;
    //const {context} = scene;
    //https://stackoverflow.com/questions/29263166/how-to-get-scene-change-events-in-cesium
    await scene.morphStart.addEventListener(function(ignore, previousMode, newMode) {
      if (model3d.initScene3D && newMode !== SceneMode.SCENE3D) {
        model3d.wind.scene.primitives.show = false;
        model3d.wind.scene.primitives.removeAll();
        model3d.wind.scene.preRender._listeners = [];
        //Object.keys(model3d.wind).forEach(function(key) { delete model3d.wind[key]; });
        setModel3d((preMdl) => ({
          ...preMdl,
          wind: null
        }));
      }
    });

    await scene.morphComplete.addEventListener(function(ignore, previousMode, newMode) {
      if (model3d.initScene3D && typeof model3d.wind !== "undefined" && model3d.wind !== null &&
          newMode === SceneMode.SCENE3D) {
        setModel3d((preMdl) => ({
          ...preMdl,
          wind: new Wind3D(globe.viewer)
        }));
      }
    });
  }

  const initModel3D = useCallback(async() => {
    if (globe.loaded) {
      if (!model3d.initScene3D) {
        await setModel3d((preMdl) => ({
          ...preMdl,
          wind: new Wind3D(globe.viewer),
          initScene3D: true,
        }));

      } else {
        await handleWind3D();
      }
    }
  },[globe.loaded, model3d.initScene3D]);
*/
  useEffect(() => {
    if (!globe.loaded) {
      console.log('Initialize Viewer after appstate'); // + appstate);
      setUserScene({ baseLayer: "NOAA ETOPO\u00a0I" });
      initGlobe();
    } else {
      render(render_basemap(), document.getElementById('rightarea'))
      //var wind3D = new Wind3D(globe.viewer);
      //initModel3D();
    }
  }, [globe.loaded]); //, initModel3D

  const initGlobe = () => {
    setGlobe({
      loaded: true,
      viewer: new Viewer(ref.current, {
        timeline: true,
        animation: true,
        geocoder: true,
        baseLayerPicker: false,
        imageryProvider: false,
        mapProjection : new WebMercatorProjection,
      }),
    });
  };

  const render_basemap = () => {
    if (globe.loaded) {
      const {scene} = globe.viewer;
      setGlobe((preState) => ({
        ...preState,
        baseLoaded: true,
      }));

      return (
        <BasemapPicker scene={scene} basePick={basePick} onchangeBase={setBasePick}/>
      );
    }
    return null;
  };

  const render_windgl = () => {
    if (globe.loaded & globe.baseLoaded) {
      return (
        <Windgl viewer={globe.viewer} />
      );
    }
    return null;
  };

  const render_layer = () => {
    if (globe.loaded & globe.baseLoaded) {
      return (
        <Layer viewer={globe.viewer} baseName={basePick.name} userBase={userScene.baseLayer}/>
      );
    }
    return null;
  };

  return (
    <Fragment>
      <div id="cesiumContainer"
          ref = {ref}
          class={style.fullSize} />
      <div id="toolbar" class={style.toolbar} />
      { render_windgl() }
      { render_layer() }
    </Fragment>
  );
};
export default Earth;
