//useRef version ref/querySelector
//https://codesandbox.io/s/preactsortablemultiselect-forked-j6mwy?file=/src/MultiSelectSort.js
//useContext Version
//https://github.com/preactjs/preact/issues/2790
//https://codesandbox.io/s/preactsortablemultiselect-forked-zw50w?file=/src/MultiSelectSort.js:70-149
//ref: https://react-select.com/advanced
//import React from 'react';
//import React, { createContext, useCallback, useContext } from "preact/compat";
import React, { findDOMNode, useRef } from "preact/compat";
//import ReactDOM from "preact/compat";
//import { useState } from 'preact/hooks';
import Select, { components } from 'react-select';
import { SortableContainer, SortableElement } from 'react-sortable-hoc';
//import { options } from "preact";
//options.debounceRendering = setTimeout;

function arrayMove(array, from, to) {
  array = array.slice();
  array.splice(to < 0 ? array.length + to : to, 0, array.splice(from, 1)[0]);
  return array;
}

const SortableMultiValue = SortableElement((props) => {
  // this prevents the menu from being opened/closed when the user clicks
  // on a value to begin dragging it. ideally, detecting a click (instead of
  // a drag) would still focus the control and toggle the menu, but that
  // requires some magic with refs that are out of scope for this example
  const onMouseDown = (e) => {
    e.preventDefault();
    // e.stopPropagation();
  };
  const innerProps = { onMouseDown };
  return <components.MultiValue {...props} innerProps={innerProps} />;
});
const SortableSelect = SortableContainer(Select);

function Control(props) {
  return (
    <components.Control
      {...props}
      innerProps={{
        ...props.innerProps,
        onMouseDown: (e) => {
          let target = e.target;
          while (target && target !== e.currentTarget) {
            // when the event was fired on a MultiValue item
            // we do not call the props.innerProps.onMouseDown handler
            // preventing the react-select dropdown to open
            if (target.className.indexOf("-multiValue") !== -1) {
              return;
            }

            target = target.parentElement;
          }

          if (props.innerProps.onMouseDown) {
            props.innerProps.onMouseDown(e);
          }
        }
      }}
    />
  );
}

const MultiSelectSort = () => {
  const colourOptions = [
    { value: 'chocolate', label: 'Chocolate' },
    { value: 'strawberry', label: 'Strawberry' },
    { value: 'vanilla', label: 'Vanilla' },
    { value: 'red', label: 'red' },
    { value: 'cyan', label: 'cyan' },
    { value: 'blue', label: 'blue' }
  ]
  const [selected, setSelected] = React.useState([
    colourOptions[4],
    colourOptions[5],
  ]);

  const onChange = selectedOptions => setSelected(selectedOptions);

  const onSortEnd = ({ oldIndex, newIndex }) => {
    const newValue = arrayMove(selected, oldIndex, newIndex);
    setSelected(newValue);
    //console.log('Values sorted:', newValue.map(i => i.value));
  };

  const ref = useRef(null);

  return (
    <div ref={ref}>
      <SortableSelect
        // react-sortable-hoc props:
        axis="xy"
        onSortEnd={onSortEnd}
        distance={4}
        getContainer={() => {
          return ref.current.querySelector('[class*="control"]');
        }}
        // small fix for https://github.com/clauderic/react-sortable-hoc/pull/352:
        getHelperDimensions={({ node }) => node.getBoundingClientRect()}
        // react-select props:
        isMulti
        options={colourOptions}
        value={selected}
        onChange={onChange}
        components={{
          MultiValue: SortableMultiValue,
          Control
        }}
        closeMenuOnSelect={false}
      />
    </div>
  );
};
export default MultiSelectSort;


