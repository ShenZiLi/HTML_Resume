import { defineStore } from 'pinia'
import { listStyles, switchStyle as apiSwitchStyle } from '../../api/style'

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
