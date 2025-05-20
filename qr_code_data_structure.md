# QR Code Data Structure Enhancement

## Current Structure
```json
{
  "version": 1,
  "type": "attendance",
  "classId": "[class_id]",
  "groupIds": ["[group_ids]"],
  "sessionType": "[CM/TD/TP]",
  "timestamp": "[utc_timestamp]",
  "nonce": "[random_6_digits]"
}
```

## Enhanced Structure
```json
{
  "version": 2,
  "type": "attendance",
  "session": {
    "id": "[unique_session_id]",
    "startTime": "[utc_iso_timestamp]",
    "endTime": "[utc_iso_timestamp]",
    "type": "[CM/TD/TP]",
    "duration": 45 // minutes
  },
  "class": {
    "id": "[class_id]",
    "code": "[class_code]",
    "title": "[class_title]"
  },
  "groups": [
    {
      "id": "[group_id]",
      "name": "[group_name]"
    }
  ],
  "location": {
    "room": "[room_number/name]",
    "building": "[building_name]"
  },
  "security": {
    "timestamp": "[utc_timestamp]",
    "nonce": "[random_32_chars]",
    "signature": "[hmac_signature]"
  }
}
```

## Key Improvements

### 1. Session Information
- Added unique session ID for better tracking
- Explicit start and end times
- Session duration in minutes
- Clear session type indication

### 2. Class Details
- More comprehensive class information
- Helps students verify they're in the right session
- Includes class code and title for display

### 3. Group Information
- Enhanced group details with names
- Helps students confirm their group assignment
- Better organization for multi-group sessions

### 4. Location Data
- Added room and building information
- Helps verify physical presence
- Useful for room tracking and analytics

### 5. Enhanced Security
- Longer random nonce (32 characters)
- HMAC signature for data verification
- Prevents QR code tampering
- Timestamp for expiration checks

## Client-Side Benefits

### For Students
1. Immediate visual confirmation of:
   - Course details
   - Session timing
   - Location information
   - Group assignment

2. Better error prevention:
   - Wrong class detection
   - Expired session detection
   - Invalid location warning

### For Teachers
1. Enhanced tracking:
   - Session duration monitoring
   - Location verification
   - Group attendance statistics

2. Improved security:
   - Tamper-proof QR codes
   - Session validity checks
   - Duplicate scan prevention

## Implementation Notes

1. The QR code data should be:
   - Compressed using efficient encoding
   - Encrypted for sensitive data
   - Signed for authenticity verification

2. The student app should:
   - Validate the signature
   - Check timestamp freshness
   - Verify location data
   - Display clear session info

3. The server should:
   - Generate unique session IDs
   - Create and verify signatures
   - Track session lifetimes
   - Monitor concurrent scans