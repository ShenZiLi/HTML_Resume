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
          <span class="module-label">{{ getModuleLabel(element.module_type) }}</span>
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
    type: Number,
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

function onDragEnd(event) {
  const { oldIndex, newIndex } = event
  if (oldIndex === newIndex) return

  resumeStore.reorderModules({ oldIndex, newIndex })

  const sortedModules = resumeStore.modules.map((mod, index) => ({
    id: mod.id,
    sort_order: index
  }))

  batchUpdateSort(resumeStore.currentResume.id, sortedModules).catch(() => {
    ElMessage.error('保存排序失败')
  })
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
  padding: 8px 10px;
  margin-bottom: 6px;
  background: #fff;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
  border: 1px solid #e5e7eb;
  gap: 8px;
}

.module-card:hover {
  border-color: #409eff;
  box-shadow: 0 2px 8px rgba(64, 158, 255, 0.15);
}

.module-card.active {
  background: #ecf5ff;
  border-color: #409eff;
}

.drag-handle {
  cursor: grab;
  color: #999;
  font-size: 14px;
  user-select: none;
}

.drag-handle:active {
  cursor: grabbing;
}

.module-label {
  flex: 1;
  font-size: 13px;
  color: #333;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.delete-btn {
  padding: 0 4px;
  font-size: 12px;
  opacity: 0;
  transition: opacity 0.2s;
}

.module-card:hover .delete-btn {
  opacity: 1;
}

.add-module-area {
  padding-top: 12px;
  border-top: 1px solid #e5e7eb;
  margin-top: 12px;
}
</style>
