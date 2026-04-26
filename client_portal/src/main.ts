import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import App from './App.vue'
import './style.css'

const router = createRouter({
  history: createWebHistory('/client_portal'),
  routes: [
    { path: '/', component: () => import('./views/Dashboard.vue') },
    { path: '/invoices', component: () => import('./views/Invoices.vue') },
    { path: '/:pathMatch(.*)*', component: () => import('./views/NotFound.vue') },
  ],
})

createApp(App).use(router).mount('#app')