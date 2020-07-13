import { h, Component } from 'preact';
import UserHandler from '../../components/UserHandler';
import style from './style';

export default class Home extends Component {
	render() {
		return (
			<div class={style.home}>
				<UserHandler />
			</div>
		);
	}
}
