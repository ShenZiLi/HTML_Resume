import request from './request'

export function addModule(data) {
  return request.post('/modules', data)
}

export function updateModuleContent(id, content) {
  return request.put(`/modules/${id}/content`, { content })
}

export function deleteModule(id) {
  return request.delete(`/modules/${id}`)
}

export function batchUpdateSort(resumeId, modules) {
  return request.put('/modules/sort', {
    resume_id: resumeId,
    modules: modules.map(m => ({ id: m.id, sortOrder: m.sortOrder }))
  })
}

export function getModuleConfig(moduleType) {
  return request.get(`/module-config/${moduleType}`)
}
