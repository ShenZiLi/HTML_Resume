<template>
  <div class="left-panel">
    <draggable
      v-model="moduleList"
      item-key="id"
      handle=".drag-handle"
      class="module-list"
      @end="onDragEnd"
    >
      <template #item="{ element }">
        <div
          class="module-card"
          :class="{ active: selectedModuleId === element.id }"
          @click="selectModule(element)"
        >
          <span class="drag-handle">☰</span>
          <span class="module-label">{{ getModuleDisplayName(element) }}</span>
          <el-button
            class="delete-btn"
            size="small"
            type="danger"
            link
            @click.stop="handleDelete(element)"
          >
            ✕
          </el-button>
        </div>
      </template>
    </draggable>

    <div class="add-module-area">
      <el-dropdown trigger="click" @command="handleAddModule">
        <el-button size="small" type="primary" style="width: 100%">
          添加模块 +
        </el-button>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item
              v-for="type in moduleTypes"
              :key="type.value"
              :command="type.value"
            >
              {{ type.label }}
            </el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import draggable from 'vuedraggable'
import { useResumeStore } from '../../store/modules/resume'
import { addModule, deleteModule as apiDeleteModule, batchUpdateSort } from '../../api/module'
import { ElMessage, ElMessageBox } from 'element-plus'

const props = defineProps({
  selectedModuleId: {
    type: [Number, null],
    default: null
  }
})

const emit = defineEmits(['select'])

const resumeStore = useResumeStore()

const moduleList = computed({
  get: () => resumeStore.modules,
  set: (val) => {
    resumeStore.modules = val
  }
})

const moduleTypes = [
  { value: 'basic_info', label: '基本信息' },
  { value: 'education', label: '教育经历' },
  { value: 'work_experience', label: '工作经历' },
  { value: 'project', label: '项目经历' },
  { value: 'award', label: '荣誉证书' }
]

function getModuleLabel(type) {
  const found = moduleTypes.find((t) => t.value === type)
  return found ? found.label : type
}

const displayFieldMap = {
  education: 'school',
  work_experience: 'company',
  project: 'projectName'
}

function getModuleDisplayName(mod) {
  const typeLabel = getModuleLabel(mod.moduleType)
  const fieldKey = displayFieldMap[mod.moduleType]
  if (!fieldKey) return typeLabel

  let content = {}
  try {
    content = typeof mod.content === 'string' ? JSON.parse(mod.content) : (mod.content || {})
  } catch { content = {} }

  const name = content[fieldKey]
  return name ? `${typeLabel} - ${name}` : typeLabel
}

function selectModule(mod) {
  emit('select', mod)
}

async function handleAddModule(moduleType) {
  if (!resumeStore.currentResume) {
    ElMessage.warning('请先创建或加载简历')
    return
  }

  try {
    const newModule = await addModule({
      resume_id: resumeStore.currentResume.id,
      module_type: moduleType,
      content: {},
      sort_order: resumeStore.modules.length
    })

    resumeStore.addModule(newModule)
    ElMessage.success('模块添加成功')
    selectModule(newModule)
  } catch (error) {
    ElMessage.error('添加模块失败')
  }
}

async function handleDelete(mod) {
  try {
    await ElMessageBox.confirm('确定要删除此模块吗？', '删除确认', {
      confirmButtonText: '删除',
      cancelButtonText: '取消',
      type: 'warning'
    })

    await apiDeleteModule(mod.id)
    resumeStore.deleteModule(mod.id)
    ElMessage.success('模块已删除')
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除模块失败')
    }
  }
}

async function onDragEnd() {
  if (!resumeStore.currentResume) return

  const sortedModules = resumeStore.modules.map((mod, index) => ({
    id: mod.id,
    sortOrder: index
  }))

  try {
    await batchUpdateSort(resumeStore.currentResume.id, sortedModules)
    resumeStore.modules.forEach((mod, index) => {
      mod.sortOrder = index
    })
    ElMessage.success('排序已保存')
  } catch (error) {
    ElMessage.error('保存排序失败')
  }
}
</script>

<style scoped>
.left-panel {
  padding: 12px;
  display: flex;
  flex-direction: column;
  height: 100%;
}

.module-list {
  flex: 1;
  overflow-y: auto;
}

.module-card {
  display: flex;
  align-items: center;
  padding: 10px 12px;
  margin-bottom: 4px;
  background: var(--color-card);
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: all var(--transition-normal);
  border: 1px solid var(--color-border);
  gap: 10px;
}

.module-card:hover {
  border-color: var(--color-primary);
  box-shadow: var(--shadow-md);
}

.module-card.active {
  background: var(--color-muted);
  border-color: var(--color-primary);
  box-shadow: var(--shadow-md);
}

.drag-handle {
  cursor: grab;
  color: var(--color-muted-foreground);
  font-size: 14px;
  user-select: none;
  transition: color var(--transition-fast);
}

.drag-handle:hover {
  color: var(--color-primary);
}

.drag-handle:active {
  cursor: grabbing;
}

.module-label {
  flex: 1;
  font-size: 13px;
  font-weight: 500;
  color: var(--color-foreground);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.module-card.active .module-label {
  color: var(--color-primary);
}

.delete-btn {
  padding: 0 4px;
  font-size: 12px;
  opacity: 0;
  transition: opacity var(--transition-fast);
}

.module-card:hover .delete-btn {
  opacity: 1;
}

.add-module-area {
  padding-top: 12px;
  border-top: 1px solid var(--color-border);
  margin-top: 12px;
}
</style>
