# Background Check System - Testing Guide

## Overview
This document provides comprehensive testing instructions for the newly implemented background checks system in the Studia Tutor Booking application.

## Implementation Summary

### 1. Database Enhancements
**File**: `lib/database/database_helper.dart`

New methods added to the `DatabaseHelper` class:
- `getTutorProfile(int tutorId)` - Retrieves a specific tutor's profile
- `getAllTutorProfiles()` - Retrieves all tutor profiles
- `updateTutorProfile(TutorProfile profile)` - Updates a tutor's profile
- `getTutorsByBackgroundCheckStatus(String status)` - Filters tutors by background check status

**Features**:
- Full CRUD operations for tutor profiles
- Query tutors by background check status (Completed, Pending, Failed)
- Direct database access without network latency

### 2. UI Screens
**File**: `lib/screens/background_check_screen.dart`

#### BackgroundCheckScreen (Main Screen)
- Displays all tutor profiles in a list
- Filter dropdown to show tutors by status:
  - All
  - Completed
  - Pending
  - Failed
- Status color-coding:
  - Green = Completed
  - Orange = Pending
  - Red = Failed
- Tab navigation integrated with booking system

#### TutorBackgroundCheckCard (Card Component)
- Shows tutor ID, hourly rate, years of experience
- Displays current background check status with color badge
- Shows check date and verification document path
- "Update" button to edit profile details

#### BackgroundCheckDetailScreen (Detail View)
- Full tutor profile information display
- Status dropdown selector
- Verification document path editor
- Bio/description text field
- Submit button to save changes
- Real-time database updates

### 3. Backend API Endpoints
**File**: `backend/bin/server.dart`

New endpoints added:
- `GET /tutor-profiles` - Retrieve all tutor profiles
- `GET /tutor-profiles/<tutorId>` - Get specific tutor profile
- `POST /tutor-profiles/<tutorId>/background-check` - Update background check status
- `GET /tutor-profiles/background-check/status/<status>` - Filter by status

**Response Format**:
```json
{
  "userId": 101,
  "bio": "Experienced math tutor...",
  "hourlyRate": 30.0,
  "yearsExperience": 5,
  "verified": true,
  "avgRating": 4.8,
  "totalReviews": 24,
  "backgroundCheckStatus": "Completed",
  "backgroundCheckDate": "2026-06-28T...",
  "verificationDocument": null
}
```

### 4. Main App Integration
**File**: `lib/main.dart`

Changes:
- Added import for `background_check_screen.dart`
- Converted `HomeScreen` to a tabbed interface using `TabController`
- Tab 1: "Book Session" - Original booking flow
- Tab 2: "Background Checks" - New background check management
- Both tabs accessible from main app navigation

---

## Testing Instructions

### Test 1: Application Startup
**Steps**:
1. Run `flutter pub get` to install dependencies
2. Run `flutter run` to start the app
3. Verify the app launches without errors

**Expected Results**:
- App starts successfully
- Main screen displays with 2 tabs at the top
- First tab shows booking session interface
- Second tab shows background check management

### Test 2: View Background Check List
**Steps**:
1. Open the app
2. Click on the "Background Checks" tab
3. Wait for the list to load

**Expected Results**:
- List displays all tutor profiles from database
- By default shows:
  - Tutor ID: 101 (Anna Kowalska)
  - Status: "Completed" (green badge)
  - Experience: 5 years
  - Hourly Rate: $30.00
- Status filter dropdown shows "All" by default

### Test 3: Filter Tutors by Status
**Steps**:
1. Open Background Checks tab
2. Click "Filter by Status" dropdown
3. Select "Pending" status
4. Observe the list

**Expected Results**:
- List filters correctly based on selection
- Only tutors with that status appear
- Selecting "All" shows all profiles again
- Filter updates in real-time

### Test 4: View Tutor Details
**Steps**:
1. Open Background Checks tab
2. Click on a tutor card (or click "Update" button)

**Expected Results**:
- Detail screen opens showing:
  - Tutor ID
  - Hourly Rate
  - Years of Experience
  - Verification Status
  - Current Rating & Reviews
  - Background Check Status (dropdown)
  - Verification Document field
  - Bio field

### Test 5: Update Background Check Status
**Steps**:
1. Open a tutor's detail screen
2. Change status from "Pending" to "Completed"
3. Click "Update Profile" button
4. Wait for success message

**Expected Results**:
- Snackbar shows "Profile updated successfully!"
- Returns to background check list
- Updated tutor now shows new status
- Database is persisted (status persists on app restart)

### Test 6: Update Verification Document
**Steps**:
1. Open a tutor's detail screen
2. Enter document path in "Verification Document Path" field
  - Example: `/uploads/tutor_101_verification.pdf`
3. Click "Update Profile"

**Expected Results**:
- Document path is saved
- Card displays document path in small text
- Data persists in database

### Test 7: Edit Tutor Bio
**Steps**:
1. Open a tutor's detail screen
2. Modify the bio text
3. Click "Update Profile"

**Expected Results**:
- Bio is updated and saved
- Returns to list view
- Changes persist

### Test 8: Database Persistence
**Steps**:
1. Make changes to a tutor profile (status, bio, document)
2. Close and reopen the app
3. Navigate to Background Checks tab

**Expected Results**:
- All changes made in previous session are preserved
- Updated status, bio, and document fields remain

### Test 9: Tab Navigation
**Steps**:
1. Open the app on Background Checks tab
2. Click "Book Session" tab
3. Make booking (or just view)
4. Click back to "Background Checks" tab

**Expected Results**:
- Tabs switch smoothly
- No data loss
- State is preserved when switching tabs

### Test 10: Backend API Testing (Manual)
**Steps** (requires running backend server):
1. Start backend: `cd backend && dart bin/server.dart`
2. Test endpoints using curl or Postman:

```bash
# Get all tutor profiles
curl http://localhost:8080/tutor-profiles

# Get specific tutor
curl http://localhost:8080/tutor-profiles/101

# Update background check
curl -X POST http://localhost:8080/tutor-profiles/101/background-check \
  -H "Content-Type: application/json" \
  -d '{"backgroundCheckStatus": "Completed", "verificationDocument": "/path/to/doc.pdf"}'

# Get tutors by status
curl http://localhost:8080/tutor-profiles/background-check/status/Completed
```

**Expected Results**:
- All endpoints return valid JSON responses
- Status updates are reflected
- No server errors

---

## Data Model Structure

### TutorProfile
```dart
final int userId;                          // Unique tutor identifier
final String? bio;                         // Tutor biography
final double hourlyRate;                   // Hourly rate in USD
final int yearsExperience;                 // Years of experience
final bool verified;                       // Platform verification status
final double avgRating;                    // Average rating (0-5)
final int totalReviews;                    // Total number of reviews
final String? backgroundCheckStatus;       // "Completed", "Pending", "Failed"
final String? backgroundCheckDate;         // ISO8601 timestamp
final String? verificationDocument;        // File path or reference
```

---

## Database Schema

### tutor_profiles Table
```sql
CREATE TABLE tutor_profiles(
  user_id INTEGER PRIMARY KEY,
  bio TEXT,
  hourly_rate REAL NOT NULL,
  years_experience INTEGER,
  verified INTEGER,
  avg_rating REAL,
  total_reviews INTEGER,
  background_check_status TEXT,
  background_check_date TEXT,
  verification_document TEXT
)
```

---

## Features Implemented

✅ Database CRUD operations for tutor profiles
✅ Background check status management
✅ Verification document tracking
✅ Background check date recording
✅ Filter and search by status
✅ Real-time UI updates
✅ Data persistence across app restarts
✅ Tab-based navigation
✅ Backend API endpoints
✅ Color-coded status badges
✅ Detail view for profile editing
✅ Error handling and user feedback

---

## Sample Data

The app initializes with sample data:
- **Tutor**: Anna Kowalska (ID: 101)
- **Status**: Completed
- **Check Date**: Current date/time
- **Hourly Rate**: $30.00
- **Experience**: 5 years
- **Rating**: 4.8/5.0
- **Reviews**: 24

---

## Troubleshooting

### Issue: "No tutor profiles found"
- **Cause**: Database not initialized
- **Solution**: Restart app or call `initializeSampleData()` manually

### Issue: Status not updating
- **Cause**: Database write failure
- **Solution**: Check logs, ensure database is writable

### Issue: Backend endpoints return 404
- **Cause**: Server not running
- **Solution**: Start backend with `dart bin/server.dart`

### Issue: Compilation errors
- **Solution**: Run `flutter clean && flutter pub get`

---

## Success Criteria

✅ All screens render without errors
✅ Database operations work correctly
✅ Status filtering works as expected
✅ Profile updates persist
✅ UI is responsive and user-friendly
✅ Backend API endpoints return valid responses
✅ No console errors or warnings
✅ Tab navigation works smoothly

---

## Future Enhancements

1. Document upload functionality
2. Approval workflow with admin interface
3. Email notifications for status changes
4. Batch status updates
5. Status history/audit log
6. Integration with third-party verification services
7. Automatic status expiration
8. Review comments for failed checks
9. Dashboard with statistics
10. Advanced filtering and search

---

## Code Quality

All code follows Dart/Flutter best practices:
- ✅ Null safety enabled
- ✅ Const constructors where applicable
- ✅ Proper error handling
- ✅ Code analysis passed (no warnings/errors)
- ✅ Organized import statements
- ✅ Consistent naming conventions
- ✅ Well-documented structure

---

**Last Updated**: 2026-06-28
**Status**: Ready for Testing
