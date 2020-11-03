//import { createRef } from 'preact'; // h, Component, render
import MultiSelectSort from 'async!../../components/MultiSelectSort';
//import UserHandler from 'async!../../components/UserHandler';
import UserCookies from 'async!../../components/UserCookies';
import UserLogin from 'async!../../components/UserLogin';

//import SortableSelect from '../../components/LayerModal/SortableSelect';
import style from './style';

//export default class Home extends Component {
const Home = () => {
//  const ref = createRef();
//  render() { //<UserHandler /> //Use Firebase only
    return (
      <div class={style.home}>
        <div style="max-width:50%;"><MultiSelectSort /></div>
        <div><UserCookies /></div>
        <div><UserLogin /></div>
      </div>
    );
//}
};
export default Home;
