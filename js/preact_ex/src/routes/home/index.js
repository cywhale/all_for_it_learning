//import { createRef } from 'preact'; // h, Component, render
import UserHandler from '../../components/UserHandler';
import LayerModal from '../../components/LayerModal';
//import SortableSelect from '../../components/LayerModal/SortableSelect';
import style from './style';

//export default class Home extends Component {
const Home = () => {
//  const ref = createRef();
//  render() {
    return (
      <div class={style.home}>
        <UserHandler />
        <LayerModal />
      </div>
    );
//}
};
export default Home;
