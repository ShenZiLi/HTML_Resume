<template>
  <div class="preview-panel">
    <div class="panel-tabs">
      <span
        class="tab"
        :class="{ active: activeTab === 'preview' }"
        @click="activeTab = 'preview'"
      >
        HTML预览
      </span>
      <span
        class="tab"
        :class="{ active: activeTab === 'html' }"
        @click="activeTab = 'html'"
      >
        HTML源码
      </span>
      <span
        class="tab"
        :class="{ active: activeTab === 'css' }"
        @click="activeTab = 'css'"
      >
        CSS编辑
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

      <div v-show="activeTab === 'html'" class="html-viewer-container">
        <div class="html-viewer-header">
          <span class="html-viewer-title">HTML 源码</span>
          <el-button size="small" @click="copyHtml">复制</el-button>
        </div>
        <pre class="html-viewer"><code>{{ htmlPreview }}</code></pre>
      </div>

      <div v-show="activeTab === 'css'" class="css-editor-container">
        <div class="css-header">
          <span class="css-label">CSS 源码</span>
          <span class="save-status" :class="{ 'has-status': cssSaveStatus }">{{ cssSaveStatus }}</span>
        </div>
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
import { ElMessage } from 'element-plus'
import { useResumeStore } from '../../store/modules/resume'
import { useStyleStore } from '../../store/modules/style'
import { generateHtml } from '../../utils/htmlGenerator'
import { saveContext } from '../../api/resume'
import { updateStyleContent as apiUpdateStyleContent } from '../../api/style'

const resumeStore = useResumeStore()
const styleStore = useStyleStore()

const activeTab = ref('preview')
const previewIframe = ref(null)
const cssContent = ref('')
const cssSaveStatus = ref('')

let cssSaveTimer = null
let contextSaveTimer = null

watch(
  () => styleStore.currentStyle,
  (style) => {
    if (style) {
      cssContent.value = style.cssContent || ''
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
  saveContextDebounced()
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

function saveContextDebounced() {
  if (contextSaveTimer) clearTimeout(contextSaveTimer)
  contextSaveTimer = setTimeout(() => {
    if (resumeStore.currentResume && htmlPreview.value) {
      saveContext(resumeStore.currentResume.id, htmlPreview.value).catch(() => {})
    }
  }, 2000)
}

function onCssChange() {
  cssSaveStatus.value = ''
  if (cssSaveTimer) clearTimeout(cssSaveTimer)

  cssSaveTimer = setTimeout(() => {
    if (styleStore.currentStyle) {
      styleStore.currentStyle.cssContent = cssContent.value
      updatePreview()
      saveCssToDb()
    }
  }, 1000)
}

async function saveCssToDb() {
  if (!styleStore.currentStyle) return
  try {
    await apiUpdateStyleContent(styleStore.currentStyle.id, cssContent.value)
    cssSaveStatus.value = '已保存'
  } catch {
    cssSaveStatus.value = '保存失败'
  }
}

async function copyHtml() {
  try {
    await navigator.clipboard.writeText(htmlPreview.value)
    ElMessage.success('HTML 已复制到剪贴板')
  } catch {
    ElMessage.error('复制失败')
  }
}
</script>

<style scoped>
.preview-panel {
  display: flex;
  flex-direction: column;
  height: 100%;
  background: var(--color-card);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.panel-tabs {
  display: flex;
  border-bottom: 1px solid var(--color-border);
  background: var(--color-muted);
  padding: 0 4px;
}

.tab {
  flex: 1;
  text-align: center;
  padding: 10px 0;
  font-size: 13px;
  font-weight: 500;
  color: var(--color-muted-foreground);
  cursor: pointer;
  transition: color var(--transition-fast), background var(--transition-fast), border-color var(--transition-fast);
  border-bottom: 2px solid transparent;
  border-radius: var(--radius-sm) var(--radius-sm) 0 0;
  letter-spacing: 0.02em;
}

.tab:hover {
  color: var(--color-primary);
  background: rgba(99, 102, 241, 0.04);
}

.tab.active {
  color: var(--color-primary);
  background: var(--color-card);
  border-bottom-color: var(--color-primary);
}

.panel-content {
  flex: 1;
  overflow: hidden;
}

.preview-container {
  height: 100%;
  display: flex;
  flex-direction: column;
  padding: 12px;
  background: var(--color-muted);
}

.preview-iframe {
  flex: 1;
  width: 100%;
  border: none;
  border-radius: var(--radius-md);
  background: var(--color-card);
  box-shadow: var(--shadow-md);
}

.html-viewer-container {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.html-viewer-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 12px;
  border-bottom: 1px solid var(--color-border);
  background: var(--color-muted);
}

.html-viewer-title {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-muted-foreground);
}

.html-viewer {
  flex: 1;
  overflow: auto;
  margin: 0;
  padding: 16px;
  background: #1e293b;
  color: #e2e8f0;
  font-family: 'JetBrains Mono', 'Fira Code', 'Consolas', 'Monaco', monospace;
  font-size: 12px;
  line-height: 1.7;
  white-space: pre-wrap;
  word-wrap: break-word;
}

.css-editor-container {
  height: 100%;
  display: flex;
  flex-direction: column;
  padding: 0;
}

.css-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 12px;
  border-bottom: 1px solid var(--color-border);
  background: var(--color-muted);
}

.css-label {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-muted-foreground);
}

.save-status {
  font-size: 12px;
  color: transparent;
  transition: color var(--transition-fast);
}

.save-status.has-status {
  color: var(--color-success);
}

.css-editor-container :deep(.el-textarea__inner) {
  flex: 1;
  font-family: 'JetBrains Mono', 'Fira Code', 'Consolas', 'Monaco', monospace;
  font-size: 13px;
  line-height: 1.7;
  background: var(--color-foreground);
  color: #e2e8f0;
  border-radius: 0;
  border: none;
  padding: 16px;
}

.css-editor-container :deep(.el-textarea__inner):focus {
  border-color: var(--color-primary);
  box-shadow: 0 0 0 2px rgba(99, 102, 241, 0.15);
}
</style>
