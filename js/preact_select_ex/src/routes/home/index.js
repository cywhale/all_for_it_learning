import { h } from 'preact';
import style from './style.css';
import MultiSelectSort from '../../components/MultiSelectSort';


const Home = () => (
	<div class={style.home}>
		<h1>Home</h1>
		<p>This is the Home component.</p>
                <div style="max-width:50%;"><MultiSelectSort /></div>
	</div>
);

export default Home;
