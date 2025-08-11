import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: () => import('../views/ImagePickerView.vue')
    },
    {
      path: '/image-viewer',
      name: 'image-viewer',
      component: () => import('../views/ImageViewerView.vue')
    }
  ]
})

export default router
