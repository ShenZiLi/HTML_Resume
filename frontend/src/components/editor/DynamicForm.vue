<template>
  <div class="dynamic-form">
    <el-form label-position="top" label-width="100%">
      <el-form-item
        v-for="field in fieldConfigs"
        :key="field.field_name"
        :label="field.label"
      >
        <el-input
          v-if="field.field_type === 'text'"
          v-model="localData[field.field_name]"
          :placeholder="field.placeholder || ''"
          @change="emitUpdate"
        />

        <el-input
          v-else-if="field.field_type === 'textarea'"
          v-model="localData[field.field_name]"
          type="textarea"
          :rows="4"
          :placeholder="field.placeholder || ''"
          @change="emitUpdate"
        />

        <el-date-picker
          v-else-if="field.field_type === 'date'"
          v-model="localData[field.field_name]"
          type="month"
          value-format="YYYY-MM"
          :placeholder="field.placeholder || '选择日期'"
          style="width: 100%"
          @change="emitUpdate"
        />

        <el-select
          v-else-if="field.field_type === 'select'"
          v-model="localData[field.field_name]"
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
          v-else-if="field.field_type === 'switch'"
          v-model="localData[field.field_name]"
          @change="emitUpdate"
        />

        <el-input
          v-else-if="field.field_type === 'image'"
          v-model="localData[field.field_name]"
          :placeholder="field.placeholder || '点击上传图片或输入图片URL'"
          @change="emitUpdate"
        />

        <el-input
          v-else
          v-model="localData[field.field_name]"
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
</style>
