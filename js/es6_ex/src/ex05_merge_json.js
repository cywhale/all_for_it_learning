const data = [
    {
      "label": "Flows",
      "disabled": false,
      "children": [
        { "label": "Windy","value": "gfs_", "format": "json", "type": "flows" }
      ],
      "value": "flows"
    },
    { "label": "-------- Socioeconomics --------", "disabled": true, "value": "socioeconomics"},
    {
      "label": "Wind farm, Taiwan",
      "children": [
        { "value": "onshorewind", "label": "Onshore wind-power stations", "type": "sitecluster", "format": "geojson" },
      ],
      "value": "taiwanwindfarm"
    },
    {
      "label": "Natural Reserve, Taiwan",
      "children": [
        { "value": "whitedolphin", "label": "White Dolphin Reserve", "type": "region", "format": "geojson" },
        { "value": "wildanimalreserve", "label": "Wild Animal Habitat", "type": "region", "format": "geojson" },
        { "value": "naturalreserve", "label": "Natural Reserve", "type": "region", "format": "geojson" }
      ],
      "value": "taiwannaturalreserve"
    }
  ];

const newj = [
    { "label": "-------- Socioeconomics --------", "disabled": true, "value": "socioeconomics"},
    {
      "label": "Wind farm, Taiwan",
      "children": [
        { "value": "onshorewind", "label": "Onshore wind-power stations", "type": "sitecluster", "format": "geojson" },
        { "value": "offshorewindpowerplan", "label": "Offshore wind-power plan", "type": "region", "format": "geojson" },
        { "value": "offshorewindpotential", "label": "Offshore wind-power potential", "type": "region", "format": "geojson" }
      ],
      "value": "taiwanwindfarm"
    }
];

const newk = {
  "label": "Demography",
  "children": [
    { "value": "population909500", "label": "Population 1990-2000", "type": "cube", "format": "json" }
  ],
  "value": "demography",
  "metagroup": "socioeconomics"
};

let arr = [...data, ...newj, ...[newk]];
console.log(arr);
let result = [];

for (let i = 0; i < arr.length; i++) {
  let found = false;
  let group = -1;
  for (let j = 0; j < result.length; j++) {
    if (result[j].value == arr[i].value) {
      found = true;
      if ('children' in result[j] && 'children' in arr[i]) {
        let filtered = arr[i].children.filter(
          function(e) {
            //console.log("Now check contains:", e.value, this[0])
            return this.map(o => o.value).indexOf(e.value) < 0
          },
          result[j].children
        );
        //console.log("i, j, filtered, arr[i].children, result[j].children", i, j, filtered, arr[i].children, result[j].children);
        if (filtered.length > 0) {
          result[j].children = [...result[j].children, ...filtered];
        }
      }
      break;
    }
    if (arr[i].metagroup === result[j].value) {
      group = j
    }
  }
  if (!found) {
    if (group >= 0 && result.length > group) { 
      //console.log("find group: ", group, result.length);
      result.splice(group + 1, 0, arr[i]);
    } else {
      result.push(arr[i]);
    }
  }
}
console.log(result);
console.log("==== check children ====")
console.log(result[3].children)