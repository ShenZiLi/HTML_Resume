import { defineStore } from 'pinia'
import { listStyles, switchStyle as apiSwitchStyle } from '../../api/style'
import { useResumeStore } from './resume'

export const useStyleStore = defineStore('style', {
  state: () => ({
    styles: [],
    currentStyle: null,
    customConfig: {}
  }),

  actions: {
    async loadStyles() {
      try {
        const data = await listStyles()
        this.styles = data
        if (data.length > 0 && !this.currentStyle) {
          const resumeStore = useResumeStore()
          const targetId = resumeStore.currentResume?.styleId
          const matched = targetId ? data.find((s) => s.id === targetId) : null
          this.currentStyle = matched || data[0]
        }
      } catch (error) {
        console.error('加载样式列表失败:', error)
        throw error
      }
    },

    async switchStyle(resumeId, styleId) {
      try {
        await apiSwitchStyle(resumeId, styleId)
        const style = this.styles.find((s) => s.id === styleId)
        if (style) {
          this.currentStyle = style
        }
      } catch (error) {
        console.error('切换样式失败:', error)
        throw error
      }
    }
  }
})
