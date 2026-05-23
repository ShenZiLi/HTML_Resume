import request from './request'

export function listStyles() {
  return request.get('/styles')
}

export function getStyle(id) {
  return request.get(`/style/${id}`)
}

export function switchStyle(resumeId, styleId) {
  return request.post(`/resume/${resumeId}/style`, { styleId })
}

export function saveStyleConfig(id, config) {
  return request.put(`/style/${id}/config`, { config })
}
