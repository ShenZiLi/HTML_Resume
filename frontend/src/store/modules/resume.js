import { defineStore } from 'pinia'
import { getResume, createResume } from '../../api/resume'

export const useResumeStore = defineStore('resume', {
  state: () => ({
    currentResume: null,
    modules: [],
    moduleConfigs: [],
    selectedModuleId: null
  }),

  actions: {
    async initOrRestore() {
      const savedId = localStorage.getItem('resume_id')

      if (savedId) {
        try {
          await this.loadResume(Number(savedId))
          this.autoSelectFirstModule()
          return
        } catch {
          localStorage.removeItem('resume_id')
        }
      }

      try {
        const resume = await createResume({ title: '未命名简历' })
        localStorage.setItem('resume_id', String(resume.id))
        await this.loadResume(resume.id)
        this.autoSelectFirstModule()
      } catch (error) {
        console.error('初始化简历失败:', error)
      }
    },

    async loadResume(id) {
      try {
        const data = await getResume(id)
        this.currentResume = data.resume || data
        this.modules = data.modules || []
        this.moduleConfigs = data.moduleConfigs || []
        localStorage.setItem('resume_id', String(id))
      } catch (error) {
        console.error('加载简历失败:', error)
        throw error
      }
    },

    autoSelectFirstModule() {
      if (this.modules.length > 0) {
        this.selectedModuleId = this.modules[0].id
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
      if (this.selectedModuleId === id) {
        this.autoSelectFirstModule()
      }
    },

    reorderModules({ oldIndex, newIndex }) {
      const [removed] = this.modules.splice(oldIndex, 1)
      this.modules.splice(newIndex, 0, removed)
    }
  },

  getters: {
    selectedModule: (state) => {
      if (!state.selectedModuleId) return null
      return state.modules.find((m) => m.id === state.selectedModuleId) || null
    }
  }
})
