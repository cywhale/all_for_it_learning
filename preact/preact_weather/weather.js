//modify code (remove '@emotion/styled') from https://codesandbox.io/s/weather-app-with-emotion-fetch-data-with-click-xb3pp
//import { hState } from './app_hooks.js';
import { useState, useEffect, useCallback, useMemo } from 'https://unpkg.com/preact@latest/hooks/dist/hooks.module.js?module'; //useRef
import { html } from './app_class.js';
//import { useState, useEffect, useCallback, useMemo } from 'preact/hooks'
//import { html } from 'htm/preact';

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
    weatherCode: 1,
    rainPossibility: 0,
    comfortability: '',
    isLoading: true
  });

  const {
    observationTime,
    locationName,
    humid,
    temperature,
    windSpeed,
    description,
    weatherCode,
    rainPossibility,
    comfortability,
    isLoading,
  } = weatherElement;

  //ithelp code: https://ithelp.ithome.com.tw/articles/10225504
  const fetchData = useCallback(() => {
    const fetchingData = async () => { //ithelp code: https://ithelp.ithome.com.tw/articles/10225102
      const [currentWeather, weatherForecast] = await Promise.all([
        fetchCurrentWeather(),
        fetchWeatherForecast() //code from ithelp: https://ithelp.ithome.com.tw/articles/10224650
      ]);

      await setWeatherElement({
        ...currentWeather,
        ...weatherForecast,
        isLoading: false
      });
    };

    setWeatherElement((prevState) => ({ //ithelp code: https://ithelp.ithome.com.tw/articles/10226579
        ...prevState,
        isLoading: true
    }));

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
          weatherCode: weatherElements.Wx.parameterValue,
          rainPossibility: weatherElements.PoP.parameterName,
          comfortability: weatherElements.CI.parameterName,
        }));
      });
  };

// Handle WeatherIcon, code from ithelp https://ithelp.ithome.com.tw/articles/10225927
  const weatherTypes = {
    isThunderstorm: [15, 16, 17, 18, 21, 22, 33, 34, 35, 36, 41],
    isClear: [1],
    isCloudyFog: [25, 26, 27, 28],
    isCloudy: [2, 3, 4, 5, 6, 7],
    isFog: [24],
    isPartiallyClearWithRain: [8, 9, 10, 11, 12, 13, 14, 19, 20, 29, 30, 31, 32, 38, 39],
    isSnowing: [23, 37, 42],
  };
  
  const weatherIcons = {
    day: {
      isThunderstorm: './svg/day-thunderstorm.svg',
      isClear: './svg/day-clear.svg',
      isCloudyFog: './svg/day-cloudy-fog.svg',
      isCloudy: './svg/day-cloudy.svg',
      isFog: './svg/day-fog.svg',
      isPartiallyClearWithRain: './svg/day-partially-clear-with-rain.svg',
      isSnowing: './svg/day-snowing.svg',
    },
    night: {
      isThunderstorm: './svg/night-thunderstorm.svg',
      isClear: './svg/night-clear.svg',
      isCloudyFog: './svg/night-cloudy-fog.svg',
      isCloudy: './svg/night-cloudy.svg',
      isFog: './svg/night-fog.svg',
      isPartiallyClearWithRain: './svg/night-partially-clear-with-rain.svg',
      isSnowing: './svg/night-snowing.svg',
    },
  };

  //use correct sunrise time can refer: https://ithelp.ithome.com.tw/articles/10225946 (but need update)
  const getMoment = (currTime) => {
    if (!currTime) return ('day');
    let month = parseInt(currTime.getMonth());
    let sunRise= month<9 && month>=6? "05:30": month<=10 && month>=3? "06:00": "06:30"   
    let sunSet = month<9 && month>=6? "18:30": month<=10 && month>=3? "18:00": "17:30"   
    const momentx = (minsec) => {
      let ms = minsec.split(":"); 
      return new Date(currTime.getFullYear(), currTime.getMonth(), currTime.getDate(), 
                      parseInt(ms[0]), parseInt(ms[1]), 0, 0);  
    }
    return momentx(sunRise) <= currTime && currTime <= momentx(sunSet)? "day": "night"
  }

  const moment = useMemo(() => getMoment(observationTime), [
    observationTime,
  ]);

  const weatherCode2Type = weatherCode =>
    Object.entries(weatherTypes).reduce(
      (currentWeatherType, [weatherType, weatherCodes]) =>
        weatherCodes.includes(Number(weatherCode))? weatherType: currentWeatherType,
      '',
    );
  
  const WeatherIcon = (currentWeatherCode, moment) => {
    const [currentWeatherIcon, setCurrentWeatherIcon] = useState('isClear');
  
    const theWeatherIcon = useMemo(() => weatherCode2Type(currentWeatherCode), [
      currentWeatherCode,
    ]);
  
    useEffect(() => {
      setCurrentWeatherIcon(theWeatherIcon);
    }, [theWeatherIcon]);
  
    return weatherIcons[moment || 'day'][currentWeatherIcon]
  };
/* Not work
  const loadingIcon = (isLoading) => {
    if (!isLoading) return html`<object type="image/svg+xml" data="./svg/redo.svg" class="svglogo"></object>`;
    return html`<object type="image/svg+xml" data="./svg/loading.svg" class="svglogo"></object>`;
  }
*/  
  return html`
    <div class="weatherContainer">
      ${console.log('render, isLoading: ', isLoading)}

      <div class="weatherCard">
        <div class="weatherLoc">${locationName}</div>
        <div class="weatherDesc">
          <span>${description}</span><span>${comfortability}</span>
        </div>
        <div class="currWeather">
          <div class="weatherTemp">
            ${Math.round(temperature)} <div class="Celsius">°C</div>
          </div>
          <div class=".iconContainer">
              <object type="image/svg+xml" data=${WeatherIcon(weatherCode, moment)} class="svglogo"></object>
          </div>
        </div>
        <div class="AirFlow">
          <!--"AirFlowIcon"-->
          <object type="image/svg+xml" data="./svg/airFlow.svg" class="svglogo"></object>
          ${windSpeed} m/h
        </div>
        <div class="Rain">
          <!--RainIcon /-->
          <object type="image/svg+xml" data="./svg/humid.svg" class="svglogo"></object>
          ${Math.round(humid * 100)} % 
        </div>
        <div class="Rain">
          <object type="image/svg+xml" data="./svg/rain.svg" class="svglogo"></object>
          ${Math.round(rainPossibility)} %
        </div>

        <div class="Redo" onClick=${fetchData} isLoading=${isLoading}>
          <object type="image/svg+xml" data="./svg/redo.svg" class="svglogo"></object>          <span> </span>最後觀測時間：
          ${new Intl.DateTimeFormat('zh-TW', {
            year: 'numeric', month: 'numeric', day: 'numeric',  
            hour: 'numeric',
            minute: 'numeric',
          }).format(observationTime)}
        </div>
      </div>
    </div>
  `
};
