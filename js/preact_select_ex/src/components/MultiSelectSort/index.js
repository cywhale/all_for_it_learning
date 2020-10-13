//import React from 'preact/compat'
import DropdownTreeSelect from 'react-dropdown-tree-select';
//For completion, it's possible to make CSS Modules work outside the /components folder?
//https://stackoverflow.com/questions/49118172/preact-cli-css-modules
//import '../../style/select_style.css';
import 'react-dropdown-tree-select/dist/styles.css'
import data from './data.json';

const onChange = (curNode, selectedNodes) => {
  console.log('onChange::', curNode, selectedNodes)
}
const onAction = (node, action) => {
  console.log('onAction::', action, node)
}
const onNodeToggle = curNode => {
  console.log('onNodeToggle::', curNode)
}

const MultiSelectSort = () => (
  <div>
    <DropdownTreeSelect data={data} onChange={onChange} onAction={onAction} onNodeToggle={onNodeToggle} />
  </div>
)

export default MultiSelectSort
