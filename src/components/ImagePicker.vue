<template>
  <div class="image-picker">
    <div class="picker-container">
      <div class="picker-area" @click="selectImage">
        <div v-if="!selectedImage" class="placeholder">
          <div class="upload-icon">🖼️</div>
          <h3>选择图片文件</h3>
          <p class="hint">点击此区域选择图片</p>
          <button class="select-btn">浏览文件</button>
        </div>

        <div v-else class="image-preview">
          <img v-if="imageUrl" :src="imageUrl" :alt="selectedImage.name" class="preview-image" />
          <div v-else class="loading">处理中...</div>
          <div class="image-info">
            <p>{{ selectedImage.name }}</p>
            <div class="actions">
              <button @click.stop="selectImage" class="change-btn">更换图片</button>
              <button @click.stop="clearImage" class="clear-btn">清除</button>
            </div>
          </div>
        </div>
      </div>

      <div v-if="error" class="error">
        <p>{{ error }}</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { config } from '@/config'

interface ImageInfo {
  name: string
  path: string
}

const selectedImage = ref<ImageInfo | null>(null)
const imageUrl = ref<string>('')
const error = ref<string>('')

const selectImage = async () => {
  try {
    let filePath: string

    if (config.isDesktop) {
      // 桌面环境：使用 Tauri dialog
      const { dialog } = await import('@tauri-apps/api')
      const selected = await dialog.open({
        multiple: false,
        filters: [{
          name: 'Image',
          extensions: ['png', 'jpg', 'jpeg', 'gif', 'webp']
        }]
      })

      if (!selected) return
      filePath = selected as string

      // 发送文件路径给后端处理
      await processImage(filePath)
    } else {
      // Web环境：使用标准文件选择
      const input = document.createElement('input')
      input.type = 'file'
      input.accept = 'image/*'

      const file = await new Promise<File | null>((resolve) => {
        input.onchange = (e) => {
          const target = e.target as HTMLInputElement
          resolve(target.files?.[0] || null)
        }
        input.click()
      })

      if (!file) return

      // Web环境下创建预览
      imageUrl.value = URL.createObjectURL(file)
      selectedImage.value = {
        name: file.name,
        path: file.name
      }
    }
  } catch (err) {
    console.error('Failed to select file:', err)
    error.value = '选择文件失败'
  }
}

const processImage = async (filePath: string) => {
  try {
    console.log('Processing image:', filePath)  // 添加日志
    const response = await fetch(`${config.apiBaseUrl}/api/process-image`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ file_path: filePath })
    })

    if (!response.ok) {
      const result = await response.json()
      throw new Error(result.message || '处理失败')
    }

    const result = await response.json()
    console.log('Process result:', result)  // 添加日志

    // 更新图片显示
    imageUrl.value = `${config.apiBaseUrl}/api/image/${result.id}`
    selectedImage.value = {
      name: filePath.split('/').pop() || 'image',
      path: filePath
    }
  } catch (err) {
    console.error('Process error:', err)  // 添加日志
    error.value = err instanceof Error ? err.message : '处理失败'
  }
}

const clearImage = () => {
  if (!config.isDesktop && imageUrl.value.startsWith('blob:')) {
    URL.revokeObjectURL(imageUrl.value)
  }
  selectedImage.value = null
  imageUrl.value = ''
  error.value = ''
}
</script>

<style scoped>
.image-picker {
  padding: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 80vh;
  background: rgba(255, 255, 255, 0.1);
  margin: 20px;
  border-radius: 12px;
}

.picker-container {
  width: 100%;
  max-width: 800px;
}

.picker-area {
  border: 2px dashed rgba(255, 255, 255, 0.3);
  border-radius: 8px;
  padding: 20px;
  text-align: center;
  cursor: pointer;
  min-height: 300px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(10px);
  transition: all 0.3s ease;
}

.picker-area:hover {
  border-color: #2196f3;
}

.placeholder {
  color: rgba(255, 255, 255, 0.9);
}

.upload-icon {
  font-size: 48px;
  margin-bottom: 20px;
}

.hint {
  margin: 10px 0;
  color: rgba(255, 255, 255, 0.7);
}

.select-btn {
  background: #2196f3;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 4px;
  cursor: pointer;
  margin-top: 10px;
}

.image-preview {
  width: 100%;
}

.preview-image {
  max-width: 100%;
  max-height: 400px;
  margin: 0 auto;
  display: block;
  border-radius: 4px;
}

.image-info {
  margin-top: 10px;
  color: rgba(255, 255, 255, 0.9);
}

.actions {
  display: flex;
  gap: 10px;
  justify-content: center;
  margin-top: 10px;
}

.change-btn, .clear-btn {
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.change-btn {
  background: #4caf50;
  color: white;
}

.clear-btn {
  background: #f44336;
  color: white;
}

.error {
  background: #ffebee;
  color: #c62828;
  padding: 10px;
  border-radius: 4px;
  margin-top: 10px;
  text-align: center;
}

.loading {
  padding: 20px;
  color: rgba(255, 255, 255, 0.7);
}
</style>
