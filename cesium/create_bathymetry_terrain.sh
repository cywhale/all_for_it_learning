# from cesium_terrain_builder tumgis/ctb-dquantized-mesh
# https://github.com/tum-gis/cesium-terrain-builder-docker
docker pull tumgis/ctb-dquantized-mesh
# put your terrain gtiff under your data directory
# or
#docker cp /YourData/geo.tif ctb:/data/
#docker cp /YourData/geo.vrt ctb:/data/
#docker cp /YourData/geo.vrt.ovr ctb:/data/
docker run --rm -it --name ctb -v "/YourData/":"/data" tumgis/ctb-quantized-mesh
# in docker, -c specify your thread, need some value to prevent core dump
mkdir -p terrain
ctb-tile -f Mesh -c 8 -C -N -o terrain <inputfile.tif or input.vrt>
# for layer.json
ctb-tile -f Mesh -c 8 -C -N -l -o terrain <inputfile.tif or input.vrt>

# use go project of geo-data/cesium-terrain-server
# https://github.com/geo-data/cesium-terrain-builder
# if use docker: https://github.com/geo-data/cesium-terrain-server/tree/master/docker
# if former, MUST install GO first
go get github.com/geo-data/cesium-terrain-server/cmd/cesium-terrain-server

# if use https, must ref: https://github.com/geo-data/cesium-terrain-server/issues/9
# by DhinendraRajapakse's solution
cd ~/go/src/github.com/geo-data/cesium-terrain-server/cmd/cesium-terrain-server/
# vi main.go
# needs
```
//  DhinendraRajapakse's solution:

https := flag.Bool("https", false, "if https is enabled")
pemPath := flag.String("pemPath", "", "Path to pem files cert.pem and key.pem")


// ... (skip) ...


if *https {

	if len(*pemPath) == 0 {
		log.Notice(fmt.Sprintf("Https Server Cannot be run with out  -pemPath specified %s", *pemPath))
		os.Exit(1)
	}

	keyFilesExist := true
	_, err := os.Stat(*pemPath + "/key.pem")
	if err != nil {
		keyFilesExist = false
	} else if os.IsNotExist(err) {
		keyFilesExist = false
	}

	_, err = os.Stat(*pemPath + "/cert.pem")
	if err != nil {
		keyFilesExist = false
	} else if os.IsNotExist(err) {
		keyFilesExist = false
	}

	if !keyFilesExist {
		log.Notice(fmt.Sprintf("Https Server Cannot be run key.pem and cert.pem do not exist in dir %s" + *pemPath))
		os.Exit(1)
	}

	log.Notice(fmt.Sprintf("Https Server listening on port %d", *port))

        err_http := http.ListenAndServeTLS(fmt.Sprintf(":%d", *port), *pemPath+"/cert.pem", *pemPath+"/key.pem", nil)
	if err_http != nil {
		fmt.Println(err_http)
	}

	os.Exit(1)
} else {
	log.Notice(fmt.Sprintf("Http Server listening on port %d", *port))

	err_http := http.ListenAndServe(fmt.Sprintf(":%d", *port), nil)
	if err_http != nil {
		fmt.Println(err_http)
	}
	os.Exit(1)
}

```

cd ../../
# under directory geo-data/cesium-terrain-server
go build ./...
go install ./...

# if https, copy your key.pem cert.pem to /YourPem/
# Run the command under /YourData, assume here the directory structure follow geo-data github suggestion:
#/data/tilesets/terrain/srtm/
#├── 0
#│   └── 0
#│       └── 0.terrain
#├── 1
#│   └── 1
#│       └── 1.terrain
#├── 2
#│   └── 3
#│       └── 3.terrain
#└── 3
#    └── 7
#        └── 6.terrain
# and you may set proxy_pass to https://YourHost/tilesets/ if use nginx, port assume 8038
cesium-terrain-server -dir /data/tilesets/terrain -port 8038 -pemPath /YourPem -https true

# follow cesium programming basics & following suggestions
# https://community.cesium.com/t/viewing-tiles-under-surface-imagery-obscures-tiles/9290/3
# https://community.cesium.com/t/help-us-test-the-new-underground-features-in-cesiumjs/9581
# https://sandcastle.cesium.com/?src=Globe%20Translucency.html

#    var Your_Cesium_terrainProvider = new Cesium.CesiumTerrainProvider({
#        url: "https://YourHoust/tilesets/srtm",
#        requestWaterMask: false,
#        requestVertexNormals:  true,
#    });
