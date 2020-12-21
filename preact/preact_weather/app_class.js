'use strict';
// python -m SimpleHTTPServer 8010
// if need version htm@3.0.4 or from module //'https://unpkg.com/preact?module';
// import { html, Component, render } from 'https://unpkg.com/htm/preact/standalone.module.js';
import { h, Component, render } from 'https://unpkg.com/preact@latest?module';
import htm from "https://unpkg.com/htm@latest/dist/htm.module.js?module";
export const html = htm.bind(h);
// import { h, render } from 'preact'; 
// import { html, Component } from 'htm/preact';

import { Counter, ToDo } from './app_hooks.js';
import { WeatherApp } from './weather.js';

class App_class extends Component {
    constructor () {
      super();
      this.state = { loading: true, time: null, count: 0, value: '', name: 'user' };

      this.onInput = e => {
        this.setState({ value: e.target.value });
      }

      this.onSubmit = e => {
        e.preventDefault();
        this.setState({ name: this.state.value });
      }

      this.increment = () => {
        this.setState(prev => ({ count: prev.count +1 }));
      };
    }

    async componentDidMount () {
      try {
        //this.setState({ loading: true, time: null, value: '', name: 'user' })
        this.timer = setInterval(() => {
          this.setState({ loading: false, time: Date.now() });
        }, 1000);
      } catch(err) {
        console.log(err)
      }
    }

    componentWillUnmount() {
      clearInterval(this.timer);
    }

    render (props, state) {
      let xtime = new Date(this.state.time).toLocaleTimeString();
      return html`
      <div>
        <div>
          <h1>Hello, ${state.name}!</h1>
          <form onSubmit=${this.onSubmit}>
            <input type="text" value=${state.value} onInput=${this.onInput} />
            <button type="submit">Update</button>
          </form>
        </div>
        <div>
          ${ state.loading &&
            html`
              <p>😴 Loading time from server...</p>
            `
          }
          ${ state.time &&
            html`
              <p>Justa a trial...</p>
              <p>⏱ Update : <i>${xtime}</i></p>
              <hr />
              <div>
                Counter: ${state.count}
                <button onClick=${this.increment}>Increment</button>
              </div>
            `
          }
        </div>
        <hr />
      </div>
      `
      }
}
class Count_hook extends Component {
  render (props, state) {
    let countx = Counter(3);
    return countx;
  }  
}  

class Todo_hook extends Component {
  render (props, state) {
    return ToDo(); //html`${ToDo()}`;
  }  
}  

class weatherCard extends Component {
  componentDidMount () {
    let redox = this.base.querySelector('.Redo');
    console.log('After render: ' + redox.getAttribute('isLoading'));
  }
  getSnapshotBeforeUpdate() {
    let redox = this.base.querySelector('.Redo');
  //redox.setAttribute('isLoading', isLoading);
    console.log('Before render: ' + redox.getAttribute('isLoading'));
  }
  render (props, state) {
    return WeatherApp();
  }  
}  

render(html`<${App_class}/>`, document.getElementById('app'));
render(html`<${Count_hook}/>`, document.getElementById('app_hook'));
render(html`<${Todo_hook}/>`, //ToDo(), //
       document.getElementById('todo_hook'));
render(html`<${weatherCard}/>`, document.getElementById('weather_blk'));
