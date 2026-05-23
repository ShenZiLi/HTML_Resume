import axios from 'axios'
import { getUserId } from '../utils/deviceId'

// 暂未实现用户注册登录功能，当前写死 userId 为 1
const request = axios.create({
  baseURL: '/api/v1',
  timeout: 10000
})

request.interceptors.request.use(
  (config) => {
    config.headers['X-User-Id'] = getUserId()
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

request.interceptors.response.use(
  (response) => {
    if (response.config.responseType === 'text' || response.config.responseType === 'blob') {
      return response.data
    }
    const result = response.data
    if (result && result.code === 200) {
      return result.data
    }
    return Promise.reject(new Error(result?.message || '请求失败'))
  },
  (error) => {
    if (error.response) {
      const { status, data } = error.response
      switch (status) {
        case 400:
          console.error('请求参数错误:', data.message)
          break
        case 401:
          console.error('未授权，请重新登录')
          break
        case 403:
          console.error('拒绝访问')
          break
        case 404:
          console.error('请求资源不存在')
          break
        case 500:
          console.error('服务器内部错误')
          break
        default:
          console.error(`请求失败: ${data.message || '未知错误'}`)
      }
    } else if (error.request) {
      console.error('网络错误，请检查网络连接')
    } else {
      console.error('请求配置错误:', error.message)
    }
    return Promise.reject(error)
  }
)

export default request
