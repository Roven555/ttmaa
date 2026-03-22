<template>
  <v-card class="mt-4">
    <v-card-title>Login</v-card-title>
    <v-card-text>
      <v-form @submit.prevent="handleLogin">
        <v-text-field
          v-model="email"
          label="Email"
          type="email"
          required
          :rules="emailRules"
          class="mb-4"
        />

        <v-text-field
          v-model="password"
          label="Password"
          type="password"
          required
          class="mb-4"
        />

        <v-alert v-if="error" type="error" class="mb-4">
          {{ error }}
        </v-alert>

        <v-btn
          type="submit"
          color="primary"
          prepend-icon="mdi-login"
          :loading="isLoading"
          block
        >
          Log In
        </v-btn>
      </v-form>

      <v-card-subtitle class="text-center mt-4">
        Demo Credentials:<br>
        Email: admin@example.com<br>
        Password: password
      </v-card-subtitle>
    </v-card-text>
  </v-card>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/auth';

const router = useRouter();
const auth = useAuthStore();

const email = ref('');
const password = ref('');
const isLoading = ref(false);
const error = ref('');

const emailRules = [
  (v: any) => !!v || 'Email is required',
  (v: any) => /.+@.+\..+/.test(v) || 'Email must be valid',
];

const handleLogin = async () => {
  isLoading.value = true;
  error.value = '';

  const success = await auth.login(email.value, password.value);
  if (success) {
    router.push('/tasks');
  } else {
    error.value = auth.error || 'Login failed';
  }

  isLoading.value = false;
};
</script>
