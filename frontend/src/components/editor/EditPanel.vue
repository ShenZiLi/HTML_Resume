<template>
  <div class="edit-panel">
    <div v-if="selectedModule" class="edit-content">
      <div class="edit-header">
        <h3 class="edit-title">{{ getModuleLabel(selectedModule.module_type) }}</h3>
        <span v-if="isSaving" class="save-status">保存中...</span>
        <span v-else-if="lastSaved" class="save-status">已保存 {{ lastSaved }}</span>
      </div>
      <DynamicForm
        :key="selectedModule.id"
        :field-configs="fieldConfigs"
        :form-data="formData"
        @update="handleFormUpdate"
      />
    </div>
    <div v-else class="empty-state">
      <p>请选择一个模块进行编辑</p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import DynamicForm from './DynamicForm.vue'
import { useResumeStore } from '../../store/modules/resume'
import { getModuleConfig } from '../../api/module'
import { updateModuleContent } from '../../api/module'
import { ElMessage } from 'element-plus'

const props = defineProps({
  selectedModule: {
    type: Object,
    default: null
  }
})

const resumeStore = useResumeStore()

const fieldConfigs = ref([])
const formData = ref({})
const isSaving = ref(false)
const lastSaved = ref('')

let saveTimer = null

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

watch(
  () => props.selectedModule,
  async (mod) => {
    if (!mod) {
      fieldConfigs.value = []
      formData.value = {}
      return
    }

    formData.value = { ...(mod.content || {}) }

    try {
      const config = await getModuleConfig(mod.module_type)
      fieldConfigs.value = config?.fields || []
    } catch (error) {
      fieldConfigs.value = []
    }
  },
  { immediate: true }
)

function handleFormUpdate(newData) {
  formData.value = newData
  debouncedSave()
}

function debouncedSave() {
  if (saveTimer) clearTimeout(saveTimer)
  isSaving.value = true

  saveTimer = setTimeout(() => {
    saveData()
  }, 1000)
}

async function saveData() {
  if (!props.selectedModule) return

  try {
    await updateModuleContent(props.selectedModule.id, formData.value)

    resumeStore.updateModule(props.selectedModule.id, { content: { ...formData.value } })

    const now = new Date()
    lastSaved.value = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}:${now.getSeconds().toString().padStart(2, '0')}`
  } catch (error) {
    ElMessage.error('保存失败')
  } finally {
    isSaving.value = false
  }
}
</script>

<style scoped>
.edit-panel {
  padding: 16px;
  height: 100%;
  overflow-y: auto;
}

.edit-content {
  max-width: 600px;
  margin: 0 auto;
}

.edit-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.edit-title {
  margin: 0;
  font-size: 18px;
  color: #333;
}

.save-status {
  font-size: 12px;
  color: #999;
}

.empty-state {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
  color: #999;
  font-size: 14px;
}
</style>
