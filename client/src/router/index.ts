import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router';
import { useAuthStore } from '@/stores/auth';
import LoginPage from '@/pages/LoginPage.vue';
import TasksPage from '@/pages/TasksPage.vue';

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'Login',
    component: LoginPage,
    meta: { requiresAuth: false },
  },
  {
    path: '/tasks',
    name: 'Tasks',
    component: TasksPage,
    meta: { requiresAuth: true },
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: () => {
      const auth = useAuthStore();
      return auth.isAuthenticated() ? '/tasks' : '/login';
    },
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

router.beforeEach((to, from, next) => {
  const auth = useAuthStore();
  const requiresAuth = to.meta.requiresAuth !== false;

  if (requiresAuth && !auth.isAuthenticated()) {
    next('/login');
  } else if (to.path === '/login' && auth.isAuthenticated()) {
    next('/tasks');
  } else {
    next();
  }
});

export default router;
