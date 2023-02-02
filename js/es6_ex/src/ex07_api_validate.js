import SwaggerParser from "@apidevtools/swagger-parser";

let apiurl = // 'https://ecodata.odb.ntu.edu.tw/api/json'; //not valid (Swagger 2.0)
    //'https://api.odb.ntu.edu.tw/apieditor/static/odb_openapi3_sadcp_ctd.yml'
    //valid --> API name: ODB Open API, Version: 1.0.0
    //'https://api.odb.ntu.edu.tw/search/schema?node=odb_v1_gebco_202211'
    //valid --> API name: ODB API for GEBCO Bathymetry, Version: 1.0.0
    //'https://api.odb.ntu.edu.tw/search/schema?node=odb_v1_copkey_202210'; //not valid
    'https://api.odb.ntu.edu.tw/search/schema?node=obis_v3_202208'

SwaggerParser.validate(apiurl, (err, api) => {
    if (err) {
        console.error(err);
    }
    else {
        console.log("API name: %s, Version: %s", api.info.title, api.info.version);
    }
});
