//import { h } from 'preact';
import style from './style.css';
import MultiSelectSort from 'async!../../components/MultiSelectSort';
import UserCookies from '../../components/UserCookies';


const Home = () => (
	<div class={style.home}>
		<h1>Home</h1>
		<p>This is the Home component.</p>
                <div style="max-width:50%;"><MultiSelectSort /></div>
                <UserCookies />
	</div>
);

export default Home;
