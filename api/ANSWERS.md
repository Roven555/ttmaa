# Written Questions - Answers

## Question 1: Performance Considerations for Handling 1M+ Tasks

When dealing with 1 million or more tasks, performance becomes critical. Here's a comprehensive strategy:

### 1. Database Optimization

#### Indexing Strategy
```sql
-- Primary indexes for fast lookups
CREATE INDEX idx_user_id ON tasks(user_id);
CREATE INDEX idx_status ON tasks(status);
CREATE INDEX idx_created_at ON tasks(created_at DESC);
CREATE INDEX idx_priority ON tasks(priority);

-- Composite indexes for common filter combinations
CREATE INDEX idx_user_status ON tasks(user_id, status);
CREATE INDEX idx_user_created ON tasks(user_id, created_at DESC);

-- Email index for authentication
CREATE UNIQUE INDEX idx_user_email ON users(email);
```

#### Query Optimization
- Select only needed columns:
  ```php
  // Wrong - expensive
  $tasks = Task::where('user_id', $userId)->get();

  // Better - reduce data transfer
  $tasks = Task::where('user_id', $userId)
    ->select(['id', 'title', 'status', 'priority', 'due_date'])
    ->get();
  ```

- Use eager loading to prevent N+1 queries:
  ```php
  // Wrong - will run N+1 queries
  $tasks = Task::all();
  foreach ($tasks as $task) {
      echo $task->user->name; // Query per task!
  }

  // Correct - single query
  $tasks = Task::with('user')->get();
  ```

### 2. Pagination Strategy

Never load all records at once. Always paginate:

```php
// Always paginate - default 15 per page
$tasks = Task::paginate(15);

// User can adjust, but cap it
$perPage = min(request('per_page'), 100);
$tasks = Task::paginate($perPage);
```

Frontend considerations:
- Load only current page in view
- Use virtual scrolling for large lists if needed
- Implement "load more" for infinite scroll

### 3. Caching Strategy

Implement multi-level caching:

```php
// Cache frequently accessed data (user's task count)
$taskCount = Cache::remember("user.{$userId}.task_count", 3600, function () use ($userId) {
    return Task::where('user_id', $userId)->count();
});

// Cache task summaries for dashboard
$summary = Cache::remember("user.{$userId}.summary", 1800, function () use ($userId) {
    return [
        'pending' => Task::where('user_id', $userId)->where('status', 'pending')->count(),
        'completed' => Task::where('user_id', $userId)->where('status', 'completed')->count(),
    ];
});
```

Cache invalidation strategy:
- Clear relevant cache when task is created/updated/deleted
- Use tag-based caching for granular control

```php
public function store(StoreTaskRequest $request)
{
    $task = Task::create($request->validated());

    // Invalidate user's cache
    Cache::tags(['user.' . $task->user_id])->flush();

    return new TaskResource($task);
}
```

### 4. Data Archival Strategy

For very old tasks:
```php
// Move completed tasks older than 1 year to archive table
$archived = Task::where('status', 'completed')
    ->where('updated_at', '<', now()->subYear())
    ->forceDelete(); // or move to archive table

// Return only recent tasks
$tasks = Task::where('created_at', '>', now()->subYear())->paginate();
```

### 5. Database Connection Pooling

Use connection pooling in production:
- Redis for caching
- Database connection pools (e.g., ProxySQL for MySQL)

### 6. Asynchronous Processing

For heavy operations, use queues:
```php
// Instead of processing immediately
// Queue the job
DeleteOldTasksJob::dispatch();

// Or process in background
Event::dispatch(new TasksArchivingRequired());
```

### 7. Read Replicas

For read-heavy applications:
- Use read replicas for SELECT queries
- Write to primary database only
- Load balance reads across replicas

### 8. Monitoring & Analysis

Monitor key metrics:
```php
// Add query logging in development
DB::listen(function($query) {
    Log::debug("Query took {$query->time}ms");
});

// Monitor slow queries
// Use tools like New Relic, DataDog, or Laravel Telescope
```

### TypeScript Implementation Example

For the frontend with 1M+ tasks scenario:

```typescript
// Implement virtual scrolling
import { defineComponent } from 'vue'

export default defineComponent({
  name: 'TaskListVirtual',
  props: {
    tasks: Array,
    itemHeight: {
      type: Number,
      default: 100
    }
  },
  computed: {
    visibleTasks() {
      // Only render visible items
      const start = Math.floor(this.scrollTop / this.itemHeight)
      const end = start + Math.ceil(this.clientHeight / this.itemHeight)
      return this.tasks.slice(start, end)
    }
  }
})

// API service with caching decorator
class CachedApiService {
  private cache = new Map()

  async getTasks(filters: any) {
    const key = JSON.stringify(filters)

    if (this.cache.has(key)) {
      return this.cache.get(key)
    }

    const response = await api.getTasks(filters)
    this.cache.set(key, response.data, 5 * 60 * 1000) // 5 min cache
    return response.data
  }
}
```

---

## Question 2: Security Considerations for Laravel API + Vue SPA

### 1. Authentication & Authorization

#### Token Storage

⚠️ **Security Warning**: localStorage is vulnerable to XSS attacks.

```typescript
// Less Secure: Current Implementation (for development)
localStorage.setItem('auth_token', token)

// More Secure: Use httpOnly cookies in production
// Set in Laravel response:
// setcookie('auth_token', $token, [
//     'httponly' => true,
//     'secure' => true,  // HTTPS only
//     'samesite' => 'Strict'
// ])

// Vue would automatically send cookie with requests
// No JavaScript access needed
```

**Recommendation**: In production, use httpOnly cookies with SameSite=Strict.

#### Token Expiration

```php
// Laravel Sanctum configuration
'expiration' => 60 * 24 * 365, // 1 year in minutes

// Shorter expiration for higher security
'expiration' => 60, // 1 hour

// Implement refresh tokens
public function refreshToken(Request $request)
{
    $token = Auth::user()->createToken('auth_token')->plainTextToken;

    // Optionally revoke old token
    Auth::user()->currentAccessToken()->delete();

    return response()->json(['token' => $token]);
}
```

Implementation in Vue:
```typescript
// Add token refresh interceptor
api.interceptors.response.use(
    response => response,
    async error => {
        if (error.response?.status === 401) {
            const newToken = await api.post('/refresh-token')
            localStorage.setItem('auth_token', newToken.data.token)

            // Retry original request
            return api(error.config)
        }
        return Promise.reject(error)
    }
)
```

### 2. CORS Configuration

```php
// config/cors.php or middleware
'allowed_origins' => ['http://localhost:3000'],
'allowed_methods' => ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
'allowed_headers' => ['Content-Type', 'Authorization'],
'exposed_headers' => ['Authorization'],
'max_age' => 3600,
'supports_credentials' => true,
```

Production configuration:
```php
'allowed_origins' => [
    'https://app.example.com',
    'https://www.example.com',
],
```

### 3. CSRF Protection

For form-based submissions (not needed for API with token auth):

```php
// Not needed for SPA since we use Bearer tokens
// But important if serving forms from Laravel

// In Laravel middleware
'csrf' => true,

// In Vue component (if needed)
const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
```

### 4. Input Validation & Sanitization

```php
// Laravel Form Requests
class StoreTaskRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'title' => 'required|string|max:255',
            'description' => 'nullable|string|max:1000',
            'status' => 'required|in:pending,completed',
            'priority' => 'required|in:low,medium,high',
        ];
    }

    protected function prepareForValidation()
    {
        // Sanitize input before validation
        $this->merge([
            'title' => strip_tags($this->title),
            'description' => strip_tags($this->description),
        ]);
    }
}

// Vue-side validation
export function validateTask(task: any): string[] {
    const errors: string[] = []

    if (!task.title || task.title.trim().length === 0) {
        errors.push('Title is required')
    }

    if (task.title && task.title.length > 255) {
        errors.push('Title cannot exceed 255 characters')
    }

    return errors
}
```

### 5. SQL Injection Prevention

Laravel's Eloquent ORM prevents SQL injection:

```php
// Safe - uses parameterized queries
$tasks = Task::where('user_id', $userId)->get();

// Also safe with raw queries
$tasks = DB::select('SELECT * FROM tasks WHERE user_id = ?', [$userId]);

// AVOID - vulnerable
$tasks = DB::select("SELECT * FROM tasks WHERE user_id = $userId");
```

TypeScript/Frontend: Not applicable as frontend doesn't execute SQL.

### 6. XSS (Cross-Site Scripting) Prevention

Vue 3 provides built-in XSS protection:

```vue
<!-- Safe - Vue escapes by default -->
<div>{{ user.name }}</div>

<!-- UNSAFE - never do this -->
<!-- <div v-html="unSafeHtml"></div> -->

<!-- Safe alternatives if HTML needed -->
<div v-html="sanitizedHtml"></div>
```

Sanitization library (DOMPurify):
```typescript
import DOMPurify from 'dompurify'

const clean = DOMPurify.sanitize(userInput)
```

### 7. Rate Limiting

```php
// Laravel rate limiting on login endpoint
Route::post('/login', [AuthController::class, 'login'])
    ->middleware('throttle:5,1'); // 5 attempts per minute

// Public API rate limiting
Route::middleware('throttle:60,1')->group(function () {
    Route::apiResource('tasks', TaskController::class);
});
```

Vue implementation:
```typescript
// Prevent multiple submissions
let lastSubmitTime = 0

async function handleSubmit() {
    const now = Date.now()
    if (now - lastSubmitTime < 1000) {
        // Ignore if less than 1 second since last submit
        return
    }
    lastSubmitTime = now

    await submitForm()
}
```

### 8. HTTPS in Production

```php
// Force HTTPS in production
'url' => env('APP_URL', 'https://app.example.com'),

// In Laravel middleware
if (env('APP_ENV') === 'production') {
    URL::forceScheme('https');
}
```

### 9. Security Headers

```php
// Add security headers middleware
class AddSecurityHeaders
{
    public function handle($request, $next)
    {
        $response = $next($request);

        $response->header('X-Content-Type-Options', 'nosniff');
        $response->header('X-Frame-Options', 'DENY');
        $response->header('X-XSS-Protection', '1; mode=block');
        $response->header('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
        $response->header('Content-Security-Policy', "default-src 'self'");

        return $response;
    }
}
```

### 10. Logging & Monitoring

```php
// Log security events
Log::warning('Failed login attempt', [
    'email' => $email,
    'ip' => request()->ip(),
]);

// Detect suspicious activity
if (Task::where('user_id', $userId)->count() > 10000) {
    Log::alert('User creating excessive tasks', ['user_id' => $userId]);
}
```

---

## Question 3: TypeScript Benefits and Code Sample

### Benefits of TypeScript

1. **Type Safety**: Catches errors at compile time, not runtime
2. **Autocomplete & IntelliSense**: IDEs provide better suggestions
3. **Self-Documenting Code**: Types act as documentation
4. **Refactoring**: Safe refactoring with type checking
5. **Reduced Bugs**: Fewer runtime errors in production
6. **Better Tooling**: ESLint, Prettier, and debuggers work better

### Comparison: JavaScript vs TypeScript

#### Without TypeScript (JavaScript)
```javascript
// api.js
async function getTasks(filters) {
  // What's the structure of filters?
  // What will the response look like?
  // No type hints available

  const response = await fetch('/api/tasks', {
    params: filters
  })

  return response.data
}

// component.js
const tasks = await getTasks({ search: 'test' })
// tasks could be anything - array? object? null?
// No type checking

// This bugs silently
const title = tasks.title // Wrong! tasks is array, not object
```

#### With TypeScript
```typescript
// types/index.ts
export interface Task {
  id: number
  user_id: number
  title: string
  status: 'pending' | 'completed'
  priority: 'low' | 'medium' | 'high'
}

export interface TaskFilters {
  search?: string
  status?: Task['status']
  priority?: Task['priority']
  page?: number
  per_page?: number
}

export interface ApiResponse<T> {
  data: T[]
  meta: PaginationMeta
}

// api.ts
async function getTasks(filters: TaskFilters): Promise<Task[]> {
  const response = await fetch('/api/tasks', {
    params: filters
  })

  // Type-safe response
  const data: ApiResponse<Task> = response.data
  return data.data
}

// component.ts
const tasks: Task[] = await getTasks({ search: 'test' })
// Now IDE knows tasks is Task[]
// Cannot call tasks.title - TypeScript catches this!

// Autocomplete shows all properties of Task
tasks[0].title // ✓ Valid
tasks[0].invalid_prop // ✗ TypeScript error caught before runtime!
```

### Real-World Example: Type-Safe API Service

```typescript
// services/api.ts
import axios, { AxiosError } from 'axios'
import type { Task, User, TaskFilters, LoginResponse } from '@/types'

class ApiService {
  private api = axios.create({
    baseURL: import.meta.env.VITE_API_URL
  })

  // Type-safe login
  async login(email: string, password: string): Promise<LoginResponse> {
    try {
      const response = await this.api.post<LoginResponse>('/login', {
        email,
        password,
      })
      return response.data
    } catch (error) {
      const axiosError = error as AxiosError<{ message: string }>
      throw new Error(axiosError.response?.data?.message || 'Login failed')
    }
  }

  // Type-safe task operations
  async getTasks(filters: TaskFilters): Promise<Task[]> {
    const response = await this.api.get<Task[]>('/tasks', {
      params: filters,
    })
    return response.data
  }

  async createTask(taskData: Partial<Task>): Promise<Task> {
    // TypeScript ensures taskData matches Task structure
    const { title, status, priority } = taskData

    // Compile error if required fields missing
    if (!title || !status || !priority) {
      throw new Error('Missing required fields')
    }

    const response = await this.api.post<Task>('/tasks', taskData)
    return response.data
  }

  // Type-safe filtering
  async getTasksByStatus(
    userId: number,
    status: Task['status']
  ): Promise<Task[]> {
    // status is guaranteed to be 'pending' or 'completed'
    // Can't pass invalid status: getTasksByStatus(1, 'invalid')

    return this.getTasks({
      user_id: userId,
      status,
    })
  }
}

export default new ApiService()
```

### Refactoring Safety Example

```typescript
// If we change Task interface
export interface Task {
  id: number
  title: string
  // ❌ Changed: description was removed
  // description: string

  // ✅ Changed: priority is now enum instead of string
  priority: 'low' | 'medium' | 'high' | 'urgent' // Added 'urgent'
}

// TypeScript will flag ALL places using old structure
// component.ts shows compile-time errors:
const description = task.description // ✗ Error: property doesn't exist
const isPriority = task.priority === 'critical' // ✗ Error: 'critical' not valid

// Must fix all references before deployment
// JavaScript would fail silently at runtime!
```

### Error Handling with Types

```typescript
interface ApiError {
  status: number
  message: string
  details?: Record<string, string[]>
}

async function safeApiCall<T>(
  apiFunction: () => Promise<T>
): Promise<{ data: T | null; error: ApiError | null }> {
  try {
    const data = await apiFunction()
    return { data, error: null }
  } catch (error) {
    const apiError: ApiError = {
      status: error.response?.status || 500,
      message: error.response?.data?.message || 'Unknown error',
      details: error.response?.data?.errors,
    }
    return { data: null, error: apiError }
  }
}

// Usage with full type safety
const { data: tasks, error } = await safeApiCall(() =>
  api.getTasks({ status: 'pending' })
)

if (error) {
  console.error(`API Error ${error.status}: ${error.message}`)
  // error.details is properly typed
  Object.entries(error.details || {}).forEach(([field, messages]) => {
    console.error(`${field}: ${messages.join(', ')}`)
  })
} else {
  // tasks is Task[], not any[]
  tasks.forEach(task => {
    console.log(`${task.title} - ${task.status}`)
  })
}
```

### Summary Table

| Aspect | JavaScript | TypeScript |
|--------|-----------|-----------|
| Runtime errors | Yes, caught at runtime | No, caught before deploy |
| Autocomplete | Limited | Full IDE support |
| Refactoring | Risky, manual verification | Safe, automated checking |
| Learning curve | Shorter | Steeper but worth it |
| Development speed | Faster initially | Slower initially, faster long-term |
| Maintenance | Hard in large projects | Easier with type contracts |
| Documentation | Requires comments | Built into types |
| Debugging | More trial and error | More straightforward |

TypeScript's investment pays off significantly in:
- **Medium to large projects** (100+ files)
- **Team environments** (multiple developers)
- **Production applications** (reliability critical)
- **Long-term maintenance** (code lifespans > 6 months)
