// utils/request.js
import config from '@/config'
import { tansParams } from '@/utils/common'
import { getToken, removeToken } from '@/utils/auth'
const baseUrl = config.baseUrl

/**
 * 通用请求方法（适配若依后端 + @InnerAuth 权限）
 * 兼容两种调用方式：
 * 1. request('/path', 'GET', data, headers)
 * 2. request({ url, method, data, headers, timeout })
 * @returns Promise
 */
export const request = (urlOrOptions, method = 'GET', data = {}, headers = {}) => {
  const options = typeof urlOrOptions === 'object' && urlOrOptions !== null
    ? {
        url: urlOrOptions.url || '',
        method: urlOrOptions.method || 'GET',
        data: urlOrOptions.data || {},
        params: urlOrOptions.params || null,
        headers: {
          ...(urlOrOptions.headers || {}),
          ...(urlOrOptions.header || {})
        },
        timeout: urlOrOptions.timeout || 10000
      }
    : {
        url: urlOrOptions || '',
        method,
        data,
        params: null,
        headers,
        timeout: 10000
      }

  if (options.params) {
    const queryString = tansParams(options.params)
    if (queryString) {
      const separator = options.url.includes('?') ? '&' : '?'
      options.url = `${options.url}${separator}${queryString.slice(0, -1)}`
    }
  }

  const token = getToken() || ''
  const requestHeaders = {
    'Content-Type': 'application/json',
    ...(options.headers || {})
  }

  const isToken = requestHeaders.isToken === false
  if (!isToken && token) {
    requestHeaders.Authorization = requestHeaders.Authorization || `Bearer ${token}`
  }
  delete requestHeaders.isToken

  return new Promise((resolve, reject) => {
    uni.request({
      url: baseUrl + options.url,
      method: (options.method || 'GET').toUpperCase(),
      data: options.data,
      header: requestHeaders,
      timeout: options.timeout,
      success: (res) => {
        if (typeof res.data !== 'object') {
          uni.showToast({ title: '后端返回格式错误', icon: 'none' })
          reject({ msg: '返回格式非JSON' })
          return
        }

        if (res.data.code === 200) {
          resolve(res.data)
          return
        }

        if (res.data.code === 401) {
          uni.showToast({ title: '登录已过期，请重新登录', icon: 'none' })
          removeToken()
          uni.removeStorageSync('userInfo')
          uni.navigateTo({ url: '/pages/profile/login' })
          reject({
            code: res.data.code,
            msg: res.data.msg || 'Token无效/过期'
          })
          return
        }

        if (res.data.code === 403) {
          uni.showToast({ title: '没有访问权限', icon: 'none' })
          reject({
            code: res.data.code,
            msg: res.data.msg || '没有访问权限'
          })
          return
        }

        uni.showToast({
          title: res.data.msg || '操作失败',
          icon: 'none',
          duration: 2000
        })
        reject({
          code: res.data.code,
          msg: res.data.msg || '操作失败'
        })
      },
      fail: (err) => {
        let errMsg = ''
        if (err.errMsg.includes('connect fail') || err.errMsg.includes('timeout')) {
          errMsg = `后端服务未启动或地址错误：${baseUrl}`
        } else if (err.statusCode === 404) {
          errMsg = '接口不存在：' + options.url
        } else if (err.statusCode === 500) {
          errMsg = '后端接口报错，请查看控制台'
        } else {
          errMsg = '网络错误：' + err.errMsg
        }

        uni.showToast({
          title: errMsg,
          icon: 'none',
          duration: 3000
        })
        reject({
          ...err,
          msg: errMsg
        })
      },
      complete: () => {}
    });
  })
}

export const get = (url, data, headers) => request(url, 'GET', data, headers)
export const post = (url, data, headers) => request(url, 'POST', data, headers)
export const put = (url, data, headers) => request(url, 'PUT', data, headers)
export const del = (url, data, headers) => request(url, 'DELETE', data, headers)

export default request
