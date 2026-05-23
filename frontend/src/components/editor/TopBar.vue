<template>
  <div class="top-bar">
    <div class="top-bar-left">
      <el-input
        v-if="resumeStore.currentResume"
        v-model="titleInput"
        class="title-input"
        size="small"
        @blur="saveTitle"
        @keyup.enter="saveTitle"
      />
      <span v-else class="title-placeholder">未加载简历</span>

      <el-button size="small" @click="handleNewResume">新建简历</el-button>
      <el-button size="small" @click="handleImport">导入</el-button>
      <el-button size="small" type="primary" @click="handleExportHtml">导出 HTML</el-button>
      <el-button size="small" type="primary" @click="handleExportJson">导出 JSON</el-button>
    </div>

    <div class="top-bar-right">
      <el-select
        v-model="selectedStyleId"
        placeholder="选择样式"
        size="small"
        style="width: 140px"
        @change="handleStyleChange"
      >
        <el-option
          v-for="style in styleStore.styles"
          :key="style.id"
          :label="style.name"
          :value="style.id"
        />
      </el-select>
    </div>

    <input ref="importInput" type="file" accept=".json" style="display: none" @change="handleFileImport" />
  </div>
</template>

<script setup>
import { ref, watch, computed } from 'vue'
import { useResumeStore } from '../../store/modules/resume'
import { useStyleStore } from '../../store/modules/style'
import { createResume, updateResumeTitle, exportHtml, exportJson } from '../../api/resume'
import { ElMessage } from 'element-plus'

const resumeStore = useResumeStore()
const styleStore = useStyleStore()
const importInput = ref(null)

const titleInput = ref('')
const selectedStyleId = ref(null)

watch(
  () => resumeStore.currentResume,
  (val) => {
    if (val) {
      titleInput.value = val.title || ''
    }
  },
  { immediate: true }
)

watch(
  () => styleStore.currentStyle,
  (val) => {
    if (val) {
      selectedStyleId.value = val.id
    }
  },
  { immediate: true }
)

async function saveTitle() {
  if (!resumeStore.currentResume) return
  const newTitle = titleInput.value.trim()
  if (!newTitle) return

  try {
    await updateResumeTitle(resumeStore.currentResume.id, newTitle)
    resumeStore.currentResume.title = newTitle
    ElMessage.success('标题已保存')
  } catch (error) {
    ElMessage.error('保存标题失败')
  }
}

async function handleNewResume() {
  try {
    const resume = await createResume({ title: '未命名简历' })
    ElMessage.success('新建简历成功')
    await resumeStore.loadResume(resume.id)
    resumeStore.autoSelectFirstModule()
    styleStore.loadStyles()
  } catch (error) {
    ElMessage.error('新建简历失败')
  }
}

function handleImport() {
  importInput.value?.click()
}

function handleFileImport(event) {
  const file = event.target.value
  if (!file) return

  const reader = new FileReader()
  reader.onload = (e) => {
    try {
      const data = JSON.parse(e.target.result)
      ElMessage.success('导入成功')
    } catch (error) {
      ElMessage.error('导入失败：文件格式错误')
    }
  }
  reader.readAsText(file)
  event.target.value = ''
}

async function handleExportHtml() {
  if (!resumeStore.currentResume) {
    ElMessage.warning('请先加载简历')
    return
  }
  try {
    const res = await exportHtml(resumeStore.currentResume.id)
    const blob = new Blob([res.data || res], { type: 'text/html' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `${resumeStore.currentResume.title || '简历'}.html`
    a.click()
    URL.revokeObjectURL(url)
    ElMessage.success('导出 HTML 成功')
  } catch (error) {
    ElMessage.error('导出 HTML 失败')
  }
}

async function handleExportJson() {
  if (!resumeStore.currentResume) {
    ElMessage.warning('请先加载简历')
    return
  }
  try {
    const res = await exportJson(resumeStore.currentResume.id)
    const data = res.data || res
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `${resumeStore.currentResume.title || '简历'}.json`
    a.click()
    URL.revokeObjectURL(url)
    ElMessage.success('导出 JSON 成功')
  } catch (error) {
    ElMessage.error('导出 JSON 失败')
  }
}

async function handleStyleChange(styleId) {
  if (!resumeStore.currentResume) return
  try {
    await styleStore.switchStyle(resumeStore.currentResume.id, styleId)
    ElMessage.success('样式已切换')
  } catch (error) {
    ElMessage.error('切换样式失败')
  }
}
</script>

<style scoped>
.top-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 100%;
  padding: 0 16px;
  font-size: 13px;
  color: var(--color-foreground);
  gap: 10px;
}

.top-bar-left {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: nowrap;
}

.title-input {
  width: 180px;
}

.title-input :deep(.el-input__wrapper) {
  background: var(--color-muted);
  border: 1px solid transparent;
  transition: border-color var(--transition-fast);
}

.title-input :deep(.el-input__wrapper:hover),
.title-input :deep(.el-input__wrapper.is-focus) {
  border-color: var(--color-primary);
}

.title-placeholder {
  color: var(--color-muted-foreground);
  margin-right: 8px;
  font-weight: 500;
}

.top-bar-right {
  display: flex;
  align-items: center;
  gap: 4px;
}
</style>
