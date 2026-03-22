<template>
  <v-layout>
    <v-app-bar color="primary">
      <v-toolbar-title>Task Manager</v-toolbar-title>
      <v-spacer />
      <v-menu>
        <template v-slot:activator="{ props }">
          <v-btn
            v-bind="props"
            prepend-icon="mdi-account"
            text
          >
            {{ user?.name }}
          </v-btn>
        </template>
        <v-list>
          <v-list-item @click="handleLogout">
            <v-list-item-title>Logout</v-list-item-title>
          </v-list-item>
        </v-list>
      </v-menu>
    </v-app-bar>

    <v-main>
      <v-container>
        <v-row>
          <v-col cols="12">
            <h1 class="mb-4">Tasks</h1>
          </v-col>
        </v-row>

        <v-row>
          <v-col cols="12">
            <TaskFilters @filter-change="applyFilters" />
          </v-col>
        </v-row>

        <v-row>
          <v-col cols="12">
            <TaskForm @task-saved="loadTasks" />
          </v-col>
        </v-row>

        <v-row>
          <v-col cols="12">
            <TaskList
              :tasks="tasks"
              :is-loading="isLoading"
              :current-page="currentPage"
              :per-page="perPage"
              :total="total"
              @refresh="loadTasks"
            />
          </v-col>
        </v-row>
      </v-container>
    </v-main>
  </v-layout>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/auth';
import TaskFilters from '@/components/TaskFilters.vue';
import TaskForm from '@/components/TaskForm.vue';
import TaskList from '@/components/TaskList.vue';
import type { Task } from '@/types';
import api from '@/services/api';

const router = useRouter();
const auth = useAuthStore();

const tasks = ref<Task[]>([]);
const isLoading = ref(false);
const currentPage = ref(1);
const perPage = ref(15);
const total = ref(0);
const filters = ref({});

const user = computed(() => auth.user);

const loadTasks = async () => {
  isLoading.value = true;
  try {
    const response = await api.getTasks(currentPage.value, perPage.value, filters.value);
    tasks.value = response.data.data;
    total.value = response.data.meta.total;
  } catch (err) {
    console.error('Failed to load tasks:', err);
  } finally {
    isLoading.value = false;
  }
};

const applyFilters = (newFilters: any) => {
  filters.value = newFilters;
  currentPage.value = 1;
  loadTasks();
};

const handleLogout = async () => {
  await auth.logout();
  router.push('/login');
};

onMounted(() => {
  loadTasks();
});
</script>
