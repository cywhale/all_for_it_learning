'use strict';
import { useState } from 'https://unpkg.com/preact@latest/hooks/dist/hooks.module.js?module'; //useRef, useCallback, useEffect
import { html } from './app_class.js';
//import { useState } from 'preact/hooks'
//import { html } from 'htm/preact';

//export const hState = useState;

function useCounter(initx=0) {
    const [count, setCount] = useState(initx);
    const increment = () => { //useCallback(() => {
      setCount(count + 1);
    }; //, [value]);
    const decrement = () => setCount((curr) => curr - 1);
    return { count, increment, decrement };
}

function xCounter(initx=0) {
    const { count, increment } = useCounter(initx);
    return html`
      <div>
        xCount: ${count}
        <button onClick=${increment}>+1</button>
      </div>
    `
}

export const Counter = xCounter;

// modified code from https://bit.ly/3e9IQdx
export const ToDo = props => {
    const [listName, setListName] = useState('')
    const [todoList, setTodoList] = useState([{ key: 1, name: 'Default' }])
    const [time, setTime] = useState(new Date())

    const addTodo = () => { //useCallback(
        const newKey = todoList.length === 0 ? 1 : todoList[todoList.length - 1].key + 1
        setTodoList([...todoList, { key: newKey, name: listName }])
        setListName('')
    }; //, [todoList]);

    const removeTodo = (listKey) => { //useCallback(
        let foundIndex = todoList.findIndex((list) => {
            return list.key === listKey
        })
        todoList.splice(foundIndex, 1)
        setTodoList([...todoList])
    }; //,[todoList]);

    return html`
        <div>
            <input value=${listName} onChange=${e => setListName(e.target.value)} />
            <input type='button' value='Add' onClick=${addTodo} />
            ${todoList.map((list) => {
                return html`
                    <li key=${list.key}>
                        ${list.name}
                        <span>   </span>
                        <input type='button' value='Del' onClick=${() => { removeTodo(list.key) }} />
                    </li>
                `
            })}
        </div>
    `
};
