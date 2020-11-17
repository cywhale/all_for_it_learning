import { useRef, useEffect, useState, useCallback } from 'preact/hooks';
import WindGL from './WindGL.js';
import style from './style';
//import canvas2globe from './canvas2globe.js';
const { windConfig } = require('./.setting.js');

const Windgl = (props) => {
  const { viewer } = props;
  const windRef = useRef(null);
  const [wgl, setWgl] = useState({
    wind: null,
    data: null,
    img: null,
  });
  const [wglctrl, setWglctrl] = useState({
    loadfile: '2020111300',
    start: false,
    isLoading: true,
    //updateOnce: false,
  })
/*
  const updateRetina => (ratio) {
    //const ratio = meta['retina resolution'] ? pxRatio : 1;
    canvas.width = canvas.clientWidth * ratio;
    canvas.height = canvas.clientHeight * ratio;
    wind.resize();
  }*/
  const fetchWindData = (loadfile) => {
    fetch(windConfig.base + loadfile + '.json',
    ).then(response => response.json())
     .catch(err => console.error('Fetch Wind Json Error:', err))
     .then(data => {
        setWgl(preState => ({
          ...preState,
          data: data
        }));
        return(data);
     });
  };

  const fetchWindImg = (loadfile) => {
    fetch(windConfig.base + loadfile + '.png'
    ).then(response => response.blob())
     .catch(err => console.error('Fetch Wind Image Error:', err))
     .then(blob => new Promise((resolve, reject) => {
       const reader = new FileReader()
       reader.onloadend = () => resolve(reader.result)
       reader.onerror = reject
       reader.readAsDataURL(blob)
    })).then(dataImg => {
       setWgl(preState => ({
          ...preState,
          img: dataImg
       }));
       return(dataImg)
    });
  };

//https://stackoverflow.com/questions/31424561/wait-until-all-promises-complete-even-if-some-rejected
//https://stackoverflow.com/questions/30569182/promise-allsettled-in-babel-es6-implementation
//https://stackoverflow.com/questions/44050414/promise-all-for-objects-in-javascript
  const reflect = (promise) => {
    return Promise.resolve(promise)
    .then(
      val => ({ status: 'fulfilled', value: val }),
      err => ({ status: 'rejected', reason: error })
    );
  }

  const updateWind = useCallback((wind, loadfile) => {
    const fetchingData = async(wind, loadfile) => {
      const promises = [
          fetchWindData(loadfile),
          fetchWindImg(loadfile)
      ];
    //const results = await Promise.allSettled(promises); //Promise.allSettled is not a function
      const results = await Promise.all(promises.map(reflect));
    //const gotdata = results.filter(p => p.status === 'fulfilled');
      const failPromises = results.filter(p => p.status === 'rejected');
      if (failPromises && failPromises.length > 0) {
        alert("Error: Wind data fetch error:" + failPromises[0].reason);
      } else {
      /*await Promise.all([
            fetchWindData(loadfile),
            fetchWindImg(loadfile)
          ]).then(data => {
       */
        wind.setWind(wgl.data, wgl.img); //gotdata[0].value, gotdata[1].value);
        /*wind.draw();
        await setWgl(preState => ({
            ...preState,
            wind: wind
        }));

        await setWglctrl(preState => ({
            ...preState,
            start: true
        }));*/
      };//);

      await setWglctrl((preState) => ({
            ...preState,
            isLoading: false
      }));
    };

    setWglctrl((preState) => ({
          ...preState,
          isLoading: true
    }));

    fetchingData(wind, loadfile);
  }, []);

  const updateFrame = () => {
      /*if (wgl.wind.windData) {
        wgl.wind.draw();
      }*/
      requestAnimationFrame(updateFrame);
  }

  const initCanvas = useCallback((canvas) => {
    //const pxRatio = Math.max(Math.floor(window.devicePixelRatio) || 1, 2);
    canvas.width = parseInt(viewer.canvas.width) //canvas.clientWidth * pxRatio;
    canvas.height = parseInt(viewer.canvas.height) //canvas.clientHeight * pxRatio;
    const gl = canvas.getContext('webgl', {antialiasing: false, alpha: 0.7});
    let wind = new WindGL(gl);
    wind.numParticles = 65536;
    //updateFrame();

    wind.fadeOpacity = 0.996;
    wind.speedFactor = 0.25;
    wind.dropRate = 0.003;
    wind.dropRateBump = 0.01;

    setWgl(preState => ({
        ...preState,
        wind: wind
    }));

    setWglctrl(preState => ({
        ...preState,
        start: true
     }));
    /*const windFiles = { 0: '2020111300' };
    updateWind(wind, wglctrl.loadfile);*/
  },[]);

  useEffect(() => {
    if (windRef.current) {
      //const canvas = document.getElementById('wind');
      const canvas = viewer.canvas;

      if (!wglctrl.start) {
        initCanvas(canvas)
        console.log("Wgl canvas initialized");
      } else if (wglctrl.start) { //&& !wglctrl.updateOnce) {
        updateWind(wgl.wind, wglctrl.loadfile);
      } else if (!wglctrl.isLoading) {
        wgl.wind.draw();
        updateFrame();
/*
        setWglctrl((preState) => ({
          ...preState,
          updateOnce: true
        }));

        wgl.wind.numParticles = 65536;
        updateFrame();

        wgl.wind.fadeOpacity = 0.996;
        wgl.wind.speedFactor = 0.25;
        wgl.wind.dropRate = 0.003;
        wgl.wind.dropRateBump = 0.01;

        //const windFiles = { 0: '2020111300' };
        updateWind(wgl.wind, wglctrl.loadfile);
        */
        //console.log("Wgl data updated and state update: ", wglctrl.isLoading);
        //updateRetina();
/*
        viewer.camera.moveStart.addEventListener(function () {
          document.querySelector("#wind").style.display = 'none';
          //if (wglctrl.start) {
          //  windy.stop();
          //}
        });
        viewer.camera.moveEnd.addEventListener(function () {
          document.querySelector("#wind").style.display = 'block';
          //if (!!windy && started) {
          //  redraw();
          //}
        });
*/
      }
    }
  }, [windRef.current, wglctrl.start, wglctrl.isLoading])


  return(
    <canvas id="wind" class={style.windCanvas} ref={windRef}></canvas>
  );
};
export default Windgl;

