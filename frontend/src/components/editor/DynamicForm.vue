<template>
  <div class="dynamic-form">
    <el-form label-position="top" label-width="100%">
      <el-form-item
        v-for="field in fieldConfigs"
        :key="field.fieldKey"
        :label="field.fieldName"
      >
        <el-input
          v-if="field.fieldType === 'text'"
          v-model="localData[field.fieldKey]"
          :placeholder="field.placeholder || ''"
          @change="emitUpdate"
        />

        <el-input
          v-else-if="field.fieldType === 'textarea'"
          v-model="localData[field.fieldKey]"
          type="textarea"
          :rows="4"
          :placeholder="field.placeholder || ''"
          @change="emitUpdate"
        />

        <el-date-picker
          v-else-if="field.fieldType === 'date'"
          v-model="localData[field.fieldKey]"
          type="month"
          value-format="YYYY-MM"
          :placeholder="field.placeholder || '选择日期'"
          style="width: 100%"
          @change="emitUpdate"
        />

        <el-select
          v-else-if="field.fieldType === 'select'"
          v-model="localData[field.fieldKey]"
          :placeholder="field.placeholder || '请选择'"
          style="width: 100%"
          @change="emitUpdate"
        >
          <el-option
            v-for="opt in (field.options || [])"
            :key="opt.value"
            :label="opt.label"
            :value="opt.value"
          />
        </el-select>

        <el-switch
          v-else-if="field.fieldType === 'switch'"
          v-model="localData[field.fieldKey]"
          @change="emitUpdate"
        />

        <el-input
          v-else-if="field.fieldType === 'image'"
          v-model="localData[field.fieldKey]"
          :placeholder="field.placeholder || '点击上传图片或输入图片URL'"
          @change="emitUpdate"
        />

        <el-input
          v-else
          v-model="localData[field.fieldKey]"
          :placeholder="field.placeholder || ''"
          @change="emitUpdate"
        />
      </el-form-item>
    </el-form>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  fieldConfigs: {
    type: Array,
    required: true
  },
  formData: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update'])

const localData = ref({ ...props.formData })

watch(
  () => props.formData,
  (newVal) => {
    localData.value = { ...newVal }
  },
  { deep: true }
)

function emitUpdate() {
  emit('update', { ...localData.value })
}
</script>

<style scoped>
.dynamic-form {
  padding: 16px;
  overflow-y: auto;
}

.dynamic-form :deep(.el-form-item__label) {
  font-weight: 500;
  font-size: 13px;
  color: var(--color-foreground);
  padding-bottom: 4px;
}

.dynamic-form :deep(.el-form-item) {
  margin-bottom: 16px;
}

.dynamic-form :deep(.el-input__wrapper),
.dynamic-form :deep(.el-textarea__inner) {
  border-radius: var(--radius-sm);
  transition: box-shadow var(--transition-fast), border-color var(--transition-fast);
}

.dynamic-form :deep(.el-input__wrapper:focus-within) {
  box-shadow: 0 0 0 2px rgba(99, 102, 241, 0.15);
}
</style>
