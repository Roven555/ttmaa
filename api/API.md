# API Documentation

## Base URL

```
http://localhost:8000/api
```

## Authentication

All endpoints (except `/login`) require authentication using Bearer tokens.

### Header Format
```
Authorization: Bearer {token}
```

### Getting a Token

**Endpoint**: `POST /login`

**Request**:
```json
{
  "email": "admin@example.com",
  "password": "password"
}
```

**Response** (200):
```json
{
  "token": "1|abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890",
  "user": {
    "id": 1,
    "name": "Admin User",
    "email": "admin@example.com",
    "role": "admin",
    "created_at": "2024-03-22T10:00:00.000000Z"
  }
}
```

**Response** (401):
```json
{
  "message": "Invalid credentials"
}
```

---

## Authentication Endpoints

### POST /login

Login with email and password to get authentication token.

**Request**:
```json
{
  "email": "user@example.com",
  "password": "password"
}
```

**Response**: 200 OK
```json
{
  "token": "auth_token_here",
  "user": { /* User object */ }
}
```

**Errors**:
- `401 Unauthorized`: Invalid credentials

---

### POST /logout

Logout and revoke the current token.

**Headers**:
```
Authorization: Bearer {token}
```

**Response**: 200 OK
```json
{
  "message": "Logged out successfully"
}
```

---

### GET /user

Get the current authenticated user's profile.

**Headers**:
```
Authorization: Bearer {token}
```

**Response**: 200 OK
```json
{
  "id": 1,
  "name": "Admin User",
  "email": "admin@example.com",
  "role": "admin",
  "created_at": "2024-03-22T10:00:00.000000Z"
}
```

---

## Task Endpoints

### GET /tasks

List tasks with optional filtering, searching, and pagination.

**Headers**:
```
Authorization: Bearer {token}
```

**Query Parameters**:
| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `page` | integer | Page number (1-indexed) | `1` |
| `per_page` | integer | Items per page (default: 15) | `20` |
| `search` | string | Search in title and description | `"meeting"` |
| `status` | string | Filter by status: `pending` or `completed` | `pending` |
| `priority` | string | Filter by priority: `low`, `medium`, or `high` | `high` |
| `user_id` | integer | Filter by user (admin only) | `2` |

**Response**: 200 OK
```json
{
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "title": "Complete project",
      "description": "Finish the task manager app",
      "status": "completed",
      "priority": "high",
      "due_date": "2024-03-25T18:00:00.000000Z",
      "created_by": 1,
      "created_at": "2024-03-22T10:00:00.000000Z",
      "updated_at": "2024-03-22T15:30:00.000000Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "from": 1,
    "last_page": 5,
    "per_page": 15,
    "to": 15,
    "total": 67,
    "path": "http://localhost:8000/api/tasks"
  },
  "links": {
    "first": "http://localhost:8000/api/tasks?page=1",
    "last": "http://localhost:8000/api/tasks?page=5",
    "prev": null,
    "next": "http://localhost:8000/api/tasks?page=2"
  }
}
```

**Notes**:
- Regular users only see their own tasks
- Admin users see all tasks unless filtered by `user_id`

---

### POST /tasks

Create a new task.

**Headers**:
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request**:
```json
{
  "title": "Review code",
  "description": "Review PR #123",
  "status": "pending",
  "priority": "medium",
  "due_date": "2024-03-25T18:00:00Z",
  "user_id": 2
}
```

**Field Rules**:
| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `title` | string | Yes | Max 255 characters |
| `description` | string | No | - |
| `status` | string | Yes | `pending` or `completed` |
| `priority` | string | Yes | `low`, `medium`, or `high` |
| `due_date` | datetime | No | Valid ISO date |
| `user_id` | integer | No | Must exist in users table (admin only to specify) |

**Response**: 201 Created
```json
{
  "id": 15,
  "user_id": 1,
  "title": "Review code",
  "description": "Review PR #123",
  "status": "pending",
  "priority": "medium",
  "due_date": "2024-03-25T18:00:00.000000Z",
  "created_by": 1,
  "created_at": "2024-03-22T16:00:00.000000Z",
  "updated_at": "2024-03-22T16:00:00.000000Z"
}
```

**Errors**:
- `422 Unprocessable Entity`: Validation fails
  ```json
  {
    "message": "The title field is required.",
    "errors": {
      "title": ["The title field is required."],
      "status": ["The status field is required."]
    }
  }
  ```

---

### GET /tasks/{id}

Get a single task by ID.

**Headers**:
```
Authorization: Bearer {token}
```

**URL Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | integer | Task ID |

**Response**: 200 OK
```json
{
  "id": 1,
  "user_id": 1,
  "title": "Complete project",
  "description": "Finish the task manager app",
  "status": "completed",
  "priority": "high",
  "due_date": "2024-03-25T18:00:00.000000Z",
  "created_by": 1,
  "created_at": "2024-03-22T10:00:00.000000Z",
  "updated_at": "2024-03-22T15:30:00.000000Z"
}
```

**Errors**:
- `403 Forbidden`: User doesn't have permission to view this task
- `404 Not Found`: Task doesn't exist

---

### PUT /tasks/{id}

Update an existing task.

**Headers**:
```
Authorization: Bearer {token}
Content-Type: application/json
```

**URL Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | integer | Task ID |

**Request** (any or all fields):
```json
{
  "title": "Updated title",
  "status": "completed",
  "priority": "low"
}
```

**Response**: 200 OK
```json
{
  "id": 1,
  "user_id": 1,
  "title": "Updated title",
  "description": "Finish the task manager app",
  "status": "completed",
  "priority": "low",
  "due_date": "2024-03-25T18:00:00.000000Z",
  "created_by": 1,
  "created_at": "2024-03-22T10:00:00.000000Z",
  "updated_at": "2024-03-22T16:30:00.000000Z"
}
```

**Errors**:
- `403 Forbidden`: User doesn't have permission to update this task
- `404 Not Found`: Task doesn't exist
- `422 Unprocessable Entity`: Validation fails

---

### DELETE /tasks/{id}

Delete a task.

**Headers**:
```
Authorization: Bearer {token}
```

**URL Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | integer | Task ID |

**Response**: 200 OK
```json
{
  "message": "Task deleted successfully"
}
```

**Errors**:
- `403 Forbidden`: User doesn't have permission to delete this task
- `404 Not Found`: Task doesn't exist

---

## Error Responses

### Standard Error Format

All errors follow this format:

```json
{
  "message": "Error message here",
  "status": 400
}
```

### Common HTTP Status Codes

| Status | Meaning | Example |
|--------|---------|---------|
| 200 | OK | Request succeeded |
| 201 | Created | Resource created successfully |
| 400 | Bad Request | Malformed request |
| 401 | Unauthorized | Missing/invalid token |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource doesn't exist |
| 422 | Unprocessable Entity | Validation failed |
| 500 | Server Error | Internal server error |

### Validation Error Response

```json
{
  "message": "The given data was invalid.",
  "errors": {
    "email": [
      "The email field is required."
    ],
    "password": [
      "The password field must be at least 8 characters."
    ]
  }
}
```

---

## Rate Limiting

Currently no rate limiting is implemented. In production, consider implementing rate limiting on the login endpoint.

## CORS

The API is configured for CORS. For frontend on `http://localhost:3000`, make sure your requests include:
```
Origin: http://localhost:3000
```

## Testing the API

### Using curl

**Login**:
```bash
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"password"}'
```

**Get Tasks** (replace TOKEN with actual token):
```bash
curl -X GET "http://localhost:8000/api/tasks?page=1&per_page=10" \
  -H "Authorization: Bearer TOKEN"
```

**Create Task**:
```bash
curl -X POST http://localhost:8000/api/tasks \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "New Task",
    "status": "pending",
    "priority": "high"
  }'
```

### Using Postman

1. Create `POST` request to `http://localhost:8000/api/login`
2. In Body (raw JSON), add credentials
3. Copy the token from response
4. Create new requests with `Authorization: Bearer {token}` header

---

## Response Examples by Scenario

### Login Flow
```
POST /login -> 200 OK with token
GET /user -> 200 OK with user data
POST /logout -> 200 OK (token revoked)
GET /tasks -> 401 Unauthorized (no token)
```

### Task Management Flow
```
POST /tasks -> 201 Created (task created)
GET /tasks -> 200 OK with paginated list
GET /tasks/1 -> 200 OK (user can access) or 403 Forbidden (not owner)
PUT /tasks/1 -> 200 OK (updated)
DELETE /tasks/1 -> 200 OK (deleted)
GET /tasks/1 -> 404 Not Found (already deleted)
```
