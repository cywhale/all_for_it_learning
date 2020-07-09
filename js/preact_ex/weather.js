//modify code (remove '@emotion/styled') from https://codesandbox.io/s/weather-app-with-emotion-fetch-data-with-click-xb3pp
//import { hState } from './app_hooks.js';
import { useState, useEffect } from 'https://unpkg.com/preact@latest/hooks/dist/hooks.module.js?module'; //useRef, useCallback
import { html } from './app_class.js';
/* //the following cannot create custom HTML Tags, may need preact-custom-element 
const Container = (props) => { return html`<div class="weatherContainer"></div>`; };
const WeatherCard = (props) => { return html` <div class="weatherCard"></div>`; };
const Location = (props) => { return html` <div class="weatherLoc"></div>`; };
const Description = (props) => { return html` <div class="weatherDesc"></div>`; };
const CurrentWeather = (props) => { return html` <div class="currWeather"></div>`; };
const Temperature = (props) => { return html` <div class="weatherTemp"></div>`; };
const Celsius = (props) => { return html` <div class=".Celsius"></div>`; };
const Cloudy = (props) => { return html` <div class="Cloudy"></div>`; }; //styled(CloudyIcon)
const AirFlow = (props) => { return html` <div class="AirFlow"></div>`; };
const Rain = (props) => { return html` <div class="Rain"></div>`; };
const Redo = (props) => { return html` <div class="Redo"></div>`; };
*/
export const WeatherApp = () => {
  const [currentWeather, setCurrentWeather] = useState({ //hState
    observationTime: new Date(),
    locationName: '臺北',
    description: '',
    temperature: '',
    windSpeed: '',
    humid: '',
  });

  useEffect(() => {
    console.log("Fetch current weather...")
    fetchCurrentWeather();
  }, []);

  const fetchCurrentWeather = () => {
    fetch(
      'https://opendata.cwb.gov.tw/api/v1/rest/datastore/O-A0003-001?Authorization=CWB-507B37E0-0383-4D8C-878D-628B54EC3536&locationName=臺北',
    )
      .then(response => response.json())
      .then(data => {
        const locationData = data.records.location[0];
        const weatherElements = locationData.weatherElement.reduce(
          (neededElements, item) => {
            if (['WDSD', 'TEMP', 'HUMD', 'H_Weather'].includes(item.elementName)) {
              neededElements[item.elementName] = item.elementValue;
            }
            return neededElements;
          }, {},
        );

        setCurrentWeather({
          observationTime: locationData.time.obsTime,
          locationName: locationData.locationName,
          description: weatherElements.H_Weather,
          temperature: weatherElements.TEMP,
          windSpeed: weatherElements.WDSD,
          humid: weatherElements.HUMD,
        });
      });
  };

  return html`
    <div class="weatherContainer">
      <div class="weatherCard">
        <div class="weatherLoc">${currentWeather.locationName}</div>
        <div class="weatherDesc">${currentWeather.description}</div>
        <div class="currWeather">
          <div class="weatherTemp">
            ${Math.round(currentWeather.temperature)} <div class="Celsius">°C</div>
          </div>
          <div class="Cloudy"><!--CloudyIcon /--></div>
        </div>
        <div class="AirFlow">
          <div class="AirFlowIcon">${currentWeather.windSpeed} m/h</div>
        </div>
        <div class="Rain">
          <!--RainIcon /-->
          ${Math.round(currentWeather.humid * 100)} %
        </div>

        <div class="Redo" onClick=${fetchCurrentWeather}>
          最後觀測時間：
          ${new Intl.DateTimeFormat('zh-TW', {
            hour: 'numeric',
            minute: 'numeric',
          }).format(new Date(currentWeather.observationTime))}        
        </div>
      </div>
    </div>
  `
};
