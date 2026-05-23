<template>
  <div class="editor-layout" ref="layoutRef">
    <TopBar class="top-bar" />
    <div class="main-content" ref="mainRef">
      <LeftPanel
        v-show="!leftCollapsed"
        ref="leftRef"
        class="left-panel"
        :style="{ width: leftPct + '%' }"
        :selected-module-id="resumeStore.selectedModuleId"
        @select="handleSelectModule"
      />
      <div
        class="resize-handle resize-handle-left"
        :class="{ collapsed: leftCollapsed }"
        @mousedown="startResize('left', $event)"
      >
        <button class="collapse-btn" @click.stop="toggleLeft">
          <span>{{ leftCollapsed ? '›' : '‹' }}</span>
        </button>
      </div>

      <EditPanel
        class="edit-panel"
        :selected-module="resumeStore.selectedModule"
      />

      <div
        class="resize-handle resize-handle-right"
        :class="{ collapsed: rightCollapsed }"
        @mousedown="startResize('right', $event)"
      >
        <button class="collapse-btn" @click.stop="toggleRight">
          <span>{{ rightCollapsed ? '‹' : '›' }}</span>
        </button>
      </div>
      <PreviewPanel
        v-show="!rightCollapsed"
        ref="rightRef"
        class="preview-panel"
        :style="{ width: rightPct + '%' }"
      />
    </div>
    <div v-if="isDragging" class="drag-overlay"></div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useResumeStore } from '../store/modules/resume'
import { useStyleStore } from '../store/modules/style'
import TopBar from '../components/editor/TopBar.vue'
import LeftPanel from '../components/editor/LeftPanel.vue'
import EditPanel from '../components/editor/EditPanel.vue'
import PreviewPanel from '../components/editor/PreviewPanel.vue'

const resumeStore = useResumeStore()
const styleStore = useStyleStore()

const layoutRef = ref(null)
const mainRef = ref(null)
const leftRef = ref(null)
const rightRef = ref(null)

const leftPct = ref(16)
const rightPct = ref(35)
const leftCollapsed = ref(false)
const rightCollapsed = ref(false)
const isDragging = ref(false)

const MIN_PCT = 10
const MAX_PCT = 80

let resizing = null
let startX = 0
let startPct = 0
let containerWidth = 0

function startResize(side, e) {
  if (e.target.closest('.collapse-btn')) return
  e.preventDefault()
  isDragging.value = true
  resizing = side
  startX = e.clientX
  startPct = side === 'left' ? leftPct.value : rightPct.value
  containerWidth = mainRef.value.offsetWidth
  document.addEventListener('mousemove', onResize)
  document.addEventListener('mouseup', stopResize)
  document.body.style.cursor = 'col-resize'
  document.body.style.userSelect = 'none'
}

function onResize(e) {
  if (!resizing || !containerWidth) return
  const deltaPx = e.clientX - startX
  const deltaPct = (deltaPx / containerWidth) * 100

  if (resizing === 'left') {
    const newPct = startPct + deltaPct
    const clamped = Math.min(MAX_PCT, Math.max(MIN_PCT, newPct))
    leftRef.value?.$el && (leftRef.value.$el.style.width = clamped + '%')
  } else {
    const newPct = startPct - deltaPct
    const clamped = Math.min(MAX_PCT, Math.max(MIN_PCT, newPct))
    rightRef.value?.$el && (rightRef.value.$el.style.width = clamped + '%')
  }
}

function stopResize() {
  if (resizing === 'left') {
    const el = leftRef.value?.$el
    if (el) {
      leftPct.value = parseFloat(el.style.width)
    }
  } else if (resizing === 'right') {
    const el = rightRef.value?.$el
    if (el) {
      rightPct.value = parseFloat(el.style.width)
    }
  }
  resizing = null
  isDragging.value = false
  document.removeEventListener('mousemove', onResize)
  document.removeEventListener('mouseup', stopResize)
  document.body.style.cursor = ''
  document.body.style.userSelect = ''
}

function toggleLeft() {
  leftCollapsed.value = !leftCollapsed.value
}

function toggleRight() {
  rightCollapsed.value = !rightCollapsed.value
}

function handleSelectModule(mod) {
  resumeStore.selectedModuleId = mod.id
}

onMounted(async () => {
  await resumeStore.initOrRestore()
  styleStore.loadStyles()
})

onUnmounted(() => {
  document.removeEventListener('mousemove', onResize)
  document.removeEventListener('mouseup', stopResize)
})
</script>

<style scoped>
.editor-layout {
  display: flex;
  flex-direction: column;
  height: 100vh;
  width: 100vw;
  overflow: hidden;
  background: var(--color-background);
}

.top-bar {
  height: 52px;
  flex-shrink: 0;
  border-bottom: 1px solid var(--color-border);
  background: var(--color-card);
  box-shadow: var(--shadow-sm);
}

.main-content {
  display: flex;
  flex: 1;
  overflow: hidden;
}

.left-panel {
  flex-shrink: 0;
  border-right: none;
  background: var(--color-card);
  overflow-y: auto;
}

.edit-panel {
  flex: 1;
  min-width: 0;
  overflow-y: auto;
  background: var(--color-background);
}

.preview-panel {
  flex-shrink: 0;
  border-left: none;
  background: var(--color-card);
  overflow-y: auto;
}

.resize-handle {
  width: 6px;
  flex-shrink: 0;
  cursor: col-resize;
  background: transparent;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background var(--transition-fast);
  z-index: 10;
}

.resize-handle:hover {
  background: var(--color-border);
}

.resize-handle-left {
  border-right: 1px solid var(--color-border);
}

.resize-handle-right {
  border-left: 1px solid var(--color-border);
}

.resize-handle.collapsed {
  cursor: default;
}

.collapse-btn {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  width: 20px;
  height: 36px;
  border: 1px solid var(--color-border);
  border-radius: var(--radius-sm);
  background: var(--color-card);
  color: var(--color-muted-foreground);
  font-size: 14px;
  line-height: 1;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0;
  transition: color var(--transition-fast), background var(--transition-fast), border-color var(--transition-fast);
  z-index: 11;
}

.resize-handle-left .collapse-btn {
  right: -12px;
}

.resize-handle-right .collapse-btn {
  left: -12px;
}

.collapse-btn:hover {
  color: var(--color-primary);
  border-color: var(--color-primary);
  background: var(--color-card);
  box-shadow: var(--shadow-sm);
}

.drag-overlay {
  position: fixed;
  inset: 0;
  z-index: 9999;
  cursor: col-resize;
}
</style>
