import { h } from 'preact';
import { Router } from 'preact-router';
import { createMemoryHistory } from 'history'; //createHashHistory
import Header from './header';
import Redirect from './Redirect';

// Code-splitting is automated for `routes` directory
import Home from '../routes/home';
import Profile from '../routes/profile';

const App = () => {
  return(
    <div id="app">
      <Header />
      <Router history={createMemoryHistory()}>
	<Home path="/" />
        <Profile path="/profile/" user="me" />
	<Profile path="/profile/:user" />
        <Redirect path="/login" to="http://localhost:3000" />
      </Router>
    </div>
  );
};
export default App;
