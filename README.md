# Campus Connect

Campus Connect is a working MVP Flutter app for students and teachers to centralize notices, tasks, announcements, reminders, and files.

## Stack
- Flutter (mobile + web)
- Supabase (Auth, Postgres DB, Storage, realtime streams)
- Provider state management

## Features implemented
- Role-based login/signup (student, teacher, admin)
- Route protection (dashboard only after login)
- Student dashboard with:
  - Greeting
  - Important messages
  - Upcoming tasks/deadlines
  - Announcements
  - Notes/file links with open/download support
- Teacher dashboard with:
  - Create announcements
  - Send categorized messages with priority
  - Auto task conversion from message keywords
  - Student search (name/class/roll)
  - Import student class list from XLSX
  - Save Google Drive notes links
- Messages with timestamp, sender, role, category, priority
- Demo seed button for quick data
- Responsive UI:
  - Mobile bottom navigation
  - Desktop NavigationRail / two-column admin layout

## Project structure
- lib/
  - models/
  - screens/
  - services/
  - providers/
  - widgets/
  - utils/

## 1) Full setup steps

### Prerequisites
- Flutter SDK installed
- Supabase account and project
- Dart and Chrome/Android emulator for local testing

### Install
```bash
flutter pub get
```

### Supabase config used
This project currently initializes Supabase with your provided values in the service layer.
- URL: https://ghivhjejmloektsbddbu.supabase.co
- Anon key: already wired in code

Recommended for production:
- Move URL/key to environment config using `--dart-define`

### Create DB schema
Run the SQL in `supabase/schema.sql` in Supabase SQL Editor.

### Create storage bucket
In Supabase Storage:
- Create public bucket named `campus-files`

### Enable auth
In Supabase Authentication:
- Enable Email provider

## 2) Supabase schema
Tables:
- users
- students
- messages
- announcements
- tasks
- files
- announcement_reads

Full SQL is included in:
- `supabase/schema.sql`

## 3) How to run locally
```bash
flutter pub get
flutter run
```

Web:
```bash
flutter run -d chrome
```

## 4) How to deploy Flutter web on Vercel

### Build
```bash
flutter build web
```

### Deploy with Vercel CLI
```bash
npm i -g vercel
vercel
```

When prompted:
- Set output directory as: `build/web`

### Optional vercel.json
```json
{
  "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }]
}
```

## 5) GitHub README content
Use this README directly as your GitHub `README.md`.

## Class list import notes
- Teacher dashboard has an `Import Student XLSX` button.
- Expected column order in spreadsheet rows:
  1. Name
  2. Class
  3. Roll Number
  4. Section
  5. Department
  6. Email
- First row is treated as header.

## Quality notes
- This is MVP-ready and functional.
- For production hardening, add stricter RLS policies, validation, and audit logging.
