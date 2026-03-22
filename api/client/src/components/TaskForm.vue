<template>
  <v-dialog v-model="isOpen" max-width="600">
    <template v-slot:activator="{ props }">
      <v-btn
        v-bind="props"
        color="primary"
        prepend-icon="mdi-plus"
      >
        Create Task
      </v-btn>
    </template>

    <v-card>
      <v-card-title>{{ task?.id ? 'Edit Task' : 'Create New Task' }}</v-card-title>

      <v-card-text>
        <v-form @submit.prevent="handleSubmit">
          <v-text-field
            v-model="formData.title"
            label="Title"
            required
            class="mb-4"
          />

          <v-textarea
            v-model="formData.description"
            label="Description"
            class="mb-4"
          />

          <v-select
            v-model="formData.status"
            label="Status"
            :items="['pending', 'completed']"
            class="mb-4"
          />

          <v-select
            v-model="formData.priority"
            label="Priority"
            :items="['low', 'medium', 'high']"
            class="mb-4"
          />

          <v-text-field
            v-model="formData.due_date"
            label="Due Date"
            type="datetime-local"
            class="mb-4"
          />

          <v-alert v-if="error" type="error" class="mb-4">
            {{ error }}
          </v-alert>

          <v-row>
            <v-col>
              <v-btn @click="isOpen = false">Cancel</v-btn>
            </v-col>
            <v-col class="text-right">
              <v-btn
                type="submit"
                color="primary"
                :loading="isLoading"
              >
                {{ task?.id ? 'Update' : 'Create' }}
              </v-btn>
            </v-col>
          </v-row>
        </v-form>
      </v-card-text>
    </v-card>
  </v-dialog>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import type { Task } from '@/types';
import api from '@/services/api';
import { useAuthStore } from '@/stores/auth';

const props = defineProps<{
  task?: Task;
}>();

const emit = defineEmits<{
  'task-saved': [];
  'task-deleted': [];
}>();

const auth = useAuthStore();
const isOpen = ref(false);
const isLoading = ref(false);
const error = ref('');

const formData = reactive({
  title: '',
  description: '',
  status: 'pending' as 'pending' | 'completed',
  priority: 'medium' as 'low' | 'medium' | 'high',
  due_date: '',
  user_id: undefined as number | undefined,
});

onMounted(() => {
  if (props.task) {
    Object.assign(formData, props.task);
  }
});

const handleSubmit = async () => {
  isLoading.value = true;
  error.value = '';

  try {
    if (props.task?.id) {
      await api.updateTask(props.task.id, formData);
    } else {
      await api.createTask(formData);
    }
    isOpen.value = false;
    emit('task-saved');
  } catch (err: any) {
    error.value = err.response?.data?.message || 'Failed to save task';
  } finally {
    isLoading.value = false;
  }
};

const handleDelete = async () => {
  if (!props.task?.id) return;

  if (confirm('Are you sure you want to delete this task?')) {
    try {
      await api.deleteTask(props.task.id);
      isOpen.value = false;
      emit('task-deleted');
    } catch (err: any) {
      error.value = err.response?.data?.message || 'Failed to delete task';
    }
  }
};
</script>
