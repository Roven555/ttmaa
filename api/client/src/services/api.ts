import axios, { AxiosInstance } from 'axios';
import type { LoginResponse, Task, User, PaginatedResponse } from '@/types';

const API_URL = import.meta.env.VITE_API_URL;

class ApiService {
  private api: AxiosInstance;

  constructor() {
    this.api = axios.create({
      baseURL: API_URL,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    });

    this.api.interceptors.request.use((config) => {
      const token = localStorage.getItem('auth_token');
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
      return config;
    });

    this.api.interceptors.response.use(
      (response) => response,
      (error) => {
        if (error.response?.status === 401) {
          localStorage.removeItem('auth_token');
          localStorage.removeItem('user');
          window.location.href = '/login';
        }
        return Promise.reject(error);
      }
    );
  }

  // Auth endpoints
  login(email: string, password: string) {
    return this.api.post<LoginResponse>('/login', { email, password });
  }

  logout() {
    return this.api.post('/logout');
  }

  getCurrentUser() {
    return this.api.get<User>('/user');
  }

  // Tasks endpoints
  getTasks(page: number = 1, perPage: number = 15, filters: any = {}) {
    return this.api.get<PaginatedResponse<Task>>('/tasks', {
      params: {
        page,
        per_page: perPage,
        ...filters,
      },
    });
  }

  getTask(id: number) {
    return this.api.get<Task>(`/tasks/${id}`);
  }

  createTask(data: Partial<Task>) {
    return this.api.post<Task>('/tasks', data);
  }

  updateTask(id: number, data: Partial<Task>) {
    return this.api.put<Task>(`/tasks/${id}`, data);
  }

  deleteTask(id: number) {
    return this.api.delete(`/tasks/${id}`);
  }
}

export default new ApiService();
