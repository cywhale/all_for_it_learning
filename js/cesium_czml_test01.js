//Also test on cesium sandcastle: https://bit.ly/2JMpAsP
//Moing obj position, and path trajectory, polyline between two objs
//geojson to czml, may ref: https://cesium.com/blog/2018/03/21/czml-time-animation/
//simple.czml example on sandcastle: https://sandcastle.cesium.com/SampleData/simple.czml
//satellite example: https://bit.ly/3pbA45g with airplane and side-view https://reurl.cc/8n8NdM


var viewer = new Cesium.Viewer("cesiumContainer", {
    shouldAnimate: true,
});
  

var czml = [
    {
      id: "document",
      name: "CZML movement Dynamic",
      version: "1.0",
      clock: {
          interval: '2010-02-02T00:00:00Z/2010-02-03T23:59:59Z',
          currentTime: '2010-02-02T00:00:00Z',
          multiplier: 10000,
          range: 'LOOP_STOP',
          step: 'SYSTEM_CLOCK_MULTIPLIER'    
      }
    },
    { //Packet-1
      id: "myobj1",
      availability: "2010-02-02T00:00:00Z/2010-02-03T23:59:59Z",
      position: {
        epoch: "2010-02-02T00:00:00Z",
        cartographicDegrees: [
          0, 121.27, 22.52, 14000,
          43200, 122.552, 23.675, 14000,
          86400, 123.62, 24.713, 14000.0
        ],
      },   
      point: {
        color: {
          rgba: [255, 255, 255, 128],
        },
        outlineColor: {
          rgba: [255, 0, 0, 128],
        },
        outlineWidth: 3,
        pixelSize: 15,
      },
      path : {
        resolution : 1,
        leadTime: 0,
        trailTime: 172800,
        material : {
          solidColor : { 
            color: { rgba: [0, 127, 255, 128] }
          }
        },
        width : 2
      },
      polyline:{
        show:[
          {
          interval:"2010-02-02T00:00:00Z/2020-02-03T23:59:59Z",
          boolean:true
          },
        ],
        width:1,
        material:{
          solidColor:{
            color:{
              rgba:[
              0,255,255,255
              ]
            }
          }
        },
        followSurface:false,
        positions:{
          references:[
          "myobj1#position","myobj2#position"
          ]
        }
      }
    },
    {// Packet-2, but try another obj
      id: "myobj2",
      availability: "2010-02-03T00:00:00Z/2010-02-03T23:59:59Z",
      position: {
        epoch: "2010-02-03T00:00:00Z",
        cartographicDegrees: [
          0, 122.0, 24.713, 14000,
          43200, 121.552, 25.075, 14000,
          86400, 121.02, 25.713, 14000.0
        ]
      },
      path : {
        resolution : 1,
        leadTime: 0,
        trailTime: 172800,
        material : {
          solidColor : { 
            color: { rgba: [64, 127, 0, 128] }
          }
        },
        width : 2
      },
      point: {
        color: {
          rgba: [255, 125, 125, 128],
        },
        outlineColor: {
          rgba: [0, 255, 0, 128],
        },
        outlineWidth: 3,
        pixelSize: 25,
      }
    },
    {// Packet-3
      id: "myobj1",
      //someInterpolatableProperty: {
      position: {
        epoch: "2010-02-03T00:00:00Z",
        cartographicDegrees: [
          10000, 125.0, 24.713, 14000,
          43200, 124.552, 25.075, 14000,
          86400, 124.62, 25.713, 14000.0
        ],
        //backwardExtrapolationDuration: 86400
        //forwardExtrapolationDuration: 4.0
      },/*
      path : {
        resolution : 1,
        leadTime: 0,
        trailTime: 86400,
        material : {
          solidColor : { 
            color: { rgba: [127, 127, 255, 128] }
          }
        },
        width : 2
      },*/
    }    
];
  
viewer.dataSources.add(Cesium.CzmlDataSource.load(czml));
  
viewer.scene.camera.setView({
      destination: Cesium.Cartesian3.fromDegrees(121.5, 23.00, 95000),
      /*orientation: {
        heading: 6,
      },*/
});
