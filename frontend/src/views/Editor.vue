<template>
  <div class="editor-layout">
    <TopBar class="top-bar" />
    <div class="main-content">
      <LeftPanel
        class="left-panel"
        :selected-module-id="resumeStore.selectedModuleId"
        @select="handleSelectModule"
      />
      <EditPanel
        class="edit-panel"
        :selected-module="resumeStore.selectedModule"
      />
      <PreviewPanel class="preview-panel" />
    </div>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useResumeStore } from '../store/modules/resume'
import { useStyleStore } from '../store/modules/style'
import TopBar from '../components/editor/TopBar.vue'
import LeftPanel from '../components/editor/LeftPanel.vue'
import EditPanel from '../components/editor/EditPanel.vue'
import PreviewPanel from '../components/editor/PreviewPanel.vue'

const resumeStore = useResumeStore()
const styleStore = useStyleStore()

function handleSelectModule(mod) {
  resumeStore.selectedModuleId = mod.id
}

onMounted(async () => {
  await resumeStore.initOrRestore()
  styleStore.loadStyles()
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
  width: 220px;
  border-right: 1px solid var(--color-border);
  background: var(--color-card);
  overflow-y: auto;
}

.edit-panel {
  flex: 1;
  overflow-y: auto;
  background: var(--color-background);
}

.preview-panel {
  width: 480px;
  border-left: 1px solid var(--color-border);
  background: var(--color-card);
  overflow-y: auto;
}
</style>
