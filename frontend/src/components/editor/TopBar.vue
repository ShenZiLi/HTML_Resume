<template>
  <div class="top-bar">
    <div class="top-bar-left">
      <el-select
        v-model="currentResumeId"
        class="resume-selector"
        popper-class="resume-selector-dropdown"
        size="small"
        placeholder="选择简历"
        @change="handleResumeSwitch"
      >
        <el-option
          v-for="r in resumeStore.resumeList"
          :key="r.id"
          :label="r.title || '未命名简历'"
          :value="r.id"
        >
          <span class="resume-option-label">{{ r.title || '未命名简历' }}</span>
          <span class="resume-option-delete" @click.stop="handleDeleteResume(r)">✕</span>
        </el-option>
      </el-select>

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
      <el-dropdown size="small" @command="handleExportCommand">
        <el-button size="small" type="primary">
          导出 <el-icon class="el-icon--right"><arrow-down /></el-icon>
        </el-button>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item command="html">导出 HTML</el-dropdown-item>
            <el-dropdown-item command="markdown">导出 Markdown</el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
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
        >
          <span class="style-option-label">{{ style.name }}</span>
          <span
            v-if="!style.isBuiltin"
            class="style-option-delete"
            @click.stop="handleDeleteStyle(style)"
          >✕</span>
        </el-option>
      </el-select>

      <el-button size="small" @click="showNewStyleDialog">新建样式</el-button>
    </div>

    <el-dialog
      v-model="newStyleDialogVisible"
      title="新建样式"
      width="600px"
      :close-on-click-modal="false"
    >
      <el-form label-position="top">
        <el-form-item label="样式名称">
          <el-input
            v-model="newStyleForm.name"
            placeholder="请输入样式名称"
          />
        </el-form-item>
        <el-form-item label="初始 CSS 内容">
          <el-input
            v-model="newStyleForm.cssContent"
            type="textarea"
            :rows="15"
            placeholder="请输入初始 CSS 内容（留空将使用默认模板）"
            class="css-input"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="newStyleDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleCreateStyle">创建</el-button>
      </template>
    </el-dialog>

  </div>
</template>

<script setup>
import { ref, watch, computed } from 'vue'
import { useResumeStore } from '../../store/modules/resume'
import { useStyleStore } from '../../store/modules/style'
import { createResume, updateResumeTitle, deleteResume as apiDeleteResume, exportHtml } from '../../api/resume'
import { generateMarkdown } from '../../utils/markdownGenerator'
import { ElMessage, ElMessageBox } from 'element-plus'
import { ArrowDown } from '@element-plus/icons-vue'

const resumeStore = useResumeStore()
const styleStore = useStyleStore()

const titleInput = ref('')
const selectedStyleId = ref(null)
const newStyleDialogVisible = ref(false)
const newStyleForm = ref({
  name: '',
  cssContent: ''
})

const defaultCssTemplate = `:root {
    --primary: #6366F1;
    --primary-light: #EDE9FE;
    --dark: #1E1B4B;
    --gray: #64748B;
    --light-gray: #F5F3FF;
    --white: #FFFFFF;
    --border: #E0E7FF;
}

* { margin: 0; padding: 0; box-sizing: border-box; }

body {
    font-family: 'Inter', sans-serif;
    background-color: #FAFAFA;
    color: var(--dark);
    line-height: 1.6;
    padding: 2rem;
}

.resume {
    max-width: 960px;
    margin: 0 auto;
    background: var(--white);
    border-radius: 12px;
    box-shadow: 0 10px 30px rgba(0,0,0,0.08);
    overflow: hidden;
}

header {
    background: linear-gradient(135deg, var(--primary), #1D4ED8);
    color: var(--white);
    padding: 2.5rem 2rem;
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 1.5rem;
}

.header-content { flex: 1; display: flex; flex-direction: column; gap: 0.5rem; }

.name { font-size: 2rem; font-weight: 700; }

.section { padding: 2rem; border-bottom: 1px solid var(--border); }
.section:last-child { border-bottom: none; }
.section-title { font-size: 1.375rem; font-weight: 600; color: var(--primary); margin-bottom: 1.25rem; }
`

const currentResumeId = computed({
  get: () => resumeStore.currentResume?.id || null,
  set: () => {}
})

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

async function handleResumeSwitch(resumeId) {
  try {
    await resumeStore.switchResume(resumeId)
    styleStore.loadStyles()
  } catch (error) {
    ElMessage.error('切换简历失败')
  }
}

async function handleDeleteResume(resume) {
  try {
    await ElMessageBox.confirm(
      `确定要删除简历「${resume.title || '未命名简历'}」吗？此操作不可撤销。`,
      '删除确认',
      { confirmButtonText: '删除', cancelButtonText: '取消', type: 'warning' }
    )
  } catch {
    return
  }

  try {
    await apiDeleteResume(resume.id)
    ElMessage.success('简历已删除')

    const isCurrent = resumeStore.currentResume?.id === resume.id
    await resumeStore.loadResumeList()

    if (isCurrent) {
      if (resumeStore.resumeList.length > 0) {
        await resumeStore.switchResume(resumeStore.resumeList[0].id)
      } else {
        const newResume = await createResume({ title: '未命名简历' })
        await resumeStore.loadResumeList()
        await resumeStore.loadResume(newResume.id)
        resumeStore.autoSelectFirstModule()
      }
      styleStore.loadStyles()
    }
  } catch (error) {
    ElMessage.error('删除简历失败')
  }
}

async function handleNewResume() {
  try {
    const resume = await createResume({ title: '未命名简历' })
    ElMessage.success('新建简历成功')
    await resumeStore.loadResumeList()
    await resumeStore.loadResume(resume.id)
    resumeStore.autoSelectFirstModule()
    styleStore.loadStyles()
  } catch (error) {
    ElMessage.error('新建简历失败')
  }
}

function handleExportCommand(command) {
  switch (command) {
    case 'html':
      handleExportHtml()
      break
    case 'markdown':
      handleExportMarkdown()
      break
  }
}

async function handleExportHtml() {
  if (!resumeStore.currentResume) {
    ElMessage.warning('请先加载简历')
    return
  }
  try {
    const html = await exportHtml(resumeStore.currentResume.id)
    const blob = new Blob([html], { type: 'text/html' })
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

function handleExportMarkdown() {
  if (!resumeStore.currentResume) {
    ElMessage.warning('请先加载简历')
    return
  }
  try {
    const md = generateMarkdown(resumeStore.currentResume, resumeStore.modules)
    const blob = new Blob([md], { type: 'text/markdown' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `${resumeStore.currentResume.title || '简历'}.md`
    a.click()
    URL.revokeObjectURL(url)
    ElMessage.success('导出 Markdown 成功')
  } catch (error) {
    ElMessage.error('导出 Markdown 失败')
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

function showNewStyleDialog() {
  newStyleForm.value = {
    name: '',
    cssContent: defaultCssTemplate
  }
  newStyleDialogVisible.value = true
}

async function handleCreateStyle() {
  if (!newStyleForm.value.name.trim()) {
    ElMessage.warning('请输入样式名称')
    return
  }

  try {
    const newStyle = await styleStore.addStyle({
      name: newStyleForm.value.name.trim(),
      cssContent: newStyleForm.value.cssContent || defaultCssTemplate
    })
    ElMessage.success('样式创建成功')
    newStyleDialogVisible.value = false

    if (!selectedStyleId.value) {
      selectedStyleId.value = newStyle.id
    }
  } catch (error) {
    ElMessage.error('创建样式失败')
  }
}

async function handleDeleteStyle(style) {
  try {
    await ElMessageBox.confirm(
      `确定要删除样式「${style.name}」吗？此操作不可撤销。`,
      '删除确认',
      { confirmButtonText: '删除', cancelButtonText: '取消', type: 'warning' }
    )
  } catch {
    return
  }

  try {
    const isCurrent = styleStore.currentStyle?.id === style.id
    await styleStore.removeStyle(style.id)
    ElMessage.success('样式已删除')

    if (isCurrent && styleStore.currentStyle) {
      selectedStyleId.value = styleStore.currentStyle.id
      if (resumeStore.currentResume) {
        await styleStore.switchStyle(resumeStore.currentResume.id, styleStore.currentStyle.id)
      }
    }
  } catch (error) {
    if (error?.response?.data?.message) {
      ElMessage.error(error.response.data.message)
    } else {
      ElMessage.error('删除样式失败')
    }
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

.resume-selector {
  width: 160px;
  flex-shrink: 0;
}

.resume-selector :deep(.el-input__wrapper) {
  background: var(--color-muted);
  border: 1px solid transparent;
  transition: border-color var(--transition-fast);
}

.resume-selector :deep(.el-input__wrapper:hover),
.resume-selector :deep(.el-input__wrapper.is-focus) {
  border-color: var(--color-primary);
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

<style>
.resume-selector-dropdown .el-select-dropdown__item {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.resume-option-label {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.resume-option-delete {
  padding: 0 4px;
  font-size: 12px;
  color: #64748b;
  border-radius: 6px;
  transition: color 150ms ease, background 150ms ease;
  line-height: 1;
}

.resume-option-delete:hover {
  color: #ef4444;
  background: rgba(239, 68, 68, 0.08);
}

.style-option-label {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.style-option-delete {
  padding: 0 4px;
  font-size: 12px;
  color: #64748b;
  border-radius: 6px;
  transition: color 150ms ease, background 150ms ease;
  line-height: 1;
}

.style-option-delete:hover {
  color: #ef4444;
  background: rgba(239, 68, 68, 0.08);
}

.css-input :deep(.el-textarea__inner) {
  font-family: 'JetBrains Mono', 'Fira Code', 'Consolas', 'Monaco', monospace;
  font-size: 13px;
  line-height: 1.5;
}
</style>
