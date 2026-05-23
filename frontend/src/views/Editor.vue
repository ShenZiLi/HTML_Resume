<template>
  <div class="editor-layout">
    <TopBar class="top-bar" />
    <div class="main-content">
      <LeftPanel class="left-panel" />
      <EditPanel class="edit-panel" />
      <PreviewPanel class="preview-panel" />
    </div>
  </div>
</template>

<script setup>
import { defineAsyncComponent } from 'vue'

const TopBar = defineAsyncComponent(() => import('../components/editor/TopBar.vue'))
const LeftPanel = defineAsyncComponent(() => import('../components/editor/LeftPanel.vue'))
const EditPanel = defineAsyncComponent(() => import('../components/editor/EditPanel.vue'))
const PreviewPanel = defineAsyncComponent(() => import('../components/editor/PreviewPanel.vue'))
</script>

<style scoped>
.editor-layout {
  display: flex;
  flex-direction: column;
  height: 100vh;
  width: 100vw;
  overflow: hidden;
}

.top-bar {
  height: 48px;
  flex-shrink: 0;
  border-bottom: 1px solid #e5e7eb;
  background: #fff;
}

.main-content {
  display: flex;
  flex: 1;
  overflow: hidden;
}

.left-panel {
  width: 200px;
  border-right: 1px solid #e5e7eb;
  background: #fafafa;
  overflow-y: auto;
}

.edit-panel {
  flex: 1;
  padding: 16px;
  overflow-y: auto;
  background: #f5f5f5;
}

.preview-panel {
  width: 500px;
  border-left: 1px solid #e5e7eb;
  background: #fff;
  overflow-y: auto;
}
</style>
