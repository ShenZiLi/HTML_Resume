import { defineStore } from 'pinia'
import { getResume } from '../../api/resume'

export const useResumeStore = defineStore('resume', {
  state: () => ({
    currentResume: null,
    modules: [],
    moduleConfigs: []
  }),

  actions: {
    async loadResume(id) {
      try {
        const data = await getResume(id)
        this.currentResume = data
        this.modules = data.modules || []
        this.moduleConfigs = data.moduleConfigs || []
      } catch (error) {
        console.error('加载简历失败:', error)
        throw error
      }
    },

    addModule(module) {
      this.modules.push(module)
    },

    updateModule(id, updates) {
      const index = this.modules.findIndex((m) => m.id === id)
      if (index !== -1) {
        this.modules[index] = { ...this.modules[index], ...updates }
      }
    },

    deleteModule(id) {
      const index = this.modules.findIndex((m) => m.id === id)
      if (index !== -1) {
        this.modules.splice(index, 1)
      }
    },

    reorderModules({ oldIndex, newIndex }) {
      const [removed] = this.modules.splice(oldIndex, 1)
      this.modules.splice(newIndex, 0, removed)
    }
  }
})
