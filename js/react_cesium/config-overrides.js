const webpack =require('webpack');
const cesiumSource = 'node_modules/cesium/Source';
const cesiumWorkers = '../Build/Cesium/Workers';

const path = require('path');
const CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = function override(config, env) {
    if (!config.plugins) {
        config.plugins = [];
    }

    config.plugins.push(
      new CopyWebpackPlugin({
        patterns: [
        {
          from: path.join(cesiumSource, cesiumWorkers),
          to: "Workers",
        },
        {
          from: path.join(cesiumSource, "Assets"),
          to: "Assets",
        },
        {
          from: path.join(cesiumSource, "Widgets"),
          to: "Widgets",
        },
        ],
      })
    );
    config.plugins.push(
      new webpack.DefinePlugin({
            // Define relative base path in cesium for loading assets
         CESIUM_BASE_URL: JSON.stringify('')
      })
    );
    return config;
}

