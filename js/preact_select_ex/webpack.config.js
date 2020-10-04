const path = require('path');
module.exports = {
    mode: 'production',
    entry: {
      popup: './src/index.js',
    },
    output: {
      filename: '[name].js',
      path: __dirname + '/dist'
    },
    resolve: {
      extensions: ['.js', '.jsx'],
      alias: {
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
                loader: 'css-loader'
              },
              {
                loader: 'sass-loader'
              }
            ]
          },
      ]
    }
  };
