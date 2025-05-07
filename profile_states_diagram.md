# Profile States and Transitions Sequence Diagram

This diagram illustrates the complete flow of profile states and transitions during the attendance process, including real-time updates and database interactions.

```mermaid
sequenceDiagram
    participant Student
    participant StudentProfileNotifier
    participant TeacherProfileNotifier
    participant LiveSessionSocket
    participant Database
    participant TeacherClient

    rect rgb(200, 220, 255)
        Note over Student,Database: Profile Loading & State Management
        Student->>StudentProfileNotifier: Initialize
        StudentProfileNotifier->>Database: Query profiles table
        activate StudentProfileNotifier
        Database-->>StudentProfileNotifier: Return StudentProfile data
        StudentProfileNotifier->>StudentProfileNotifier: Set state to LOADED
        deactivate StudentProfileNotifier

        TeacherClient->>TeacherProfileNotifier: Initialize
        TeacherProfileNotifier->>Database: Query teacher_profiles
        activate TeacherProfileNotifier
        Database-->>TeacherProfileNotifier: Return TeacherProfile data
        TeacherProfileNotifier->>TeacherProfileNotifier: Set state to ACTIVE
        deactivate TeacherProfileNotifier
    end

    rect rgb(220, 240, 220)
        Note over Student,TeacherClient: Live Session Initialization
        TeacherClient->>LiveSessionSocket: connect(sessionId)
        LiveSessionSocket->>Database: Subscribe to live_sessions channel
        LiveSessionSocket->>Database: Subscribe to attendance_records channel
        LiveSessionSocket->>TeacherProfileNotifier: Set state to IN_SESSION
    end

    rect rgb(255, 220, 220)
        Note over Student,TeacherClient: Attendance Recording Flow
        Student->>LiveSessionSocket: Submit attendance
        LiveSessionSocket->>Database: Insert attendance_record
        Database-->>LiveSessionSocket: Trigger PostgresChanges
        LiveSessionSocket->>TeacherClient: Stream attendance update
        par Real-time Stats Update
            LiveSessionSocket->>TeacherClient: Update LiveSessionStats
        and Profile State Sync
            LiveSessionSocket->>StudentProfileNotifier: Update attendance state
            LiveSessionSocket->>TeacherProfileNotifier: Update session stats
        end
    end

    rect rgb(240, 220, 240)
        Note over TeacherClient,Database: Group Management
        TeacherClient->>TeacherProfileNotifier: Switch active group
        TeacherProfileNotifier->>Database: Query group attendance
        Database-->>TeacherProfileNotifier: Return filtered records
        TeacherProfileNotifier->>TeacherClient: Update group view
    end

    rect rgb(255, 240, 220)
        Note over Student,TeacherClient: Session Cleanup
        TeacherClient->>LiveSessionSocket: disconnect()
        LiveSessionSocket-->>TeacherProfileNotifier: Set state to ACTIVE
        LiveSessionSocket-->>Database: Unsubscribe from channels
    end
```

## State Transitions

### Student Profile States
- INITIALIZING → LOADED → IN_SESSION
- IN_SESSION → ATTENDANCE_RECORDED
- ATTENDANCE_RECORDED → LOADED

### Teacher Profile States
- INITIALIZING → ACTIVE → IN_SESSION
- IN_SESSION → MONITORING
- MONITORING → ACTIVE

### Live Session States
- CONNECTING → SUBSCRIBED
- SUBSCRIBED → ACTIVE
- ACTIVE → DISCONNECTED

## Database Tables
1. profiles
   - Base profile information
   - Shared between students and teachers

2. teacher_profiles
   - Teacher-specific profile data
   - Department and employee information

3. live_sessions
   - Active attendance sessions
   - Real-time session statistics

4. attendance_records
   - Attendance submissions
   - Timestamp and session data

## Real-time Components
- LiveSessionSocketService manages WebSocket connections
- PostgresChanges subscriptions for live updates
- Broadcast channels for attendance updates
- Stream controllers for UI synchronization
