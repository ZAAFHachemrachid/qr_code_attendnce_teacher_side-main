# Teacher Profile Update Plan

## 1. Update Provider Query

Current query in TeacherProfileProvider:
```sql
SELECT 
  tp.id,
  tp.employee_id,
  tp.department_id,
  tp.created_at,
  tp.updated_at,
  p.first_name,
  p.last_name,
  p.phone
FROM teacher_profiles tp
JOIN profiles p ON tp.id = p.id
```

Updated query to include department data:
```sql
SELECT 
  tp.id,
  tp.employee_id,
  tp.department_id,
  tp.created_at,
  tp.updated_at,
  p.first_name,
  p.last_name,
  p.phone,
  d.name as department_name,
  d.code as department_code
FROM teacher_profiles tp
JOIN profiles p ON tp.id = p.id
JOIN departments d ON tp.department_id = d.id
```

## 2. Update UI Components

Current UI shows:
- Name
- Employee ID
- Phone (if available)
- Department (currently null)

Updates needed:
1. Add department name and code display
2. Format and display creation/update dates
3. Remove hardcoded position field
4. Improve info card layout

```dart
// Updated _buildInfoCard layout
_buildInfoCard(
  context,
  'Department Information',
  [
    _buildInfoRow('Department', '${profile.departmentName} (${profile.departmentCode})'),
    _buildInfoRow('Created', DateFormat('MMM d, yyyy').format(profile.createdAt)),
    _buildInfoRow('Last Updated', DateFormat('MMM d, yyyy').format(profile.updatedAt)),
  ],
)
```

## Implementation Steps

1. Provider Updates:
   - Update SQL query to join with departments
   - Add error handling for department joins

2. UI Updates:
   - Update info card layout
   - Add date formatting
   - Remove position display
   - Add department code display
   - Improve error and loading states

Would you like to proceed with implementing these changes in code mode?