import request from './request'

export function createResume(data) {
  return request.post('/resume', data)
}

export function listResumes() {
  return request.get('/resumes')
}

export function getResume(id) {
  return request.get(`/resume/${id}`)
}

export function updateResumeTitle(id, title) {
  return request.put(`/resume/${id}/title`, { title })
}

export function deleteResume(id) {
  return request.delete(`/resume/${id}`)
}

export function exportHtml(id) {
  return request.get(`/resume/${id}/export/html`)
}

export function exportJson(id) {
  return request.get(`/resume/${id}/export/json`)
}
