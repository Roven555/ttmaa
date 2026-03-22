# Quick Setup Instructions

## 📋 What You Have

You now have all the tools installed:
- ✅ PHP 8.3
- ✅ MySQL 8
- ✅ Node.js 18+
- ✅ npm
- ✅ Composer
- ✅ Complete Team Task Manager Application

---

## 🚀 Quick Start (3 Steps)

### **Step 1: Setup Backend**

1. Open **Command Prompt**
2. Navigate to your project:
   ```bash
   cd ttmaa
   ```
3. Run the setup script:
   ```bash
   setup-backend.bat
   ```
4. Wait for it to complete (might take 2-3 minutes for `npm install`)

### **Step 2: Start Backend Server**

1. Open a **NEW Command Prompt**
2. Navigate to api:
   ```bash
   cd ttmaa/api
   ```
3. Start Laravel:
   ```bash
   php artisan serve
   ```
4. Keep this window open. You should see:
   ```
   Laravel development server started: http://127.0.0.1:8000
   ```

### **Step 3: Start Frontend Server**

1. Open **ANOTHER NEW Command Prompt**
2. Navigate to client:
   ```bash
   cd ttmaa/client
   ```
3. Install frontend dependencies (only once):
   ```bash
   npm install
   ```
4. Start frontend:
   ```bash
   npm run dev
   ```
5. You should see:
   ```
   ➜ Local:   http://localhost:3000/
   ```

---

## 🌐 Access Your App

Once both servers are running:

1. Open your browser
2. Go to: **http://localhost:3000**
3. Login with:
   - **Email**: `admin@example.com`
   - **Password**: `password`

That's it! 🎉

---

## 📜 Test User Accounts

After setup, you can login with any of these:

| Email | Password | Role |
|-------|----------|------|
| admin@example.com | password | Admin |
| user@example.com | password | User |
| jane@example.com | password | User |

---

## 🔧 If Something Goes Wrong

### Issue: "composer: command not found"
- Make sure Composer is added to PATH
- Close and reopen Command Prompt
- Verify: `composer --version`

### Issue: "php: command not found"
- Make sure PHP is added to PATH
- Close and reopen Command Prompt
- Verify: `php -v`

### Issue: "MySQL Connection Error"
- Make sure MySQL is running
- Open MySQL Command Line Client to verify
- Check database exists: `mysql -u root -p` then `SHOW DATABASES;`

### Issue: "Port 8000 or 3000 already in use"
- Close the application using that port
- Or change port: `php artisan serve --port=8001`

### Issue: "npm ERR! code ERESOLVE"
- Run: `npm cache clean --force`
- Delete `node_modules` folder
- Run: `npm install` again

---

## 📁 Project Structure

```
ttmaa/
├── api/                    # Laravel Backend
│   ├── app/               # Controllers, Models, Policies
│   ├── database/          # Migrations, Seeders
│   ├── routes/            # API routes
│   ├── .env              # Environment config
│   └── composer.json     # PHP dependencies
│
├── client/                # Vue 3 Frontend
│   ├── src/              # Components, Pages, Services
│   ├── package.json      # npm dependencies
│   └── .env.local        # Frontend config
│
├── README.md              # Full documentation
├── API.md                 # API endpoints documentation
├── ANSWERS.md             # Written questions answers
├── setup-backend.bat      # Automated backend setup
├── setup-frontend.bat     # Automated frontend setup
└── start-servers.bat      # Start both servers
```

---

## 📚 Documentation Files

- **README.md** - Complete setup guide and features
- **API.md** - All API endpoints with examples
- **ANSWERS.md** - Answers to written questions

---

## ✅ What's Ready

- ✅ Backend with full REST API
- ✅ Frontend with Vue 3 and Vuetify
- ✅ Authentication system
- ✅ Task management (CRUD)
- ✅ Database with sample data
- ✅ Role-based access control
- ✅ Filtering and pagination
- ✅ Complete documentation

---

## 🎯 Next Steps After Setup

1. ✅ Run `setup-backend.bat`
2. ✅ Start backend server (`php artisan serve`)
3. ✅ Start frontend server (`npm run dev`)
4. ✅ Open http://localhost:3000
5. ✅ Login with admin@example.com / password
6. ✅ Create, filter, and manage tasks
7. ✅ Test with different user accounts

---

## 📞 Need Help?

Check these files:
- **Issues during setup?** → See Troubleshooting section in README.md
- **How does API work?** → See API.md
- **Written questions?** → See ANSWERS.md

---

## 🎉 Ready to Submit!

Once everything is working:

1. All source code is in the `ttmaa` folder
2. Database is set up with migrations
3. Both servers can start with simple commands
4. Documentation is complete
5. **Ready to send as assignment!** ✅
