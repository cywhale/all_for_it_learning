import { h } from 'preact';
import { Router } from 'preact-router';
import { createMemoryHistory } from 'history'; //createHashHistory
import Header from './header';

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
      </Router>
    </div>
  );
};
export default App;
