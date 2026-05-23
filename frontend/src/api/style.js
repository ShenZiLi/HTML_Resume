import request from './request'

export function listStyles() {
  return request.get('/styles')
}

export function getStyle(id) {
  return request.get(`/styles/${id}`)
}

export function switchStyle(resumeId, styleId) {
  return request.put(`/resumes/${resumeId}/style/${styleId}`)
}

export function saveStyleConfig(id, config) {
  return request.put(`/resumes/${id}/style-config`, { styleConfig: config })
}

export function updateStyleContent(id, cssContent) {
  return request.put(`/styles/${id}/content`, { cssContent })
}
