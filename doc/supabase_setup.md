# Supabase Setup for Live Attendance Tracking

## Database Tables

### 1. live_sessions
```sql
create table live_sessions (
  id uuid default gen_random_uuid() primary key,
  course_id uuid references courses(id) not null,
  session_type text not null,
  group_ids uuid[] not null,
  start_time timestamp with time zone not null default now(),
  end_time timestamp with time zone,
  status text not null default 'active',
  qr_code_data text not null,
  created_at timestamp with time zone default now()
);

-- Index for faster queries
create index live_sessions_status_idx on live_sessions(status);
create index live_sessions_course_id_idx on live_sessions(course_id);
```

### 2. attendance_records
```sql
create table attendance_records (
  id uuid default gen_random_uuid() primary key,
  session_id uuid references live_sessions(id) not null,
  student_id uuid references profiles(id) not null,
  group_id uuid references groups(id) not null,
  timestamp timestamp with time zone default now(),
  status boolean default true,
  
  -- Prevent duplicate attendance records
  unique(session_id, student_id)
);

-- Indices for performance
create index attendance_records_session_id_idx on attendance_records(session_id);
create index attendance_records_student_group_idx on attendance_records(student_id, group_id);
```

## Realtime Configuration

1. Enable Realtime in your Supabase project dashboard:
   - Navigate to Database → Replication
   - Enable "Realtime" feature
   - Add the following tables to tracking:
     ```
     live_sessions
     attendance_records
     ```

2. Configure Publication:
```sql
-- Create publication for live attendance tables
create publication live_attendance_pub for table live_sessions, attendance_records;

-- Enable replication for these tables
alter publication live_attendance_pub add table live_sessions;
alter publication live_attendance_pub add table attendance_records;
```

## Database Policies

### live_sessions Table Policies

```sql
-- Allow teachers to create sessions for their courses
create policy "Teachers can create sessions"
on live_sessions
for insert
to authenticated
using (
  exists (
    select 1 from courses
    where id = course_id
    and teacher_id = auth.uid()
  )
);

-- Allow teachers to view their own sessions
create policy "Teachers can view their sessions"
on live_sessions
for select
to authenticated
using (
  exists (
    select 1 from courses
    where id = course_id
    and teacher_id = auth.uid()
  )
);

-- Allow teachers to update their active sessions
create policy "Teachers can update their active sessions"
on live_sessions
for update
to authenticated
using (
  exists (
    select 1 from courses
    where id = course_id
    and teacher_id = auth.uid()
  )
)
with check (status = 'active');
```

### attendance_records Table Policies

```sql
-- Allow students to mark their attendance
create policy "Students can mark attendance"
on attendance_records
for insert
to authenticated
using (
  auth.uid() = student_id
  and exists (
    select 1 from live_sessions
    where id = session_id
    and status = 'active'
    and group_ids @> array[group_id]::uuid[]
  )
);

-- Allow teachers to view attendance for their sessions
create policy "Teachers can view attendance"
on attendance_records
for select
to authenticated
using (
  exists (
    select 1 from live_sessions ls
    join courses c on ls.course_id = c.id
    where ls.id = session_id
    and c.teacher_id = auth.uid()
  )
);
```

## Authentication Settings

1. Enable Email Authentication:
   - Go to Authentication → Providers
   - Enable "Email" provider
   - Configure email templates for verification

2. Role Management:
   - Create custom claims for user roles:
   ```sql
   create type user_role as enum ('teacher', 'student');
   
   alter table auth.users
   add column role user_role default 'student';
   ```

3. Create a function to set user role:
   ```sql
   create or replace function set_user_role(user_id uuid, new_role user_role)
   returns void as $$
   begin
     update auth.users
     set role = new_role
     where id = user_id;
   end;
   $$ language plpgsql security definer;
   ```

## Testing the Setup

1. Test Realtime Connection:
```dart
final channel = Supabase.instance.client
    .channel('live_session_${sessionId}')
    .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'live_sessions',
      callback: (payload) => print('Received update: $payload'),
    );

final status = await channel.subscribe();
print('Channel subscription status: $status');
```

2. Test Attendance Record Creation:
```sql
-- Insert test attendance record
insert into attendance_records (
  session_id,
  student_id,
  group_id
) values (
  '{{session_id}}',
  '{{student_id}}',
  '{{group_id}}'
);
```

## Error Handling

1. Enable Database Webhooks for error logging
2. Set up error triggers for failed attendance attempts
3. Configure automatic cleanup of expired sessions

## Performance Considerations

1. Index Optimization:
   - Monitor query performance
   - Add composite indices for frequent queries
   - Regularly vacuum tables

2. Realtime Connection Management:
   - Implement connection pooling
   - Handle reconnection with exponential backoff
## Security Functions

### QR Code Validation
```sql
-- Function to generate secure QR code data
create or replace function generate_session_qr_code(session_id uuid)
returns text
language plpgsql security definer as $$
declare
  qr_data text;
begin
  -- Generate time-based token using session_id and current timestamp
  qr_data := encode(
    hmac(
      session_id::text || extract(epoch from now())::text,
      current_setting('app.jwt_secret'),
      'sha256'
    ),
    'hex'
  );
  
  -- Update session with new QR code
  update live_sessions
  set qr_code_data = qr_data
  where id = session_id;
  
  return qr_data;
end;
$$;

-- Function to validate QR code
create or replace function validate_session_qr_code(
  session_id uuid,
  qr_code text,
  max_age_seconds int default 300
)
returns boolean
language plpgsql security definer as $$
declare
  session_data record;
begin
  -- Get session details
  select * into session_data
  from live_sessions
  where id = session_id
  and status = 'active'
  limit 1;

  -- Validate session exists and QR code matches
  if session_data.qr_code_data = qr_code
     and extract(epoch from now() - session_data.start_time) <= max_age_seconds
  then
    return true;
  else
    return false;
  end if;
end;
$$;
```

### Location Validation
```sql
-- Add location support to attendance_records
alter table attendance_records
add column location point;

-- Function to validate check-in location
create or replace function validate_checkin_location(
  session_id uuid,
  student_location point,
  max_distance_meters int default 100
)
returns boolean
language plpgsql security definer as $$
declare
  session_location point;
begin
  -- Get session location
  select location into session_location
  from live_sessions
  where id = session_id;

  -- Calculate distance and validate
  if point_distance(session_location, student_location) <= max_distance_meters then
    return true;
  else
    return false;
  end if;
end;
$$;
```

## Rate Limiting

1. Create rate limiting table:
```sql
create table rate_limits (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id),
  action text not null,
  timestamp timestamp with time zone default now(),
  
  -- Add constraints for cleanup
  constraint rate_limits_cleanup
    check (timestamp > now() - interval '1 day')
);

-- Index for efficient querying
create index rate_limits_user_action_idx 
on rate_limits(user_id, action, timestamp);
```

2. Create rate limiting function:
```sql
create or replace function check_rate_limit(
  user_id uuid,
  action text,
  max_requests int,
  window_minutes int
)
returns boolean
language plpgsql security definer as $$
declare
  request_count int;
begin
  -- Count requests in time window
  select count(*)
  into request_count
  from rate_limits
  where user_id = user_id
    and action = action
    and timestamp > now() - (window_minutes || ' minutes')::interval;

  -- Clean up old entries
  delete from rate_limits
  where timestamp <= now() - interval '1 day';

  -- Check if under limit
  if request_count < max_requests then
    -- Record new request
    insert into rate_limits (user_id, action)
    values (user_id, action);
    return true;
  else
    return false;
  end if;
end;
$$;
```

## Statistics Functions

```sql
-- Function to get session statistics
create or replace function get_session_stats(session_id uuid)
returns json
language plpgsql security definer as $$
declare
  result json;
begin
  select json_build_object(
    'totalStudents', (
      select count(distinct student_id)
      from attendance_records
      where session_id = session_id
    ),
    'presentStudents', (
      select count(distinct student_id)
      from attendance_records
      where session_id = session_id
      and status = true
    ),
    'recentCheckins', (
      select json_agg(ar.*)
      from (
        select *
        from attendance_records
        where session_id = session_id
        order by timestamp desc
        limit 5
      ) ar
    )
  ) into result;

  return result;
end;
$$;
```

## Monitoring and Maintenance

1. Create monitoring tables:
```sql
-- Track session performance
create table session_metrics (
  id uuid default gen_random_uuid() primary key,
  session_id uuid references live_sessions(id),
  concurrent_connections int,
  message_count int,
  timestamp timestamp with time zone default now()
);

-- Track error events
create table error_events (
  id uuid default gen_random_uuid() primary key,
  session_id uuid references live_sessions(id),
  error_type text,
  error_message text,
  timestamp timestamp with time zone default now()
);
```

2. Set up automated cleanup:
```sql
-- Create cleanup function
create or replace function cleanup_old_sessions()
returns void
language plpgsql security definer as $$
begin
  -- Archive completed sessions older than 30 days
  insert into archived_sessions
  select *
  from live_sessions
  where status = 'completed'
    and end_time < now() - interval '30 days';

  -- Delete archived sessions
  delete from live_sessions
  where status = 'completed'
    and end_time < now() - interval '30 days';

  -- Clean up related tables
  delete from session_metrics
  where timestamp < now() - interval '30 days';
  
  delete from error_events
  where timestamp < now() - interval '30 days';
end;
$$;

-- Create cron job for cleanup
select cron.schedule(
  'cleanup-old-sessions',
  '0 0 * * *', -- Run daily at midnight
  $$
    select cleanup_old_sessions();
  $$
);
```
   - Monitor channel status