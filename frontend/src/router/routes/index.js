const files = require.context('.', false, /\.js$/)
const routes = []
// console.log('files', files.keys())
files.keys().forEach(key => {
  if (key === './index.js') return
  // 如果是数组，表示是others的路由，所以需要解构添加
  if (files(key).default instanceof Array) {
    routes.push(...files(key).default)
  } else if (files(key).default instanceof Object) {
    routes.push(files(key).default)
  }
})

export default routes