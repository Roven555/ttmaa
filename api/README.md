# Team Task Manager

Full-stack task management app — **Laravel 11** API + **Vue 3** SPA (TypeScript, Vuetify 3).

Admins manage all tasks; regular users manage only their own. Tasks have title, description, status (`todo` / `in_progress` / `done`), priority (`low` / `medium` / `high`), due date, and assignee.

## Setup & Run

### Prerequisites

PHP 8.3+, Composer, Node.js 18+, MySQL 8.

### Backend

```bash
cd api
composer install
cp .env.example .env
php artisan key:generate
```

Edit `api/.env` and set `DB_PASSWORD` to your MySQL root password, then:

```bash
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS task_manager;"
php artisan migrate --seed
php artisan serve            # → http://localhost:8000
```

### Frontend

```bash
cd client
npm install
npm run dev                  # → http://localhost:3000
```

## Test Credentials

After `php artisan migrate --seed`:

| Role  | Email               | Password   |
|-------|---------------------|------------|
| Admin | admin@example.com   | password   |
| User  | user@example.com    | password   |
| User  | jane@example.com    | password   |

## Assumptions & Simplifications

- **No automated tests** — omitted to focus on core functionality within the time constraint. In production I would add PHPUnit feature tests for every endpoint and Vitest component tests.
- **Token in localStorage** — acceptable for this demo. In production, httpOnly cookies with `SameSite=Strict` would be safer.
- **No rate limiting** — would add `throttle` middleware on the login route in production.
- **Soft deletes on tasks** — tasks are never truly removed from the database, allowing recovery.
- **Admin can assign tasks** — regular users can only create tasks for themselves.

## API Endpoints

```
POST   /api/login          — get Bearer token
POST   /api/logout         — revoke token
GET    /api/user           — current user
GET    /api/users          — all users (for assignee dropdown)
GET    /api/tasks          — list (paginated, filterable by status/priority/search)
POST   /api/tasks          — create
GET    /api/tasks/{id}     — show
PUT    /api/tasks/{id}     — update
DELETE /api/tasks/{id}     — delete (soft)
```

All endpoints except `/login` require `Authorization: Bearer {token}`.

---

## Written Questions

### 1. Performance: Scaling `GET /api/tasks` to 1M+ rows

- **Database indexes** — compound indexes on `(user_id, status)`, `(user_id, created_at)`, and single-column indexes on `status`, `priority`, `created_at` to avoid full table scans.
- **Cursor-based pagination** — replace offset pagination with `WHERE id > :last_id LIMIT n` to avoid the linear cost of large offsets.
- **Select only needed columns** — `->select(['id','title','status','priority','due_date'])` instead of `SELECT *` to reduce data transfer.
- **Eager loading** — `Task::with('user')` prevents N+1 queries when including assignee names.
- **Caching** — cache frequently-read filter combinations (e.g. "admin, all tasks, page 1") in Redis with short TTL; invalidate on write.
- **Read replicas** — route `GET` traffic to read replicas and writes to the primary.
- **Query result limits** — cap `per_page` at 100 server-side so clients can't request unbounded result sets.
- **Async heavy work** — offload exports, bulk deletes, and archival to Laravel queues.
- **Data archival** — move completed tasks older than a configurable threshold to an archive table to keep the hot table small.
- **Full-text search** — for the `search` filter, use MySQL `FULLTEXT` indexes or Elasticsearch instead of `LIKE '%term%'` which can't use indexes.

### 2. Security: Securing a Laravel API + Vue SPA

- **SQL injection** — Laravel Eloquent uses parameterized queries by default; never interpolate user input into raw SQL.
- **XSS** — Vue 3 auto-escapes template output by default. Avoid `v-html` with user content. On the API side, validate and sanitize inputs in Form Requests.
- **CSRF** — not needed for stateless token-based APIs (no cookies = no CSRF vector). If switching to cookie auth, use Laravel Sanctum's CSRF cookie flow.
- **Authentication tokens** — use Sanctum with short expiration. In production, store tokens in httpOnly cookies instead of localStorage to prevent XSS from exfiltrating them.
- **CORS** — restrict `allowed_origins` to the exact frontend domain instead of wildcards.
- **Rate limiting** — apply `throttle:5,1` to the login endpoint; `throttle:60,1` to authenticated routes.
- **HTTPS** — force HTTPS in production via `URL::forceScheme('https')` and HSTS headers.
- **Authorization** — use Laravel Policies (`TaskPolicy`) so users can only access their own resources. Admins bypass via the policy.
- **Input validation** — every write endpoint uses a dedicated Form Request class with strict rules (`required|string|max:255`, `in:todo,in_progress,done`, etc.).

### 3. TypeScript Benefits in Vue 3

- **Compile-time safety** — catches type errors (wrong prop types, missing fields, invalid enum values) before the code reaches the browser.
- **IDE support** — autocompletion for props, emits, store state, and API response shapes dramatically speeds up development.
- **Self-documenting** — interfaces like `Task` and `User` serve as living documentation — no need to check the API docs to know what fields exist.
- **Safe refactoring** — renaming a field or changing a type immediately highlights every file that needs updating.
- **Better team collaboration** — typed contracts between components prevent miscommunication about data shapes.

### 4. Code Sample: Vue 3 `<script setup>` with Typed Props

```vue
<script setup lang="ts">
import type { Task } from '@/types';

// Strongly typed props — TS enforces callers pass a Task[]
const props = defineProps<{
  tasks: Task[];
  isLoading: boolean;
  currentPage: number;
  perPage: number;
  total: number;
}>();

// Strongly typed emits — TS enforces event payload types
const emit = defineEmits<{
  refresh: [];
  'update:currentPage': [page: number];
  'edit-task': [task: Task];
}>();

// Full autocompletion on task properties
const editTask = (task: Task) => {
  emit('edit-task', task); // TS ensures payload matches
};
</script>
```

This component (`TaskList.vue` in this project) demonstrates typed `defineProps` and `defineEmits`. TypeScript will error at compile time if a parent passes wrong prop types or if the emit payload doesn't match the declared signature.
