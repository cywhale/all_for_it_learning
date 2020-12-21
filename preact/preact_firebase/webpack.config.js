const path = require('path');
// mode
const testenv = {NODE_ENV: process.env.NODE_ENV};
var entryx;

if (testenv.NODE_ENV === "production") {
    console.log("Node env in production...");
    //config.devtool = false;
    entryx = [
      //require.resolve('./polyfills'),
      './src/index.js'
    ];
  } else {
    console.log("Node env in development...");

    entryx = [
      'webpack-dev-server/client?https://0.0.0.0/',
      './src/index.js'
    ];
}

module.exports = {
    //mode: 'production',
    //baseUrl: 'https://eco.odb.ntu.edu.tw/',
    entry: entryx,
    /*entry: {
      popup: './src/index.js',
    },*/
    output: {
      filename: '[name].js',
      path: __dirname + '/dist'
    },
    resolve: {
        extensions: ['.js', '.jsx', '.scss' , '.css'],
        alias: {
           //'firebaseImport$': path.join('src', 'components', 'firebaseImport.browser.js'),
           "react": "preact/compat",
           "react-dom": "preact/compat"
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
    }
  };
