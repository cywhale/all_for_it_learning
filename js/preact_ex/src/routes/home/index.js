//import { createRef } from 'preact'; // h, Component, render
import UserHandler from '../../components/UserHandler';
import UserCookies from '../../components/UserCookies';
//import SortableSelect from '../../components/LayerModal/SortableSelect';
import style from './style';

//export default class Home extends Component {
const Home = () => {
//  const ref = createRef();
//  render() {
    return (
      <div class={style.home}>
        <UserHandler />
        <UserCookies />
      </div>
    );
//}
};
export default Home;
