const ExtractTextPlugin = require('extract-text-webpack-plugin');

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
      extensions: ['.js', '.jsx', '.ts', '.tsx','.scss' , '.css'],
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
    }
  };
