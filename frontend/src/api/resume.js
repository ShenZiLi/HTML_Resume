import request from './request'

export function createResume(data) {
  return request.post('/resumes', data)
}

export function listResumes() {
  return request.get('/resumes')
}

export function getResume(id) {
  return request.get(`/resumes/${id}`)
}

export function updateResumeTitle(id, title) {
  return request.put(`/resumes/${id}/title`, { title })
}

export function deleteResume(id) {
  return request.delete(`/resumes/${id}`)
}

export function exportHtml(id) {
  return request.get(`/resumes/${id}/export/html`, { responseType: 'text' })
}

export function exportJson(id) {
  return request.get(`/resumes/${id}`)
}
