# System Diagrams

## Database Schema Diagram

```mermaid
erDiagram
    departments ||--o{ courses : contains
    departments ||--o{ teacher_profiles : employs
    departments ||--o{ student_groups : has
    
    profiles ||--|| admin_profiles : extends
    profiles ||--|| student_profiles : extends
    profiles ||--|| teacher_profiles : extends
    
    student_groups ||--o{ student_profiles : contains
    student_groups ||--o{ group_courses : has
    
    courses ||--o{ group_courses : assigned_to
    
    teacher_profiles ||--o{ teacher_course_groups : teaches
    courses ||--o{ teacher_course_groups : taught_by
    student_groups ||--o{ teacher_course_groups : taught_to
    
    time_slots ||--o{ weekly_schedule : used_in
    teacher_profiles ||--o{ weekly_schedule : teaches
    courses ||--o{ weekly_schedule : scheduled
    student_groups ||--o{ weekly_schedule : attends
    
    weekly_schedule ||--o{ sessions : generates
    sessions ||--o{ attendance : tracks
    student_profiles ||--o{ attendance : records
    
    departments {
        UUID id PK
        string name
        string code
    }
    
    profiles {
        UUID id PK
        string first_name
        string last_name
        string role
        string phone
    }
    
    student_groups {
        UUID id PK
        UUID department_id FK
        int academic_year
        int current_year
        string section
        string name
    }
    
    courses {
        UUID id PK
        string code
        string title
        string description
        int credit_hours
        UUID department_id FK
        int year_of_study
        string semester
    }

    admin_profiles {
        UUID id PK
        UUID profile_id FK
    }

    student_profiles {
        UUID id PK
        UUID profile_id FK
        UUID student_group_id FK
        string student_id
    }

    teacher_profiles {
        UUID id PK
        UUID profile_id FK
        UUID department_id FK
        string employee_id
    }

    group_courses {
        UUID id PK
        UUID course_id FK
        UUID student_group_id FK
        string academic_year
    }

    teacher_course_groups {
        UUID id PK
        UUID teacher_id FK
        UUID course_id FK
        UUID student_group_id FK
        string academic_year
    }

    time_slots {
        UUID id PK
        string start_time
        string end_time
        string day_of_week
    }

    weekly_schedule {
        UUID id PK
        UUID time_slot_id FK
        UUID teacher_id FK
        UUID course_id FK
        UUID student_group_id FK
        string room_number
    }

    sessions {
        UUID id PK
        UUID schedule_id FK
        datetime start_time
        datetime end_time
        string status
    }

    attendance {
        UUID id PK
        UUID session_id FK
        UUID student_id FK
        datetime timestamp
        string status
    }
```

## Authentication Flow Diagram

```mermaid
stateDiagram-v2
    [*] --> Loading
    Loading --> CheckAuth
    
    CheckAuth --> Authenticated
    CheckAuth --> Unauthenticated
    
    Unauthenticated --> LoginScreen
    LoginScreen --> CheckAuth
    
    Authenticated --> CheckRole
    CheckRole --> NoRole: role == null
    NoRole --> LoginScreen
    
    CheckRole --> TeacherFeature: role == teacher
    CheckRole --> StudentFeature: role == student
    CheckRole --> RoleSelection: role == undefined
    
    RoleSelection --> CheckRole
```

## Role-based Access Control Diagram

```mermaid
graph TB
    User --> Auth[Authentication]
    Auth --> Role[Role Check]
    
    Role -->|No Role| Login[Login Screen]
    Role -->|Teacher| RoleGuard1[Teacher Role Guard]
    Role -->|Student| RoleGuard2[Student Role Guard]
    
    RoleGuard1 -->|Authorized| TeacherFeature[Teacher Feature]
    RoleGuard2 -->|Authorized| StudentFeature[Student Feature]
    
    RoleGuard1 -->|Unauthorized| Login
    RoleGuard2 -->|Unauthorized| Login
```

## Department and Course Structure

```mermaid
graph TB
    subgraph Departments
        CSE[Computer Science & Engineering]
        EE[Electrical Engineering]
        ME[Mechanical Engineering]
        CE[Civil Engineering]
        MP[Mathematics & Physics]
    end
    
    CSE --> CSE1[CSE101: Intro to Programming]
    CSE --> CSE2[CSE102: Data Structures]
    CSE --> CSE3[CSE201: Database Systems]
    CSE --> CSE4[CSE301: Software Engineering]
    
    EE --> EE1[EE101: Circuit Analysis]
    EE --> EE2[EE102: Digital Electronics]
    EE --> EE3[EE201: Signals and Systems]
    
    ME --> ME1[ME101: Engineering Mechanics]
    ME --> ME2[ME102: Thermodynamics]
    ME --> ME3[ME201: Fluid Mechanics]
    
    CE --> CE1[CE101: Structural Analysis]
    CE --> CE2[CE102: Construction Materials]
    CE --> CE3[CE201: Soil Mechanics]
    
    MP --> MP1[MP101: Calculus I]
    MP --> MP2[MP102: Physics Mechanics]
    MP --> MP3[MP201: Linear Algebra]
```

## Session Management Flow

```mermaid
sequenceDiagram
    participant Teacher
    participant System
    participant Student
    participant QR
    
    Teacher->>System: Create Session
    System->>System: Generate QR Code
    System->>Teacher: Display QR Code
    
    Student->>QR: Scan QR Code
    QR->>System: Submit Attendance
    System->>Student: Confirm Attendance
    
    System->>Teacher: Update Attendance List
    
    Note over System: Store in attendance table
    Note over System: Link to weekly_schedule
```

## QR Code Attendance Activity Flow

```mermaid
stateDiagram-v2
    [*] --> TeacherLogin
    TeacherLogin --> ValidateRole: Authenticate
    ValidateRole --> CreateSession: Valid Teacher
    ValidateRole --> TeacherLogin: Invalid Role

    CreateSession --> GenerateQR: Start Session
    GenerateQR --> DisplayQR: QR Generated
    DisplayQR --> WaitingForStudents: Display Active

    state WaitingForStudents {
        [*] --> AcceptingScans
        AcceptingScans --> UpdateList: Student Scans
        UpdateList --> AcceptingScans: Wait for More
    }

    WaitingForStudents --> EndSession: Teacher Ends Session
    WaitingForStudents --> AutoEnd: Session Timeout

    state StudentFlow {
        [*] --> StudentLogin
        StudentLogin --> ScanQR: Valid Student
        StudentLogin --> StudentLogin: Invalid Role
        ScanQR --> ConfirmAttendance: Valid QR
        ScanQR --> DisplayError: Invalid QR
        DisplayError --> ScanQR: Try Again
    }

    EndSession --> SaveAttendance
    AutoEnd --> SaveAttendance
    SaveAttendance --> [*]
```

## Flutter App Feature Structure

```mermaid
graph TB
    subgraph lib[lib directory]
        core[core/]
        features[features/]
        screens[screens/]
        mainDart[main.dart]
    end

    subgraph features_detail[Features Directory Structure]
        features --> auth[auth/]
        features --> theme[theme/]
        features --> teacher[teacher/]
        features --> student[student/]

        auth --> auth_screens[screens/]
        auth --> auth_providers[providers/]
        auth --> auth_widgets[widgets/]
        auth_screens --> login[login_screen.dart]
        auth_providers --> authProvider[auth_provider.dart]
        auth_widgets --> roleGuard[role_guard.dart]

        theme --> theme_providers[providers/]
        theme_providers --> themeProvider[theme_provider.dart]

        teacher --> teacher_screens[screens/]
        teacher --> teacher_providers[providers/]
        teacher --> teacher_widgets[widgets/]
        teacher --> teacherFeature[teacher_feature.dart]

        student --> student_screens[screens/]
        student --> student_providers[providers/]
        student --> student_widgets[widgets/]
        student --> studentFeature[student_feature.dart]
    end

    screens --> roleSelection[role_selection_screen.dart]

    classDef default fill:#f9f9f9,stroke:#333,stroke-width:2px;
    classDef feature fill:#e1f5fe,stroke:#0288d1,stroke-width:2px;
    classDef provider fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px;
    classDef screen fill:#e8f5e9,stroke:#388e3c,stroke-width:2px;
    
    class auth,theme,teacher,student feature;
    class auth_providers,theme_providers,teacher_providers,student_providers provider;
    class login,roleSelection,auth_screens,teacher_screens,student_screens screen;
```

Note: The diagram above shows the feature-based architecture of the Flutter app, with separate modules for authentication, theming, teacher features, and student features. Each feature module follows a similar structure with screens, providers, and widgets directories.