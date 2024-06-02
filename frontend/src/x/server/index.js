import Base from './base'
const files = require.context('./apis', false, /\.js$/)
const apis = new Base()
files.keys().forEach(key => {
  let filename = key.substring(key.lastIndexOf('/') + 1, key.lastIndexOf('.'))
  apis[filename] = files(key).default
})
export default apis
