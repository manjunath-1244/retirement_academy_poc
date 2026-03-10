# Retirement Academy POC

A Ruby on Rails learning platform where unions can manage member training courses, section content (videos/images/text/review), and completion tracking.

## Core Features

- Public landing page with editable intro content
- Devise authentication (`Sign In`, `Sign Up`, show/hide password)
- Role-based access:
  - `super_admin`
  - `admin`
  - `member` (normal user)
- Union management (super admin)
- User-to-multiple-unions assignment
- Course management with section/content authoring
- Drag-and-drop course ordering (super admin)
- Learner flow with item-by-item section navigation
- Final quiz flow with per-question feedback
- Section and course completion tracking
- Course completion rules (all sections + quiz when configured)
- Automatic course completion email (sent once on first completion)
- Admin/super admin progress report by union/course

## Roles and Access

### Super Admin

- Full access to admin dashboard
- Create/edit/delete unions
- Create/edit/delete users
- Assign users to multiple unions
- Manage all courses
- Drag and drop course order
- Edit landing page content

### Admin

- Manage courses in admin panel (scoped by admin access rules in code)
- Add/edit sections and content
- Assign users to own union(s)
- View progress reports

### Member (Normal User)

- View assigned courses
- Open section content item by item
- Mark section complete
- Complete courses
- Take final quiz (if configured)
- Receive completion email after first successful completion

## Tech Stack

- Ruby: `2.7.8`
- Rails: `7.1.x`
- Database: PostgreSQL
- Auth: Devise
- Mail: Action Mailer (development testing via MailCatcher)
- Storage: Active Storage

## Local Setup

### 1) Install dependencies

```bash
bundle install
```

### 2) Database setup

```bash
bin/rails db:create
bin/rails db:migrate
```

### 3) Run server

```bash
bin/rails server
```

Open: `http://localhost:3000`

### 4) Run MailCatcher (for local email testing)

```bash
bundle exec mailcatcher
```

SMTP: `127.0.0.1:1025`  
Inbox UI: `http://127.0.0.1:1080`

## Run Tests

```bash
bin/rails test
```

## Make a User Super Admin (Console)

```bash
bin/rails c
user = User.find_by!(email: "user@example.com")
user.update!(role: "super_admin")
```

## Git Push Steps

Use these commands from project root:

```bash
git status
git add .
git commit -m "Implement role-based union/course platform updates"
git branch -M main
git remote add origin <YOUR_GIT_REPO_URL>   # run once if remote not added
git push -u origin main
```

If remote already exists:

```bash
git push
```

## Important Paths

- Routes: `config/routes.rb`
- Admin controllers: `app/controllers/admin/`
- Learner controllers: `app/controllers/course_lists_controller.rb`, `app/controllers/course_list_sections_controller.rb`
- Quiz controller: `app/controllers/course_list_quizzes_controller.rb`
- Mailers: `app/mailers/`
- Landing page: `app/controllers/home_controller.rb`, `app/views/home/index.html.erb`
- Styles/JS: `app/assets/stylesheets/application.css`, `app/assets/javascripts/application.js`

## Notes

- Frontpage text changes are stored in DB and persist after restart.
- Course order drag/drop persists in DB (`course_lists.position`).
- Completion email is sent only once when a course first reaches completed state.
