<template>
  <div class="preview-panel">
    <div class="panel-tabs">
      <span
        class="tab"
        :class="{ active: activeTab === 'preview' }"
        @click="activeTab = 'preview'"
      >
        预览
      </span>
      <span
        class="tab"
        :class="{ active: activeTab === 'css' }"
        @click="activeTab = 'css'"
      >
        CSS 编辑器
      </span>
    </div>

    <div class="panel-content">
      <div v-show="activeTab === 'preview'" class="preview-container">
        <iframe
          ref="previewIframe"
          class="preview-iframe"
          title="简历预览"
          sandbox="allow-same-origin"
        />
      </div>

      <div v-show="activeTab === 'css'" class="css-editor-container">
        <el-input
          v-model="cssContent"
          type="textarea"
          :rows="30"
          placeholder="在此编辑 CSS..."
          @input="onCssChange"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, computed } from 'vue'
import { useResumeStore } from '../../store/modules/resume'
import { useStyleStore } from '../../store/modules/style'
import { generateHtml } from '../../utils/htmlGenerator'

const resumeStore = useResumeStore()
const styleStore = useStyleStore()

const activeTab = ref('preview')
const previewIframe = ref(null)
const cssContent = ref('')

let cssSaveTimer = null

watch(
  () => styleStore.currentStyle,
  (style) => {
    if (style) {
      cssContent.value = style.css_content || ''
    }
  },
  { immediate: true }
)

const htmlPreview = computed(() => {
  return generateHtml(
    resumeStore.currentResume,
    resumeStore.modules,
    styleStore.currentStyle
  )
})

watch(htmlPreview, () => {
  if (activeTab.value === 'preview') {
    updatePreview()
  }
}, { deep: true })

watch(activeTab, (tab) => {
  if (tab === 'preview') {
    updatePreview()
  }
})

function updatePreview() {
  if (!previewIframe.value || !htmlPreview.value) return

  const iframe = previewIframe.value
  const doc = iframe.contentDocument || iframe.contentWindow.document
  doc.open()
  doc.write(htmlPreview.value)
  doc.close()
}

function onCssChange() {
  if (cssSaveTimer) clearTimeout(cssSaveTimer)

  cssSaveTimer = setTimeout(() => {
    if (styleStore.currentStyle) {
      styleStore.currentStyle.css_content = cssContent.value
      updatePreview()
    }
  }, 1000)
}
</script>

<style scoped>
.preview-panel {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.panel-tabs {
  display: flex;
  border-bottom: 1px solid #e5e7eb;
  background: #fafafa;
}

.tab {
  flex: 1;
  text-align: center;
  padding: 10px 0;
  font-size: 13px;
  color: #666;
  cursor: pointer;
  transition: all 0.2s;
  border-bottom: 2px solid transparent;
}

.tab:hover {
  color: #409eff;
}

.tab.active {
  color: #409eff;
  background: #fff;
  border-bottom-color: #409eff;
}

.panel-content {
  flex: 1;
  overflow: hidden;
}

.preview-container {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.preview-iframe {
  flex: 1;
  width: 100%;
  border: none;
  background: #fff;
}

.css-editor-container {
  height: 100%;
  padding: 12px;
}

.css-editor-container :deep(.el-textarea__inner) {
  height: 100%;
  font-family: 'Consolas', 'Monaco', monospace;
  font-size: 13px;
  line-height: 1.6;
}
</style>
