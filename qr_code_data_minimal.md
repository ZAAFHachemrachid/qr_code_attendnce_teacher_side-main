# Minimal QR Code Data Structure

## Data Format
```json
{
  "sid": "[session_unique_id]",
  "type": "[CM/TD/TP]",
  "class": {
    "id": "[class_id]",
    "code": "[class_code]"
  },
  "group": {
    "id": "[group_id]",
    "name": "[group_name]"
  }
}
```

## Field Descriptions

### Session ID (`sid`)
- Unique identifier for each attendance session
- Generated when teacher starts a new session
- Used to track attendance for specific sessions

### Session Type (`type`)
- Values: CM, TD, or TP
- Indicates the type of class session
- Affects attendance tracking rules

### Class Information (`class`)
- `id`: Internal class identifier
- `code`: Human-readable class code (e.g., "MATH101")
- Helps verify correct class attendance

### Group Information (`group`)
- `id`: Group identifier
- `name`: Human-readable group name (e.g., "Group A")
- Only included for TD/TP sessions

## Implementation Notes

### QR Code Generation
```dart
String generateQRData(TeacherClass classInfo, String sessionId, ClassType type, String? groupId) {
  final data = {
    "sid": sessionId,
    "type": type.name.toUpperCase(),
    "class": {
      "id": classInfo.id,
      "code": classInfo.code
    }
  };

  // Add group info for TD/TP sessions
  if (type != ClassType.course && groupId != null) {
    final group = classInfo.groups.firstWhere((g) => g.id == groupId);
    data["group"] = {
      "id": group.id,
      "name": group.name
    };
  }

  return json.encode(data);
}
```

### Usage Example
```dart
// In QR code generation screen
final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
final qrData = generateQRData(
  widget.teacherClass,
  sessionId,
  _selectedClassType,
  _selectedGroupIds.isNotEmpty ? _selectedGroupIds.first : null
);