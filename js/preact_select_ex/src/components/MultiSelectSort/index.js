import { useState } from 'preact/hooks';
import Select from 'react-select';
import { SortableContainer } from 'react-sortable-hoc';
import SortMulti from './SortMulti';

const MultiSelectSort = () => {
  const state_options = [
    { value: 'white', label: 'White' },
    { value: 'red', label: 'Red' },
    { value: 'cyan', label: 'Cyan' },
  ];
  const [state, setState] = useState(null);

  const arrayMove = (array, from, to) => {
    array = array.slice();
    array.splice(to < 0 ? array.length + to : to, 0, array.splice(from, 1)[0]);
    return array;
  };

  const onSortEnd = ({ oldIndex, newIndex }) => {
    const newValue = arrayMove(state, oldIndex, newIndex);
    setState(newValue);
    //console.log('Values sorted:', newValue.map(i => i.value));
  };

  const SortableSelect = SortableContainer(Select);
  return (
    <SortableSelect
         axis="xy"
         onSortEnd={onSortEnd}
         distance={4}
         // https://react-select.com/advanced
         // small fix for https://github.com/clauderic/react-sortable-hoc/pull/352:
         getHelperDimensions={({ node }) => node.getBoundingClientRect()} //>
         // <Select
             isMulti
             value={state}
             onChange={setState}
             //name="stateSel"
             //className="basic-multi-select"
             //classNamePrefix="select"
             options={state_options}
             components={{
               MultiValue: SortMulti, //SortableMultiValue,
             }}
             closeMenuOnSelect={false} />
  );
}
export default MultiSelectSort;
