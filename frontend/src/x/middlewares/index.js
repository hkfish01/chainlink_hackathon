const files = require.context('.', false, /\.js$/)
const middlewawres = []
files.keys().forEach(key => {
  if (key === './index.js') return
  middlewawres.push(files(key).default)
})
export default middlewawres