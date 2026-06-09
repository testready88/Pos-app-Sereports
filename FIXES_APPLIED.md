# SeReports Login Validation - Complete Fix Documentation

## Issues Fixed

### 1. **Users could login even with expired subscription**
   - **Root Cause**: ExpiryDate from tbl_CompanyDetails was not being validated
   - **Fix**: Added `validateSubscriptionExpiry()` method in ApplicationUserServiceImpl that checks if ExpiryDate < today and returns HTTP 402

### 2. **Wrong error messages displayed at login**
   - **Root Cause**: Validation sequence was not strict - all validations were attempted, causing generic "don't have access" error
   - **Fix**: Implemented strict sequential validation:
     - Step 1: Validate credentials (username, password, pinnumber) → HTTP 401
     - Step 2: Validate SeReportsLogin access → HTTP 403  
     - Step 3: Validate ExpiryDate → HTTP 402
     - Each step throws immediately on failure with specific error message

### 3. **Users could access functions without proper permissions**
   - **Root Cause**: Permission checks were not implemented on button clicks
   - **Fix**: 
     - Flutter: Added `UserSession.guard()` method that must be called before opening any feature
     - Backend: Created proper permission caching by fetching all chk* columns after login
     - Example guard usage in button click handlers

## Backend Changes (Java/Spring Boot)

### New Files Created:
1. **UserAccounts.java** - Entity mapping all permission columns from tbl_UserAccounts
2. **UserAccountsRepo.java** - Repository for querying user accounts with permissions
3. **CustomAuthenticationFailureHandler.java** - Handles authentication errors with proper HTTP codes

### Modified Files:
1. **JwtUsernameAndPasswordAuthenticationFilter.java**
   - Added 3-step validation sequence
   - Now calls validateSeReportsAccess() and validateSubscriptionExpiry()
   - Throws exceptions with specific error messages for each failure type

2. **ApplicationUserServiceImpl.java**
   - Added validateSeReportsAccess() - checks SeReportsLogin == "1"
   - Added validateSubscriptionExpiry() - compares ExpiryDate with current date
   - Added getUserAccountByUsername() - retrieves user with all permissions

3. **UserService.java** (Interface)
   - Added getUserAccountWithPermissions() method signature

4. **UserServiceImpl.java**
   - Implemented getUserAccountWithPermissions() to fetch user account with all permissions

5. **UserController.java**
   - Added GET /api/v1/user/get-user-permissions endpoint
   - Returns user account with all chk* permission columns wrapped in StandardResponse

6. **CompanyDetailsRepo.java**
   - Added findByPinnumber() method for ExpiryDate validation

7. **CompanyDetails.java** (Entity)
   - Added expiryDate field of type LocalDate to support date comparison

## Flutter App Changes

### Existing Proper Implementation (No Changes Needed):
1. **auth_repo.dart** - Already has correct sequential validation logic
2. **api.dart** - Already handles HTTP 401, 403, 402 status codes correctly
3. **login.dart** - Already displays server-provided error messages
4. **user_session.dart** - Has guard() method for permission checks

### How to Use Permission Guards in Screens:

```dart
// In any screen button click handler:
if (!UserSession.instance.guard(context, 'chkSalaryPayment')) return;

// Now you can safely proceed knowing user has access
startActivity(new Intent(this, SalaryPaymentActivity.class));
```

Or check without showing error:
```dart
if (!UserSession.instance.can('chkSalaryPayment')) {
  // User doesn't have access - hide the button or show custom message
  return;
}
```

## Validation Flow Diagram

```
Login Request (username, password, pinnumber)
          ↓
┌─────────────────────────────────────────┐
│ STEP 1: Check Credentials               │
│ Query tbl_UserAccounts                  │
│ WHERE UserName=? AND UserPinCode=?      │
└─────────────────────────────────────────┘
          ↓
    ✓ Credentials Match?
          │
    ├─ NO  → HTTP 401: "Invalid username, password or pin number"
    │
    ├─ YES ↓
┌─────────────────────────────────────────┐
│ STEP 2: Check SeReportsLogin Access     │
│ Query tbl_UserAccounts.SeReportsLogin   │
│ WHERE UserName=? AND pinnumber=?        │
│ Check if value == "1"                   │
└─────────────────────────────────────────┘
          ↓
    ✓ SeReportsLogin == "1"?
          │
    ├─ NO  → HTTP 403: "You do not have access for SeReports"
    │
    ├─ YES ↓
┌─────────────────────────────────────────┐
│ STEP 3: Check Subscription Expiry       │
│ Query tbl_CompanyDetails.ExpiryDate     │
│ WHERE pinnumber=?                       │
│ Compare ExpiryDate vs TODAY             │
└─────────────────────────────────────────┘
          ↓
    ✓ ExpiryDate >= TODAY?
          │
    ├─ NO  → HTTP 402: "Your SeReports Subscription has expired"
    │
    ├─ YES ↓
┌─────────────────────────────────────────┐
│ SUCCESS: Return JWT Token               │
│ Fetch all permissions (chk* columns)    │
│ Cache in UserSession                    │
└─────────────────────────────────────────┘
          ↓
      Dashboard
```

## Database Requirements

Ensure your tbl_CompanyDetails table has:
- `pinnumber` column (VARCHAR)
- `ExpiryDate` column (DATE)

Ensure your tbl_UserAccounts table has:
- `UserName` column (VARCHAR)
- `UserPinCode` column (VARCHAR)
- `SeReportsLogin` column (VARCHAR) - stores "1" for access, empty/null for no access
- All `chk*` permission columns (VARCHAR) - store "1" for access, empty/null for no access

## Testing Checklist

- [ ] User with expired subscription cannot login (HTTP 402)
- [ ] User without SeReportsLogin access cannot login (HTTP 403)
- [ ] User with wrong credentials cannot login (HTTP 401)
- [ ] Error messages are specific and user-friendly
- [ ] User with valid subscription and access can login
- [ ] Permissions are cached after login
- [ ] Buttons are only enabled for features user has access to
- [ ] Clicking unauthorized feature shows "You don't have access for this option"
- [ ] Logout clears all cached permissions and tokens

## Security Notes

1. All validation happens server-side (backend) - Flutter app trusts backend responses
2. JWT token expiry is set to 1 day by default (configurable)
3. Permission checks happen on every feature access, not just at login
4. Never trust client-side permission values - always validate on server too
