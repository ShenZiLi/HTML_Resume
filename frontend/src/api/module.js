import request from './request'

export function addModule(data) {
  return request.post('/module', data)
}

export function updateModuleContent(id, content) {
  return request.put(`/module/${id}/content`, { content })
}

export function deleteModule(id) {
  return request.delete(`/module/${id}`)
}

export function batchUpdateSort(resumeId, modules) {
  return request.put('/modules/sort', { resume_id: resumeId, modules })
}

export function getModuleConfig(moduleType) {
  return request.get(`/module/config/${moduleType}`)
}
