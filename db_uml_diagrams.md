# Database UML Diagrams

## Class Diagram (Database Entities)

```mermaid
classDiagram
    class Profile {
        +UUID id
        +String firstName
        +String lastName
        +String role
        +String phone
        +DateTime createdAt
        +DateTime updatedAt
        +getFullName()
        +updateProfile(firstName, lastName, phone)
        +getProfileByRole()
    }

    class AdminProfile {
        +UUID id
        +String accessLevel
        +DateTime createdAt
        +DateTime updatedAt
        +manageUsers()
        +setAccessLevel(level)
    }

    class TeacherProfile {
        +UUID id
        +UUID departmentId
        +String employeeId
        +DateTime createdAt
        +DateTime updatedAt
        +getAssignedCourses()
        +getWeeklySchedule()
        +generateQRCode(sessionId)
        +viewSessionAttendance(sessionId)
        +getDepartmentInfo()
        +exportAttendanceReport()
    }

    class StudentProfile {
        +UUID id
        +String studentNumber
        +UUID groupId
        +DateTime createdAt
        +DateTime updatedAt
        +getEnrolledCourses()
        +getAttendanceHistory()
        +scanQRCode(qrCode)
        +getGroupInfo()
        +getAttendanceStats()
    }

    class Department {
        +UUID id
        +String name
        +String code
        +DateTime createdAt
        +DateTime updatedAt
        +getTeachers()
        +getCourses()
        +getStudentGroups()
    }

    class StudentGroup {
        +UUID id
        +UUID departmentId
        +int academicYear
        +int currentYear
        +String section
        +String name
        +DateTime createdAt
        +DateTime updatedAt
        +getStudents()
        +getSchedule()
        +getEnrolledCourses()
    }

    class Course {
        +UUID id
        +String code
        +String title
        +String description
        +int creditHours
        +UUID departmentId
        +int yearOfStudy
        +String semester
        +DateTime createdAt
        +DateTime updatedAt
        +getEnrolledGroups()
        +getTeachers()
        +getSessions()
        +getAttendanceStats()
    }

    class Session {
        +UUID id
        +UUID courseId
        +UUID groupId
        +UUID teacherId
        +String typeC
        +String title
        +Date sessionDate
        +Time startTime
        +Time endTime
        +String room
        +String qrCode
        +DateTime qrExpiry
        +UUID weeklyScheduleId
        +DateTime createdAt
        +DateTime updatedAt
        +generateQRCode()
        +getAttendance()
        +isActive()
        +markAttendance(studentId, status)
        +exportAttendanceData()
    }

    class Attendance {
        +UUID id
        +UUID sessionId
        +UUID studentId
        +String status
        +DateTime checkInTime
        +String notes
        +DateTime createdAt
        +DateTime updatedAt
        +updateStatus(status)
        +addNotes(notes)
    }

    class TimeSlot {
        +Integer id
        +Integer slotNumber
        +Time startTime
        +Time endTime
        +getDuration()
        +isAvailable(day, room)
    }

    class WeeklySchedule {
        +UUID id
        +UUID courseId
        +UUID groupId
        +UUID teacherId
        +String typeC
        +String dayOfWeek
        +Integer timeSlotId
        +String room
        +generateSessions(startDate, endDate)
        +getConflicts()
    }

    Profile <|-- AdminProfile : extends
    Profile <|-- TeacherProfile : extends
    Profile <|-- StudentProfile : extends
    Department "1" -- "many" TeacherProfile : employs
    Department "1" -- "many" Course : offers
    Department "1" -- "many" StudentGroup : has
    StudentGroup "1" -- "many" StudentProfile : contains
    Course "many" -- "many" StudentGroup : enrolled
    Session "many" -- "1" Course : belongs to
    Session "many" -- "1" StudentGroup : attended by
    Session "many" -- "1" TeacherProfile : taught by
    Session "many" -- "1" TimeSlot : scheduled at
    Session "1" -- "many" Attendance : has
    WeeklySchedule "1" -- "many" Session : generates
    WeeklySchedule -- TimeSlot : uses
    Attendance "many" -- "1" StudentProfile : tracks
```

## Sequence Diagram (QR Code Attendance Flow)

```mermaid
sequenceDiagram
    actor Teacher
    actor Student
    participant TeacherApp
    participant Backend
    participant StudentApp

    Teacher->>TeacherApp: Login
    TeacherApp->>Backend: Authenticate
    Backend-->>TeacherApp: Return JWT

    Teacher->>TeacherApp: Generate QR Code
    TeacherApp->>Backend: Create Session
    Backend-->>TeacherApp: Return Session with QR
    TeacherApp-->>Teacher: Display QR Code

    Student->>StudentApp: Login
    StudentApp->>Backend: Authenticate
    Backend-->>StudentApp: Return JWT

    Student->>StudentApp: Scan QR Code
    StudentApp->>Backend: Submit Attendance
    Backend-->>StudentApp: Confirm Attendance
    StudentApp-->>Student: Show Success

    Teacher->>TeacherApp: View Attendance
    TeacherApp->>Backend: Get Session Attendance
    Backend-->>TeacherApp: Return Attendance List
    TeacherApp-->>Teacher: Display Attendance
```

## Sequence Diagram (Teacher Export Attendance Flow)

```mermaid
sequenceDiagram
    actor Teacher
    participant TeacherApp
    participant Backend
    participant Database
    participant FileSystem

    Teacher->>TeacherApp: Select Course/Session
    TeacherApp->>Backend: Request Attendance Data
    Backend->>Database: Query Attendance Records
    Database-->>Backend: Return Records
    
    Backend->>Backend: Process Data
    Backend->>FileSystem: Generate Export File
    FileSystem-->>Backend: File Created
    
    Backend-->>TeacherApp: Return Export URL
    TeacherApp-->>Teacher: Display Download Link
    
    Teacher->>TeacherApp: Download Report
    TeacherApp->>Backend: Request File
    Backend-->>TeacherApp: Send File
    TeacherApp-->>Teacher: Save File Locally
    
    Note over Teacher,TeacherApp: Teacher can view exported data
```

## Sequence Diagram (Student Attendance History View)

```mermaid
sequenceDiagram
    actor Student
    participant StudentApp
    participant Backend
    participant Database

    Student->>StudentApp: View Attendance History
    StudentApp->>Backend: Request History
    
    Backend->>Database: Query Student Profile
    Database-->>Backend: Return Profile
    
    Backend->>Database: Query Enrolled Courses
    Database-->>Backend: Return Courses
    
    Backend->>Database: Query Attendance Records
    Database-->>Backend: Return Records
    
    Backend->>Backend: Calculate Statistics
    Note over Backend: Compute attendance percentage
    Note over Backend: Group by course/month
    
    Backend-->>StudentApp: Return Processed Data
    
    StudentApp->>StudentApp: Format Display
    Note over StudentApp: Generate charts/graphs
    Note over StudentApp: Show attendance trends
    
    StudentApp-->>Student: Display History
    
    Student->>StudentApp: Filter by Course
    StudentApp->>StudentApp: Update View
    StudentApp-->>Student: Show Filtered Data
    
    Student->>StudentApp: View Detailed Session
    StudentApp->>Backend: Get Session Details
    Backend->>Database: Query Session
    Database-->>Backend: Return Details
    Backend-->>StudentApp: Return Session Info
    StudentApp-->>Student: Display Session Details
```