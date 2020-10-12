import { useState } from 'preact/hooks';
//import { createPortal } from 'preact/compat';
import Select from 'react-select';
import { SortableContainer } from 'react-sortable-hoc';
import SortMulti from './SortMulti';

const MultiSelectSort = () => {
  const region_options = [
    { value: 'whitedolphin', label: 'White Dolphin Reserve' },
    { value: 'wildanimal', label: 'Wild Animal Habitat' },
    { value: 'naturalreserve', label: 'Natural Reserve' },
  ];
  const [region, setRegion] = useState(null);

  const arrayMove = (array, from, to) => {
    array = array.slice();
    array.splice(to < 0 ? array.length + to : to, 0, array.splice(from, 1)[0]);
    return array;
  };

  const onSortEnd = ({ oldIndex, newIndex }) => {
    const newValue = arrayMove(region, oldIndex, newIndex);
    setRegion(newValue);
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
             value={region}
             onChange={setRegion}
             //name="regionSel"
             //className="basic-multi-select"
             //classNamePrefix="select"
             options={region_options}
             components={{
               MultiValue: SortMulti, //SortableMultiValue,
             }}
             closeMenuOnSelect={false} />
  );
}
export default MultiSelectSort;
