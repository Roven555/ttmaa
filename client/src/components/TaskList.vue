<template>
  <div>
    <v-data-table
      :headers="headers"
      :items="tasks"
      :loading="isLoading"
      :items-per-page="perPage"
      :server-items-length="total"
      @update:page="currentPage = $event"
    >
      <template v-slot:item.status="{ item }">
        <v-chip
          :color="item.status === 'completed' ? 'success' : 'warning'"
          :text-color="item.status === 'completed' ? 'white' : 'black'"
        >
          {{ item.status }}
        </v-chip>
      </template>

      <template v-slot:item.priority="{ item }">
        <v-chip
          :color="getPriorityColor(item.priority)"
          text-color="white"
        >
          {{ item.priority }}
        </v-chip>
      </template>

      <template v-slot:item.actions="{ item }">
        <v-btn
          size="small"
          color="primary"
          prepend-icon="mdi-pencil"
          @click="editTask(item)"
          class="mr-2"
        >
          Edit
        </v-btn>
        <v-btn
          size="small"
          color="error"
          prepend-icon="mdi-delete"
          @click="deleteTask(item)"
        >
          Delete
        </v-btn>
      </template>
    </v-data-table>

    <TaskForm
      v-if="selectedTask"
      :task="selectedTask"
      @task-saved="$emit('refresh')"
      @task-deleted="$emit('refresh')"
    />
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import type { Task } from '@/types';
import TaskForm from './TaskForm.vue';
import api from '@/services/api';

const props = defineProps<{
  tasks: Task[];
  isLoading: boolean;
  currentPage: number;
  perPage: number;
  total: number;
}>();

const emit = defineEmits<{
  refresh: [];
  'update:currentPage': [page: number];
}>();

const selectedTask = computed(() => {
  return undefined;
});

const headers = [
  { title: 'Title', key: 'title' },
  { title: 'Description', key: 'description' },
  { title: 'Status', key: 'status' },
  { title: 'Priority', key: 'priority' },
  { title: 'Due Date', key: 'due_date' },
  { title: 'Actions', key: 'actions', sortable: false },
];

const editTask = (task: Task) => {
  const form = document.querySelector('[class*="task-form"]');
  if (form) form.click();
};

const deleteTask = async (task: Task) => {
  if (confirm(`Delete task "${task.title}"?`)) {
    try {
      await api.deleteTask(task.id);
      emit('refresh');
    } catch (err) {
      console.error('Delete failed:', err);
    }
  }
};

const getPriorityColor = (priority: string) => {
  const colors: Record<string, string> = {
    low: 'green',
    medium: 'orange',
    high: 'red',
  };
  return colors[priority] || 'blue';
};
</script>
