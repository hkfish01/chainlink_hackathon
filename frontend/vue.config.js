const { defineConfig } = require('@vue/cli-service')
const NodePolyfillPlugin = require("node-polyfill-webpack-plugin");

module.exports = defineConfig({
  transpileDependencies: true,
  // publicPath: '/whiskyrwa',
  publicPath: '/',
  chainWebpack: config =>{
    config.plugin('html').tap(args => {
      args[0].title = '';
      return args;
    })
  },
  configureWebpack: {
    plugins: [new NodePolyfillPlugin()],
    optimization: {
      splitChunks: {
        chunks: "all",
      },
    },
  },
  css: {
    loaderOptions: {
      postcss: {
        postcssOptions: {
          plugins: [require('tailwindcss'), require('autoprefixer')]
        }
      }
    }
  },
  devServer: {
    proxy: {
      '/prod-api': {
        target : 'http://116.196.89.134:8080',
        changeOrigin : true
      },
    },
  }
})
