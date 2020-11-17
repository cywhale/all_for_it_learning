const PNG = require('pngjs').PNG;
const fs = require('fs');

const data = JSON.parse(fs.readFileSync('tmp.json'));
const name = process.argv[2];
const uobj = data.u.messages[0];
const vobj = data.v.messages[0];
const uk = uobj.find(item => item.key === "values");
const vk = vobj.find(item => item.key === "values");

const ui = uobj.find(item => item.key === "Ni");
const uj = uobj.find(item => item.key === "Nj");
const umax = uobj.find(item => item.key === "maximum");
const umin = uobj.find(item => item.key === "minimum");

const vi = vobj.find(item => item.key === "Ni");
const vj = vobj.find(item => item.key === "Nj");
const vmax = vobj.find(item => item.key === "maximum");
const vmin = vobj.find(item => item.key === "minimum");

const udate = uobj.find(item => item.key === "dataDate");
const utime = uobj.find(item => item.key === "dataTime");
const vdate = vobj.find(item => item.key === "dataDate");
const vtime = vobj.find(item => item.key === "dataTime");

const u = {Ni: ui.value, Nj: uj.value, maximum: umax.value, minimum: umin.value, values: uk.value, dataDate: udate.value, dataTime: utime.value};
const v = {Ni: vi.value, Nj: vj.value, maximum: vmax.value, minimum: vmin.value, values: vk.value, dataDate: vdate.value, dataTime: vtime.value};

console.log(u);
//console.log(v);
console.log(u.minimum);
console.log(v.minimum);
console.log(u.Ni, u.Nj)

const width = u.Ni;
const height = u.Nj - 1;

const png = new PNG({
    colorType: 2,
    filterType: 4,
    width: width,
    height: height
});

for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
        const i = (y * width + x) * 4;
        const k = y * width + (x + width / 2) % width;
        png.data[i + 0] = Math.floor(255 * (u.values[k] - u.minimum) / (u.maximum - u.minimum));
        png.data[i + 1] = Math.floor(255 * (v.values[k] - v.minimum) / (v.maximum - v.minimum));
        png.data[i + 2] = 0;
        png.data[i + 3] = 255;
    }
}

png.pack().pipe(fs.createWriteStream(name + '.png'));

fs.writeFileSync(name + '.json', JSON.stringify({
    source: 'http://nomads.ncep.noaa.gov',
    date: formatDate(u.dataDate + '', u.dataTime),
    width: width,
    height: height,
    uMin: u.minimum,
    uMax: u.maximum,
    vMin: v.minimum,
    vMax: v.maximum
}, null, 2) + '\n');

function formatDate(date, time) {
    return date.substr(0, 4) + '-' + date.substr(4, 2) + '-' + date.substr(6, 2) + 'T' +
        (time < 10 ? '0' + time : time) + ':00Z';
}
