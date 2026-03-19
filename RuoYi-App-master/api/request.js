import config from '@/config'
import request from '@/utils/request'
import { getToken } from '@/utils/auth'

// 统一导出业务请求函数，便于后续独立扩展 App 业务拦截逻辑。
export default request

// 封装文件上传，兼容微信小程序与 H5。
export function uploadFile(filePath, formData = {}) {
  return new Promise((resolve, reject) => {
    uni.uploadFile({
      url: config.baseUrl + '/common/upload',
      filePath,
      name: 'file',
      formData,
      header: {
        Authorization: 'Bearer ' + getToken()
      },
      success: (response) => {
        const data = JSON.parse(response.data || '{}')
        if (data.code !== 200) {
          uni.showToast({
            title: data.msg || '上传失败',
            icon: 'none'
          })
          reject(data)
          return
        }
        resolve(data)
      },
      fail: (error) => {
        uni.showToast({
          title: '上传失败，请稍后重试',
          icon: 'none'
        })
        reject(error)
      }
    })
  })
}
