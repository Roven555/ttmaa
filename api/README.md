# Team Task Manager Application

A full-stack task management application built with **Laravel 11** (PHP 8.3) backend and **Vue 3** (TypeScript) frontend with **Vuetify 3** UI framework.

## Features

- **User Authentication**: Simple login/logout system with role-based access
- **Role-Based Access Control**: Admin users can manage all tasks, regular users can only manage their own
- **Task Management**: Create, read, update, and delete tasks
- **Task Filtering**: Filter tasks by status, priority, and search by title/description
- **Pagination**: Handle large task lists efficiently
- **Responsive UI**: Built with Vuetify 3 for modern, responsive design
- **RESTful API**: Clean, well-structured JSON REST API

## Tech Stack

### Backend
- **Framework**: Laravel 11
- **Language**: PHP 8.3
- **Database**: MySQL 8
- **Authentication**: Laravel Sanctum (API tokens)
- **Validation**: Form Requests

### Frontend
- **Framework**: Vue 3
- **Language**: TypeScript
- **UI Framework**: Vuetify 3
- **State Management**: Pinia
- **HTTP Client**: Axios
- **Routing**: Vue Router 4
- **Build Tool**: Vite

## Project Structure

```
.
├── api/                          # Laravel Backend
│   ├── app/
│   │   ├── Models/              # Database models
│   │   ├── Http/
│   │   │   ├── Controllers/     # API controllers
│   │   │   ├── Requests/        # Form request validation
│   │   │   └── Resources/       # API response resources
│   │   └── Policies/            # Authorization policies
│   ├── database/
│   │   ├── migrations/          # Database schema
│   │   └── seeders/             # Database seeders
│   ├── routes/
│   │   └── api.php              # API routes
│   └── .env.example             # Environment template
│
├── client/                       # Vue 3 Frontend
│   ├── src/
│   │   ├── components/          # Reusable components
│   │   ├── pages/               # Page components
│   │   ├── services/            # API service layer
│   │   ├── stores/              # Pinia stores
│   │   ├── types/               # TypeScript interfaces
│   │   ├── router/              # Vue Router config
│   │   ├── App.vue              # Root component
│   │   └── main.ts              # Entry point
│   ├── index.html               # HTML template
│   ├── vite.config.ts           # Vite config
│   ├── tsconfig.json            # TypeScript config
│   └── .env.local               # Environment vars
│
├── README.md                     # This file
├── API.md                        # API documentation
└── ANSWERS.md                    # Written questions answers
```

## Prerequisites

- **Node.js** (v18 or higher) - for frontend
- **PHP** (v8.3 or higher) - for backend
- **Composer** - PHP package manager
- **MySQL** (v8 or compatible) - database

## Installation & Setup

### Backend Setup

1. **Navigate to the API directory**:
   ```bash
   cd api
   ```

2. **Install PHP dependencies**:
   ```bash
   composer install
   ```

3. **Copy environment file**:
   ```bash
   cp .env.example .env
   ```

4. **Generate application key** (if composer scripts don't run automatically):
   ```bash
   php artisan key:generate
   ```

5. **Create MySQL database**:
   ```sql
   CREATE DATABASE task_manager;
   ```

6. **Update database credentials in `.env`**:
   ```env
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=task_manager
   DB_USERNAME=root
   DB_PASSWORD=your_password
   ```

7. **Run migrations**:
   ```bash
   php artisan migrate
   ```

8. **Seed default users** (optional):
   ```bash
   php artisan db:seed
   ```

9. **Start Laravel development server**:
   ```bash
   php artisan serve
   ```
   The API will be available at `http://localhost:8000`

### Frontend Setup

1. **Navigate to the client directory** (in a new terminal):
   ```bash
   cd client
   ```

2. **Install Node dependencies**:
   ```bash
   npm install
   ```

3. **Update API URL in `.env.local`** (if needed):
   ```env
   VITE_API_URL=http://localhost:8000/api
   ```

4. **Start development server**:
   ```bash
   npm run dev
   ```
   The frontend will be available at `http://localhost:3000`

## Default Test Users

After seeding the database, you can login with:

### Admin User
- **Email**: `admin@example.com`
- **Password**: `password`

### Regular User
- **Email**: `user@example.com`
- **Password**: `password`

### Another Regular User
- **Email**: `jane@example.com`
- **Password**: `password`

## Usage

1. **Start both servers** (backend and frontend)
2. **Open browser** and navigate to `http://localhost:3000`
3. **Login** with one of the test credentials
4. **Create tasks** using the "Create Task" button
5. **Filter and search** tasks using the filters
6. **Edit tasks** by clicking the edit button
7. **Delete tasks** by clicking the delete button
8. **Logout** using the user menu in the top-right

## API Documentation

For detailed API documentation, see [API.md](./API.md)

### Quick API Examples

**Login**:
```bash
POST /api/login
{
  "email": "admin@example.com",
  "password": "password"
}
```

**Get Tasks**:
```bash
GET /api/tasks?page=1&per_page=15&status=pending
Authorization: Bearer {token}
```

**Create Task**:
```bash
POST /api/tasks
Authorization: Bearer {token}
{
  "title": "My Task",
  "description": "Task description",
  "priority": "high",
  "status": "pending",
  "user_id": 1
}
```

## Database Reset

To reset the database and start fresh:

### Using Laravel Artisan:
```bash
php artisan migrate:refresh --seed
```

### Or manually:
```sql
DROP DATABASE task_manager;
CREATE DATABASE task_manager;
```

Then run migrations again:
```bash
php artisan migrate --seed
```

## Troubleshooting

### "Connection refused" for database
- Ensure MySQL is running
- Check database credentials in `.env`
- Verify the `task_manager` database exists

### "CORS error" or "Cannot reach API"
- Ensure Laravel server is running on `http://localhost:8000`
- Verify `VITE_API_URL` in `client/.env.local`

### "npm install" fails
- Run `npm cache clean --force`
- Delete `node_modules` and `package-lock.json`
- Try again: `npm install`

### "composer install" fails
- Ensure PHP 8.3+ is installed: `php -v`
- Update Composer: `composer self-update`
- Try again: `composer install`

## Performance Considerations

For handling 1M+ tasks, refer to [ANSWERS.md](./ANSWERS.md) for detailed performance optimization strategies including:
- Database indexing
- Query optimization
- Pagination strategies
- Caching considerations

## Security Considerations

Refer to [ANSWERS.md](./ANSWERS.md) for security implementation details including:
- CORS configuration
- CSRF token handling
- Input validation
- SQL injection prevention
- XSS prevention
- Rate limiting
- Secure token storage

## Development

### Running Tests

Frontend:
```bash
npm run test
```

Backend:
```bash
php artisan test
```

### Build for Production

Frontend:
```bash
npm run build
```
Output will be in `client/dist/`

Backend is already production-ready. For production deployment:
1. Set `APP_ENV=production` in `.env`
2. Set `APP_DEBUG=false` in `.env`
3. Ensure proper database backups
4. Configure HTTPS/SSL
5. Set up proper error logging

## License

This project is part of an HR assignment for Full-Stack Web Developer position.

## Support

For issues or questions, refer to the API documentation or check the written answers at [ANSWERS.md](./ANSWERS.md)
