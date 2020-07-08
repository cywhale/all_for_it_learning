'use strict';
import { useState, useCallback } from 'https://unpkg.com/preact@latest/hooks/dist/hooks.module.js?module'; //useEffect, 
import { html } from './app_class.js';

function useCounter(initx=0) {
    const [value, setCount] = useState(initx);
    const incr = () => { //useCallback(() => {
      setCount(value + 1);
    }; //, [value]);
    return { value, incr };
}

function xCounter(initx=0) {
    const { value, incr } = useCounter(initx);
    return html`
      <div>
        xCount: ${value}
        <button onClick=${incr}>+1</button>
      </div>
    `
}

export const Counter = xCounter;