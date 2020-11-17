import { createRef } from 'preact';
import { Router } from 'preact-router';
import Earth from 'async!./Earth';
import style from './style/style_app';
/** @jsx h */
const App = (props) => {
  const ref = createRef();
  return (
    <div id="app">
      <Router>
      <div path='/' class={style.home}>
        <div class={style.right_area} id="rightarea" />
        <Earth ref={ref} />
      </div>
      </Router>
    </div>
  );
}
export default App;
