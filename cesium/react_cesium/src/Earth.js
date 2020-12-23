import { Viewer } from 'cesium';
//import Ion from "../node_modules/cesium/Source/Core/Ion";
import React, { Component } from 'react';
import MultiSelectSort from './MultiSelectSort';
import './Earth.css'
import '../node_modules/cesium/Build/Cesium/Widgets/widgets.css';
//const widgets_style = require('Widgets/widgets.css');

//Ion.defaultAccessToken='';
class Earth extends Component {
  state = {viewerLoaded : false}

  componentDidMount() {
      this.viewer = new Viewer(this.cesiumContainer, {
          animation : false,
          baseLayerPicker : false,
          fullscreenButton : false,
          geocoder : false,
          homeButton : false,
          infoBox : false,
          sceneModePicker : false,
          selectionIndicator : true,
          timeline : false,
          navigationHelpButton : false,
          scene3DOnly : true,
//          imageryProvider,
//          terrainProvider,
      });
  }

  componentWillUnmount() {
      if(this.viewer) {
          this.viewer.destroy();
      }
  }
  render() {
      const containerStyle = {
          width: '100%',
          height: '100%',
          top: 0,
          left: 0,
          bottom: 0,
          right: 0,
          position: 'fixed',
          display : "flex",
          alignItems : "stretch",
      };

      //const widgetStyle = {
      //    flexGrow : 2
      //}

      return (
        <div style={containerStyle}>
        <div id="cesiumContainer"
          ref={ element => this.cesiumContainer = element }
          className="fullSize">
        </div>
        <div id="toolbar" className="toolbar">
           <MultiSelectSort />
        </div>
        </div>
      );
  }
}
export default Earth;
