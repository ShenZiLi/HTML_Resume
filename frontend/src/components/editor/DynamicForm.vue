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

        <template v-else-if="field.layoutType === 'list'">
          <div class="list-field">
            <div
              v-for="(_, index) in getListField(field.fieldKey)"
              :key="index"
              class="list-item"
            >
              <el-input
                v-model="localData[field.fieldKey][index]"
                type="textarea"
                :rows="2"
                :placeholder="`${field.placeholder || '请输入内容'} ${index + 1}`"
                @change="emitUpdate"
              />
              <el-button
                type="danger"
                link
                @click="removeListItem(field.fieldKey, index)"
              >
                删除
              </el-button>
            </div>
            <el-button
              size="small"
              @click="addListItem(field.fieldKey)"
            >
              + 添加{{ field.fieldName }}
            </el-button>
          </div>
        </template>

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

        <div v-else-if="field.fieldType === 'image'" class="image-upload">
          <el-input
            v-model="localData[field.fieldKey]"
            :placeholder="field.placeholder || '上传图片或输入图片URL'"
            @change="emitUpdate"
          >
            <template #append>
              <el-upload
                :show-file-list="false"
                :before-upload="(file) => handleImageUpload(file, field.fieldKey)"
                accept="image/*"
              >
                <el-button>上传</el-button>
              </el-upload>
            </template>
          </el-input>
          <div v-if="localData[field.fieldKey]" class="image-preview">
            <img :src="localData[field.fieldKey]" alt="预览" />
          </div>
        </div>

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
import { uploadImage } from '../../api/upload'
import { ElMessage } from 'element-plus'

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

function getListField(key) {
  if (!Array.isArray(localData.value[key])) {
    localData.value[key] = []
  }
  return localData.value[key]
}

function addListItem(key) {
  if (!Array.isArray(localData.value[key])) {
    localData.value[key] = []
  }
  localData.value[key].push('')
  emitUpdate()
}

function removeListItem(key, index) {
  if (Array.isArray(localData.value[key])) {
    localData.value[key].splice(index, 1)
    emitUpdate()
  }
}

async function handleImageUpload(file, fieldKey) {
  try {
    const imageUrl = await uploadImage(file)
    localData.value[fieldKey] = imageUrl
    emitUpdate()
    ElMessage.success('图片上传成功')
  } catch (error) {
    ElMessage.error('图片上传失败')
  }
  return false
}

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
  padding-bottom: 4px;
}

.dynamic-form :deep(.el-form-item) {
  margin-bottom: 16px;
}

.list-field {
  width: 100%;
}

.list-item {
  display: flex;
  gap: 8px;
  margin-bottom: 8px;
  align-items: flex-start;
}

.list-item .el-input {
  flex: 1;
}

.image-upload {
  width: 100%;
}

.image-preview {
  margin-top: 8px;
  text-align: center;
}

.image-preview img {
  max-width: 120px;
  max-height: 160px;
  border-radius: 4px;
  border: 1px solid #dcdfe6;
  object-fit: cover;
}
</style>
