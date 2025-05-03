# User Creation Script

This script creates teacher and student users in Supabase using the Management API.

## Features

- Creates 4 teachers and 60 students
- Sets proper user metadata (roles, departments, etc.)
- Includes rate limiting to avoid API limits
- Handles errors gracefully
- Logs progress to console
- Saves created user data to file

## Requirements

- Node.js installed
- Supabase project with Management API access
- Service Role Key from Supabase

## Setup

1. Install dependencies:
```bash
npm install node-fetch
```

2. Configure the script:
- Open `create_users.js`
- Set `SUPABASE_URL` to your Supabase project URL
- Set `SUPABASE_SERVICE_ROLE_KEY` to your service role key

## Usage

Run the script:
```bash
node create_users.js
```

## Output

The script will:
1. Create users with progress logging to console
2. Save created user data to `created_users.json`
3. Display a summary of created users

## User Details

### Teachers
- Emails: teacher1@example.com through teacher4@example.com
- Password: DefaultPass123!
- Assigned to departments: Computer Science, Mathematics, Physics, Chemistry

### Students
- Emails: student1@example.com through student60@example.com
- Password: DefaultPass123!
- Includes student ID and metadata

## Error Handling

- Failed user creations are logged but don't stop the script
- Rate limiting prevents API overload
- Configuration validation before execution