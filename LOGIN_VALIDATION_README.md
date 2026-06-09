# Login Validation — Implementation Notes

## Files Changed / Added

| File | Status |
|---|---|
| `lib/model/user_permissions.dart` | **NEW** |
| `lib/utils/user_session.dart` | **NEW** |
| `lib/utils/api.dart` | **UPDATED** |
| `lib/repository/auth_repo.dart` | **UPDATED** |
| `lib/screen/auth_screen/login.dart` | **UPDATED** |

---

## Flutter-side flow (what the app does)

1. User enters username, password, pin number and taps Login.
2. App posts credentials to `POST /login`.
3. **If HTTP 200** → JWT saved, then `GET /api/v1/user/get-user-permissions` is
   called to fetch the full `tbl_UserAccounts` row and cache all `chk*` flags in
   `UserSession` (SharedPreferences + in-memory singleton).
4. **If HTTP 401** → snackbar: *"Invalid username, password or pin number."*
5. **If HTTP 403** → snackbar: *"You do not have access for SeReports."*
6. **If HTTP 402** → snackbar: *"Your SeReports Subscription has expired."*
7. The backend can override any message by including a `"message"` key in the
   JSON response body.

---

## Backend changes required

### POST /login — return specific HTTP codes

| Condition | HTTP code | Body (optional) |
|---|---|---|
| username/password/pinnumber mismatch in `tbl_UserAccounts` | `401` | `{"message":"Invalid username, password or pin number."}` |
| Credentials match but `SeReportsLogin` column is empty / not `1` | `403` | `{"message":"You do not have access for SeReports."}` |
| Credentials + SeReportsLogin valid but `ExpiryDate` in `tbl_CompanyDetails` (matched by `pinnumber`) < today | `402` | `{"message":"Your SeReports Subscription has expired."}` |
| All checks pass | `200` | JWT in `Authorization: Bearer <token>` header |

### GET /api/v1/user/get-user-permissions — new endpoint

Returns the logged-in user's full `tbl_UserAccounts` row as JSON.
The JWT (already saved after login) is sent automatically by the app.

Expected response shape:
```json
{
  "data": {
    "LocaCode": "01",
    "UserCode": "USR001",
    "CName": "John Doe",
    "UserName": "johndoe",
    "UserType": "1",
    "pinnumber": "1234",
    "LoginLocaCode": "01",
    "chkAddItem": 1,
    "chkEditItem": 1,
    "chkDelItem": null,
    "chkSalaryPayment": 1,
    "SeReportsLogin": 1,
    ...all other chk columns...
  }
}
```

Values: `1` = access granted, `null` / `""` / `0` = no access.

---

## How to guard a feature screen

```dart
// At the top of any onTap / button handler:
if (!UserSession.instance.guard(context, 'chkSalaryPayment')) return;

// That's it. If the user lacks access, a red snackbar is shown automatically:
// "You don't have access for this option."
```

For a custom message:
```dart
if (!UserSession.instance.guard(
      context,
      'chkSalaryPayment',
      customMessage: 'Salary Payment access is required.',
    )) return;
```

For a boolean check without showing a snackbar:
```dart
final hasCost = UserSession.instance.can('chkShowCost');
```

All permission keys match the exact column names in `tbl_UserAccounts`
(case-sensitive), e.g. `chkSalaryPayment`, `chkInvoice`, `chkPurchase`, etc.
