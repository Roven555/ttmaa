<template>
  <v-card class="mb-4">
    <v-card-text>
      <v-row>
        <v-col cols="12" md="3">
          <v-text-field
            v-model="search"
            label="Search tasks"
            prepend-icon="mdi-magnify"
            @keyup.debounce="$emit('filter-change', getFilters())"
          />
        </v-col>

        <v-col cols="12" md="3">
          <v-select
            v-model="status"
            label="Status"
            :items="['', 'pending', 'completed']"
            @update:model-value="$emit('filter-change', getFilters())"
          />
        </v-col>

        <v-col cols="12" md="3">
          <v-select
            v-model="priority"
            label="Priority"
            :items="['', 'low', 'medium', 'high']"
            @update:model-value="$emit('filter-change', getFilters())"
          />
        </v-col>

        <v-col cols="12" md="3">
          <v-btn
            color="secondary"
            prepend-icon="mdi-refresh"
            @click="resetFilters"
            block
          >
            Reset
          </v-btn>
        </v-col>
      </v-row>
    </v-card-text>
  </v-card>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const emit = defineEmits<{
  'filter-change': [filters: any];
}>();

const search = ref('');
const status = ref('');
const priority = ref('');

const getFilters = () => ({
  search: search.value || undefined,
  status: status.value || undefined,
  priority: priority.value || undefined,
});

const resetFilters = () => {
  search.value = '';
  status.value = '';
  priority.value = '';
  emit('filter-change', {});
};
</script>
