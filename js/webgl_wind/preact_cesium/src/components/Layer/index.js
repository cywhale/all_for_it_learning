import { Fragment } from 'preact';
import { useEffect } from 'preact/hooks';
import Color from 'cesium/Source/Core/Color.js';
import defined from 'cesium/Source/Core/defined.js';
import style from './style_modal';
import LayerModal from 'async!./LayerModal';
//import Datepicker from 'async!../Datepicker';

const Layer = (props) => {
  const {viewer, baseName, userBase} = props;

  const render_ImgLayer = () => {
    return(<LayerModal viewer={viewer} baseName={baseName} userBase={userBase} />);
  }

  useEffect(() => {
    console.log("Test basemaplayer name: ", baseName, " & ", userBase);
  }, []);

  return (
    <Fragment>
      <div class={style.toolToggle}>
         <a class={style.toolButn} href="#ctrl"><i></i></a>
      </div>
      <div id="ctrl" class={style.modalOverlay}>
        <div class={style.modalHeader} id="ctrlheader">
          Contrl clustering
          <a href="#" class={style.close}>&times;</a>
        </div>
        <div class={style.modal}>
          <div class={style.ctrlwrapper}>
            <section class={style.ctrlsect}>
              <div class={style.ctrlcolumn}>
                <div id="ctrlsectdiv1" />
                <div id="ctrlsectdiv2">
                  { render_ImgLayer() }
                </div>
              </div>
            </section>
          </div>
        </div>
      </div>
    </Fragment>
  );
};
export default Layer;
