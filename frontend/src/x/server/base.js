import axios from 'axios'
// import store from '@/x/store'
import qs from 'qs'
// import { ElMessage } from 'element-plus'

const timeout = 60 * 60 * 1000 // 超时时间
class Base {
  /**
   * 构造器
   * @constructor
   * @param {object} [config={}] axios.create参数
   */
  constructor(config = {}) {
    this._http = axios.create(Object.assign({
      baseURL: this._getBaseURL(),
      timeout,
      withCredentials: false
    }, config))
    const defaults = this._defaultParams()
    this._http.interceptors.request.use(
      (request) => {
        if (request.method === 'get') {
          request.params = {
            ...defaults,
            ...request.params
          }
        } else {
          if(Object.prototype.toString.call(request.data) === '[object FormData]') {
            Object.keys(defaults).forEach((key) => {
              request.data.append(key, defaults[key])
            })
          } else {
            const data = qs.parse(request.data)
            request.data = {
              ...defaults,
              ...data
            }
          }
          console.error('request', request.data)
        }
        return request
      },
    )
    this._http.interceptors.response.use(function (res) {
      if(res.data && res.data.code === 401) {
        return res
      }
      // if(res.data && res.data.code !== 200) {
      //   ElMessage.error(res.data.msg)
      // }
      return res
    }, err => {
      if(err.response?.status === 401) {
      } else if(err.response?.status === 500) {
      }
    })
  }
  /**
   * 基础参数
   */
  _defaultParams () {
    // "0":中⽂，"1":繁体，"2":英⽂
    return {
      // language: '0'
      _t: new Date().getTime()
    }
  }
  /**
   * 获取基础URL
   * @returns {string}
   * @private
   */
  _getBaseURL() {
    return ''
  }
  /**
   * _handleResult
   * 需要返回非0弹出toast
   * @private
   */
  _handleResult(res = {}) {
    return res.data
  }
  /**
   * GET请求
   * @param url
   * @param params
   * @returns {PromiseLike<T> | Promise<T>}
   */
  get(url, params = {}, options) {
    return this._http.get(url, { params, ...options }).catch(e => {
      console.error("get", e)
    })
  }

  /**
   * POST请求
   * @param url
   * @param params
   * @returns {PromiseLike<T> | Promise<T>}
   */
  post(url, params, options) {
    return this._http.post(url, params, options)
  }

  put(url, params, options) {
    return this._http.put(url, params, options)
  }

}

export default Base
