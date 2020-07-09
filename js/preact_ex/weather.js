//modify code (remove '@emotion/styled') from https://codesandbox.io/s/weather-app-with-emotion-fetch-data-with-click-xb3pp
//import { hState } from './app_hooks.js';
import { useState, useEffect, useCallback } from 'https://unpkg.com/preact@latest/hooks/dist/hooks.module.js?module'; //useRef
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
  const [weatherElement, setWeatherElement] = useState({ //hState
    observationTime: new Date(),
    locationName: '',
    humid: 0,
    temperature: 0,
    windSpeed: 0,
    description: '',
    //weatherCode: 0,
    rainPossibility: 0,
    comfortability: '',
  });
  //ithelp code: https://ithelp.ithome.com.tw/articles/10225504
  const fetchData = useCallback(() => {
    const fetchingData = async () => { //ithelp code: https://ithelp.ithome.com.tw/articles/10225102
      const [currentWeather, weatherForecast] = await Promise.all([
        fetchCurrentWeather(),
        fetchWeatherForecast() //code from ithelp: https://ithelp.ithome.com.tw/articles/10224650
      ]);

      await setWeatherElement({
        ...currentWeather,
        ...weatherForecast
      });
    };
    fetchingData();
  }, []); // callback with dependency [] is like useMemo hook

  useEffect(() => {
    //console.log("Fetch current weather...")
    fetchData(); //function cause dependency unequal then repeated render, so put within callback
  }, [fetchData]);

  const fetchCurrentWeather = () => {
    fetch(
      'https://opendata.cwb.gov.tw/api/v1/rest/datastore/O-A0003-001?Authorization=CWB-507B37E0-0383-4D8C-878D-628B54EC3536&locationName=臺北',
    )
      .then(response => response.json())
      .then(data => {
        const locationData = data.records.location[0];
        const weatherElements = locationData.weatherElement.reduce(
          (neededElements, item) => {
            if (['WDSD', 'TEMP', 'HUMD'].includes(item.elementName)) { //, 'H_Weather'
              neededElements[item.elementName] = item.elementValue;
            }
            return neededElements;
          }, {},
        );

        setWeatherElement(prevState => ({
          ...prevState,
          observationTime: new Date(locationData.time.obsTime),
          locationName: locationData.locationName,
          //description: weatherElements.H_Weather,
          temperature: weatherElements.TEMP,
          windSpeed: weatherElements.WDSD,
          humid: weatherElements.HUMD,
        }));
      });
  };

  const fetchWeatherForecast = () => {
    fetch(
      'https://opendata.cwb.gov.tw/api/v1/rest/datastore/F-C0032-001?Authorization=CWB-507B37E0-0383-4D8C-878D-628B54EC3536&locationName=臺北市',
    )
      .then(response => response.json())
      .then(data => {
        const locationData = data.records.location[0];
        const weatherElements = locationData.weatherElement.reduce(
          (neededElements, item) => {
            if (['Wx', 'PoP', 'CI'].includes(item.elementName)) {
              neededElements[item.elementName] = item.time[0].parameter;
            }
            return neededElements;
          },
          {},
        );

        setWeatherElement(prevState => ({
          ...prevState,
          description: weatherElements.Wx.parameterName,
          //weatherCode: weatherElements.Wx.parameterValue,
          rainPossibility: weatherElements.PoP.parameterName,
          comfortability: weatherElements.CI.parameterName,
        }));
      });
  };

  return html`
    <div class="weatherContainer">
      <div class="weatherCard">
        <div class="weatherLoc">${weatherElement.locationName}</div>
        <div class="weatherDesc">
          <span>${weatherElement.description}</span><span>${weatherElement.comfortability}</span>
        </div>
        <div class="currWeather">
          <div class="weatherTemp">
            ${Math.round(weatherElement.temperature)} <div class="Celsius">°C</div>
          </div>
          <div><object type="image/svg+xml" data="./svg/cloudy.svg" class="Cloudy"></object></div>
        </div>
        <div class="AirFlow">
          <!--"AirFlowIcon"-->
          <object type="image/svg+xml" data="./svg/airFlow.svg" class="svglogo"></object>
          ${weatherElement.windSpeed} m/h
        </div>
        <div class="Rain">
          <!--RainIcon /-->
          <object type="image/svg+xml" data="./svg/humid.svg" class="svglogo"></object>
          ${Math.round(weatherElement.humid * 100)} % 
        </div>
        <div class="Rain">
          <object type="image/svg+xml" data="./svg/rain.svg" class="svglogo"></object>
          ${Math.round(weatherElement.rainPossibility)} %
        </div>

        <div class="Redo" onClick=${fetchData}>
        <object type="image/svg+xml" data="./svg/redo.svg" class="svglogo"></object>
          最後觀測時間：
          ${new Intl.DateTimeFormat('zh-TW', {
            year: 'numeric', month: 'numeric', day: 'numeric',  
            hour: 'numeric',
            minute: 'numeric',
          }).format(weatherElement.observationTime)}
        </div>
      </div>
    </div>
  `
};
