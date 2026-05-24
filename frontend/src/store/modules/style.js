import { defineStore } from 'pinia'
import { listStyles, switchStyle as apiSwitchStyle, createStyle as apiCreateStyle, deleteStyle as apiDeleteStyle } from '../../api/style'
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
    },

    async addStyle(data) {
      try {
        const newStyle = await apiCreateStyle(data)
        this.styles.push(newStyle)
        return newStyle
      } catch (error) {
        console.error('创建样式失败:', error)
        throw error
      }
    },

    async removeStyle(styleId) {
      try {
        await apiDeleteStyle(styleId)
        const index = this.styles.findIndex((s) => s.id === styleId)
        if (index !== -1) {
          this.styles.splice(index, 1)
        }
        if (this.currentStyle?.id === styleId) {
          this.currentStyle = this.styles.length > 0 ? this.styles[0] : null
        }
      } catch (error) {
        console.error('删除样式失败:', error)
        throw error
      }
    }
  }
})
