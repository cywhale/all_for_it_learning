import { useEffect, useRef } from 'preact/hooks'; //useCallback
import { render, Fragment } from 'preact';
//import Select, { components } from 'react-select';
//import { SortableContainer, SortableElement } from 'react-sortable-hoc';
import MultiSelectSort from 'async!./MultiSelectSort';
import style from './style';

const LayerModal = () => {
  const modalref = useRef(null);

  useEffect(() => {
    if (modalref.current) {
      render(<MultiSelectSort />, modalref.current);
    }
  }, [modalref])

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
              <div id="laymodal" class={style.ctrlcolumn} ref={modalref}>
              </div>
            </section>
          </div>
        </div>
      </div>
    </Fragment>
  )
};
export default LayerModal;
