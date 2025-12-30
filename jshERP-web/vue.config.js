const path = require('path')
const CompressionPlugin = require('compression-webpack-plugin')

function resolve (dir) {
  return path.join(__dirname, dir)
}

// vue.config.js
module.exports = {
  // Si vous n'avez pas besoin du source map en production, vous pouvez le définir sur false pour accélérer la construction en production.
  productionSourceMap: false,
  configureWebpack: (config) => {
    // Supprimer console.log en production
    if (process.env.NODE_ENV === 'production') {
      config.optimization.minimizer[0].options.terserOptions.compress.drop_console = true
    }
  },
  chainWebpack: (config) => {
    config.resolve.alias
      .set('@$', resolve('src'))
      .set('@api', resolve('src/api'))
      .set('@assets', resolve('src/assets'))
      .set('@comp', resolve('src/components'))
      .set('@views', resolve('src/views'))
    // Environnement de production, activer la compression js\css
    if (process.env.NODE_ENV === 'production') {
      config.plugin('compressionPlugin').use(
        new CompressionPlugin({
          test: /\.(js|css|less)$/, // Correspondre aux noms de fichiers
          threshold: 10240, // Compresser les données supérieures à 10k
          deleteOriginalAssets: false // Supprimer les fichiers sources
        })
      )
    }
  },
  css: {
    loaderOptions: {
      less: {
        modifyVars: {
          /* Remplacement des variables less, utilisé pour personnaliser le thème ant design */
          'primary-color': '#1890FF',
          'link-color': '#1890FF',
          'border-radius-base': '4px'
        },
        javascriptEnabled: true
      }
    }
  },
  devServer: {
    port: 3000,
    proxy: {
      '/jshERP-boot': {
        target: 'http://localhost:9999', // Requête locale, nécessite le projet backend jshERP-boot
        ws: false,
        changeOrigin: true
      }
    }
  },
  lintOnSave: undefined
}
