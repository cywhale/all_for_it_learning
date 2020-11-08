const ExtractTextPlugin = require('extract-text-webpack-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const DuplicatePackageCheckerPlugin = require("duplicate-package-checker-webpack-plugin");
const CompressionPlugin = require('compression-webpack-plugin');
//const zlib = require('zlib');
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;

const path = require('path');
// mode
const testenv = {NODE_ENV: process.env.NODE_ENV};
var entryx, devtoolx, pluginx;
var outputx = {
      filename: '[name].[chunkhash:8].js', //'static/js/'
      sourceMapFilename: '[name].[chunkhash:8].map',
      chunkFilename: '[name].[chunkhash:8].chunk.[id].js',
      publicPath: "./",
      //path: path.resolve(__dirname, 'build'),
      // Needed to compile multiline strings in Cesium
      sourcePrefix: ''
};

var optimizex = {
       usedExports: true,
       runtimeChunk: true, //'single'
       minimizer:
       [
         new TerserPlugin({
             parallel: true,
             terserOptions: {
                compress: { drop_console: true },
                output: { comments: false }
             }, //https://github.com/preactjs/preact-cli/blob/master/packages/cli/lib/lib/webpack/webpack-client-config.js
             extractComments: false //{
         })
      ],
      splitChunks: {
        //name: 'vendors',
        chunks: "all",
        maxInitialRequests: Infinity,
        //minSize: 0,
        cacheGroups: {
        /*preactBase: {
            name: 'preactBase',
            test: (module) => {
              return /preact|prop-types/.test(module.context);
            },
            chunks: 'pre',
            priority: 10,
          },*/
          vendors: {
            test: /[\\/]node_modules[\\/]/,
            priority: -10,
            chunks: 'initial',
            name: `chunk-vendors` //(module) {
              // get the name. E.g. node_modules/packageName/not/this/part.js
              // or node_modules/packageName
              //const packageName = module.context.match(/[\\/]node_modules[\\/](.*?)([\\/]|$)/)[1];
              // npm package names are URL-safe, but some servers don't like @ symbols
              //return `npm.${packageName.replace('@', '')}`;
            //},
          } //, https://blog.logrocket.com/guide-performance-optimization-webpack/
        }
      }
    };

if (testenv.NODE_ENV === "production") {
    console.log("Node env in production...");
    entryx = [
      //require.resolve('./polyfills'),
      './src/index.js'
    ];
    outputx = {...outputx,
      path: path.resolve(__dirname, 'build')
    };
    devtoolx = false;
    pluginx = [
      new HtmlWebpackPlugin({
         template: 'template.html',
         production : true,
         inject: true,
      minify: {
        removeComments: true,
        collapseWhitespace: true,
        removeRedundantAttributes: true,
        useShortDoctype: true,
        removeEmptyAttributes: true,
        removeStyleLinkTypeAttributes: true,
        keepClosingSlash: true,
        minifyJS: true,
        minifyCSS: true,
        minifyURLs: true
      }
      }),
      new CompressionPlugin({
          filename: '[path][base].br', //asset: '[path].br[query]'
          algorithm: 'brotliCompress', //for CompressionPlugin
          deleteOriginalAssets: false, //for CompressionPlugin
          test: /\.(js|css|html|svg)$/,
          compressionOptions: {
            // zlib’s `level` option matches Brotli’s `BROTLI_PARAM_QUALITY` option.
            level: 11,
          },
          threshold: 10240,
          minRatio: 0.8
      }),
      new CompressionPlugin({
          filename: '[path][base].gz', //asset: '[path].gz[query]'
          algorithm: 'gzip',
          test: /\.(js|css|html|svg)$/,
          threshold: 10240,
          minRatio: 0.8
      }),
      new webpack.optimize.OccurrenceOrderPlugin(),
      new DuplicatePackageCheckerPlugin(),
      new BundleAnalyzerPlugin({
          analyzerMode: 'static', //disabled
          generateStatsFile: true,
          statsOptions: { source: false }
      })
    ];

  } else {
    console.log("Node env in development...");
    devtoolx = 'source-map';
    entryx = [
      'webpack-dev-server/client?https://0.0.0.0/',
      './src/index.js'
    ];
    outputx = {
      ...outputx,
      path: path.resolve(__dirname, 'dist')
    };
    pluginx = [];
}

module.exports = {
    //mode: 'production',
    //baseUrl: 'https://eco.odb.ntu.edu.tw/',
    entry: entryx,
    devtool: devtoolx,
    /*entry: {
      popup: './src/index.js',
    },*/
    output: outputx,
    node: {
      // Resolve node module use of fs
      fs: 'empty',
      net: 'empty',
      tls: 'empty',
      Buffer: false,
      http: "empty",
      https: "empty",
      zlib: "empty"
    },
    resolve: {
      fallback: path.resolve(__dirname, '..', 'src'),
      extensions: ['.js', '.json', '.jsx', ''],
      mainFields: ['module', 'main'],
      alias: {
        "react": "preact-compat",
        "react-dom": "preact-compat"
      }
    },
    module: {
      rules: [
        {
          test: /\.(js|jsx)?$/,
          exclude: /(node_modules)/,
          use: {
            loader: 'babel-loader',
            options: {
              presets: ['@babel/preset-env'],
            }
          }
        },
        {
          test: /\.tsx?$/,
          use: 'ts-loader',
          exclude: /node_modules/,
        },
        {
          test: /\.less$/,
          loader: 'less-loader', // compiles Less to CSS
        },
        {
          test: /\.css$/,
           use: ExtractTextPlugin.extract({
             fallback: 'style-loader',
             use: [
               {
                 loader: 'css-loader',
               },
             ],
           }),
          include: /node_modules[/\\]react-dropdown-tree-select/,
        },
        {
            test: /\.(scss|sass)$/,
            use: [
              {
                loader: 'style-loader'
              },
              {
                loader: 'css-loader',
                options: {
                  modules: true
                }
              },
              {
                loader: 'sass-loader'
              }
            ]
          },
      ]
    },
    devServer: {
      contentBase: path.join(__dirname, 'dist'),
      https: true,
      host : '0.0.0.0',
      //host: 'localhost',
      port: process.env.PORT || 3000,
      sockHost: '0.0.0.0',
      sockPort: '',
      transportMode: {
        client: 'ws',
      },
      proxy: {
        '**': {
          target: `https://127.0.0.1:${process.env.PORT}`,
          // context: () => true, //https://webpack.js.org/configuration/dev-server/#devserverproxy
          changeOrigin: true,
          ws: true,
        }
      },
      hot: true,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Origin, X-Requested-With, Content-Type, Accept'
      },
      //historyApiFallback: {
      //  disableDotRule: true
      //},
      public : 'eco.odb.ntu.edu.tw',
      publicPath: '/',
      disableHostCheck: true,
      quiet: false,
      inline: true,
      //compress: true
    },
    optimization: optimizex,
    plugins: pluginx
  };
