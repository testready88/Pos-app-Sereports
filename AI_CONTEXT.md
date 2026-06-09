# SeReports Accounts Module — Full Project Context for AI

## 1. Overview

**Flutter POS app** (SeReports / Se POS) with a **Spring Boot 3.4.3 / Java 17 backend** on Railway. The Accounts module has 6 screens that mirror VB6 account management screens (Assets, Capital, Card, Cash Account, Cheques, Liabilities).

### Key URLs
- **Flutter project**: `C:\Users\USER\Desktop\New adding\Semicolans-SeReports-Flutter-V1.9-main`
- **Backend source**: `C:\Users\USER\Desktop\New adding\repo`
- **Live backend**: `https://pos-app-sereports-production.up.railway.app/api/v1/accounts/*`
- **GitHub**: `https://github.com/testready88/Pos-app-Sereports`
- **Deploy**: Railway auto-deploys from `main` branch

### Tech Stack
- **Frontend**: Flutter (Dart), state management via `setState` (no BLoC for accounts), `http_interceptor` for JWT, `shared_preferences` for tokens
- **Backend**: Spring Boot 3.4.3, Java 17, SQL Server via JDBC + Hibernate, JWT auth, Redis caching
- **Printing**: `package:pdf` + `package:printing` (80mm thermal format)

---

## 2. Flutter Project Structure (Accounts Module)

### `lib/screen/accounts/` — 7 files

| File | Purpose | Key Features |
|------|---------|-------------|
| `accounts_landing_page.dart` | Entry grid (6 cards) | Drawer navigation, cards with icons/colors |
| `assets_page.dart` | Asset accounts (ID='AST') | Date filter, summary, DataTable ledger, print |
| `capital_page.dart` | Capital accounts (CA/CAC/DA) | Type filter (Capital/Contribution/Dividend) |
| `card_page.dart` | Card accounts | Account list + ledger, adjust/deposit actions |
| `cash_account_page.dart` | Cash accounts | Account list + ledger, adjust action |
| `cheques_page.dart` | Cheque transactions | Multi-filter, action buttons (Pass/Hold/Deposit/Return) |
| `liabilities_page.dart` | Liability accounts (ID='LIB') | Same pattern as assets |

### Common Pattern (assets/capital/liabilities)
Every page shares this exact widget layout:

```
Scaffold
├── AppBar (reusable Appbar widget)
├── Drawer (AppDrawer widget)
├── SafeArea (top:false, bottom:true, left:true, right:true)
│   └── Container (padding: bottom:8 for glass)
│       └── Column
│           ├── filterBar()              — Rower with Filter btn + chips + print btns
│           ├── summarySection()         — 3 totals cards + per-account breakdown
│           ├── Divider
│           ├── Expanded → DataTable     — Scrollable, black borders, alternating rows
│           └── statusFooter()           — Dark bar: record count + Cr/Dr/B/L totals
```

### Common Pattern (card/cash)
```
Column
├── filterBar()
├── accountList()  — Card-based account summary with selection
├── Divider
├── ledgerList()   — DataTable with transactions
└── statusFooter()
```

### Cheques Pattern
```
Column
├── filterBar()
├── summaryCards()   — Horizontal scroll of 8 stat cards
├── Divider
├── chqList()        — DataTable
├── statusFooter()
└── actionButtons()  — Pass/Hold/Deposit/Return/Refresh
```

---

## 3. Data Flow

### 3.1 API Layer (`lib/utils/api.dart`)

```dart
class Api {
  static Future<Map<String, dynamic>> get({url, parameter}) async {
    // 1. Build InterceptedHttp with JWT interceptor
    // 2. HTTP GET with URL params
    // 3. If 200 → jsonDecode → return Map
    // 4. Else → throw ApiException(response.body)
    // Catch SocketException → "No Internet Connection"
  }

  static Future<Map<String, dynamic>> post({url, body}) async {
    // Same but POST with JSON body
  }
}
```

### 3.2 JWT Auth (`lib/utils/interceptor.dart`)
Every request gets `Authorization: Bearer <token>` from `SharedPreferences('jwt_token')`.

### 3.3 StandardResponse Unwrapping
Backend wraps all responses in:
```json
{"code": 200, "message": "OK", "data": {...}}
```

The Flutter code reads `response['data']` which is the inner data object. The structure of `data` differs by endpoint:

**Asset/Capital/Liability ledger endpoints**:
```json
{"code": 200, "message": "OK", "data": {"data": [{"locaCode": "...", ...}]}}
```
Flutter: `resp['data']['data']` → list of Maps

**Asset/Capital/Liability summary endpoints**:
```json
{"code": 200, "message": "OK", "data": {"totals": {"totalCredit": 100.0, ...}}}
```
Flutter: `resp['data']` → Map with `totals` key

**Card/Cash endpoints**:
```json
{"code": 200, "message": "OK", "data": {"data": [{"acName": "...", ...}]}}
```
Same as asset ledger pattern.

### 3.4 Filter Flow
1. User taps "Filters" → `showFilterSheet()` bottom sheet opens
2. User selects options → `Apply Filters` button
3. `setState` copies sheet values → `Navigator.pop(ctx)` → `fetchData()`
4. `fetchData()` builds SQL WHERE clause as a string → sends as `filters` param
5. Backend does: `SELECT ... WHERE CompID=? AND {filters_string}`

### 3.5 Date Filter Columns by Table
| Page | Table | Date Column |
|------|-------|-------------|
| Assets | `tbl_AssetDet` | `AccountDate` |
| Capital | `tbl_CapitalACDet` | `AccountDate` |
| Liabilities | `tbl_LiabilityDet` | `AccountDate` |
| Card | `tbl_CardAccountLedger` | `CreateDate` |
| Cash | `tbl_CashAccountLedger` | `CreateDate` |
| Cheques | `tbl_ChqDet` | `ChqDate` |

---

## 4. Backend Java Structure

### AccountController (`api/AccountController.java`)
- 12 endpoints for accounts module
- `@RequestParam String filters` — raw SQL WHERE clause passed from Flutter
- `@RequestHeader("Authorization") String token` — JWT for company identification
- Returns `StandardResponse(200, "OK", Map.of("data", ...))`

### AccountQueryServiceImpl (`service/impl/AccountQueryServiceImpl.java`)
- Uses `JdbcTemplate` (raw SQL, no JPA for these queries)
- Filters are concatenated: `"SELECT * FROM tbl_AssetDet WHERE CompID=? AND " + filters + " ORDER BY RowNo DESC"`
- Company ID resolved from JWT via `companyUserService.getUserAllData(token).getCompanyId()`

### Key Database Tables
| Table | Page | Key Columns |
|-------|------|-------------|
| `tbl_AssetDet` | Assets | ID='AST', AccountDate, AcName, AcCode, CreditAmount, DebitAmount, BalanceAmount, LocaCode, AcMethod, Status, InvoiceNo, AcDescription, RowNo, CompID |
| `tbl_CapitalACDet` | Capital | ID='CA'/'CAC'/'DA', same columns as above |
| `tbl_LiabilityDet` | Liabilities | ID='LIB', same columns |
| `tbl_CardAccount` | Card | BankName, AcNo, AcType |
| `tbl_CardAccountLedger` | Card ledger | AcNo, CreateDate, CreditAmount, DebitAmount, BalanceAmount, InvoiceDescription |
| `tbl_CashAccount` | Cash | AcNo, AcName, BalanceAmount |
| `tbl_CashAccountLedger` | Cash ledger | AcNo, CreateDate, CreditAmount, DebitAmount, BalanceAmount |
| `tbl_ChqDet` | Cheques | ChqNo, PaidAmount, ChqDate, ChqType, Status, VenName, BnkName, InvoiceNo, LocaCode, CompID, RowNo, ReferenceNo, TransactionType, PaymentType |

### Known Column Quirks
- **CRITICAL: Map keys are PascalCase, not camelCase!** SQL Server's JDBC `ColumnMapRowMapper` returns column names as defined in the schema (PascalCase, e.g., `CreditAmount`, `LocaCode`, `AcName`). Flutter must access `r['CreditAmount']`, NOT `r['creditAmount']`. Summary SQL aliases are lowercase (`AS totalCredit`), so `sd['totals']['totalCredit']` works.
- `RowNo` column does NOT exist in `tbl_AssetDet`, `tbl_CapitalACDet`, `tbl_CardAccountLedger`, `tbl_CashAccountLedger`, or `tbl_LiabilityDet` — causes SQL error if used in ORDER BY. The backend's `ORDER BY RowNo DESC` would fail on Railway DB (missing column). A `safeQuery()` wrapper was added to catch this and return empty data instead of 500.
- `CompId` vs `compID` vs `compId` — different tables use different casing for the company ID column.
- Card accounts: Backend SQL returns `BankName` (not `AcName`), `AcNo` (not `AcCode`), `Balance` (alias, not `BalanceAmount`), and (since fix) `DeductionRate`.
- Card ledger: `SELECT *` returns `CreateDate`, `AcNo`, `CreditAmount`, `DebitAmount`, `BalanceAmount`, `InvoiceDescription` — note NO `AcName` column.

---

## 5. Known Issues & Recent Fixes

### Fixed Issues (for context)
1. **Filter crash (red screen)**: Old code used `cast<Map<String, dynamic>>()` (lazy type cast) which threw during widget build when data types mismatched. Fixed by using `map((e) => Map<String, dynamic>.from(e)).toList()` with `is List`/`is Map` guards.
2. **`ORDER BY RowNo DESC`**: Removed from Flutter filter strings because the column doesn't exist in ledger tables. Backend still has it in Java — `safeQuery()` wrapper prevents 500.
3. **`setState after dispose`**: Added `if (!mounted) return;` guards before all `setState` calls.
4. **Print crash**: `PdfPageFormat` height was `double.infinity` — changed to `1200` (finite required by `pw.MultiPage`).
5. **Zero values in footer**: Fixed by computing totals from ledger data as primary source (`.fold()`), only overriding from summary totals if non-zero.
6. **All table data showing 0.00/empty (CRITICAL)**: Root cause was case mismatch between SQL Server column names (PascalCase: `CreditAmount`, `LocaCode`, `AcName`) and Flutter map key access (camelCase: `creditAmount`, `locaCode`, `acName`). Changed ~180 map key accesses across 6 files to PascalCase. Also fixed card accounts: backend SQL now includes `DeductionRate` column; Flutter maps `BankName`/`AcNo`/`Balance` instead of `acName`/`acCode`/`balanceAmount`; card/cash ledger now passes `acNo` param instead of ignored `filters` param.

### Current Known Issues (may need fixes)
1. **Some fields show no data**: Some backend tables may lack certain columns on Railway DB (e.g., `RowNo`, `acCode`, `locaCode` for some records).
2. **Spelling mismatch**: Backend DB uses `'RECIEVED CHQ'` (misspelled) but Flutter dropdown correctly shows `'RECEIVED CHQ'`. Backend controller handles the translation.
3. **Java `pom.xml` has `java.version` 21** but the project was changed to use Java 17. If you get build errors, check this property.
4. **Card/cash ledger filtering**: `fetchLedger()` now passes `acNo` param instead of previously broken `filters` param. Name/date/location filters on card/cash pages are NOT yet processed by the backend — they will be ignored.
5. **Per-account breakdown cards**: The summary endpoint returns `{"totals": {...}}` but Flutter code checks `sd['data']` expecting a list. Since no breakdown endpoint exists, `summaryData` is always empty, and the per-account breakdown cards show "No summary data". The top-level summary cards (Cr/Dr/B/L row) work correctly.

---

## 6. Print System (`lib/service/account_print_service.dart`)

- 80mm thermal format: `PdfPageFormat(80 * PdfPageFormat.mm, 1200, marginAll: 8)`
- Uses `pw.MultiPage` with auto-pagination
- Two print buttons per page: "Print Summary" (summary data) and "Print Ledger" (transaction list)
- Column definitions for each report are defined in each page's `printSummaryReport()` / `printLedgerReport()`

---

## 7. Common Bugs and How to Fix

### 7.1 "Red screen" when using filters
The Filter button opens a bottom sheet. When "Apply Filters" is pressed:
1. `setState` updates filter variables
2. Disposes local controllers
3. Pops the sheet
4. Calls `fetchData()`

**If red screen occurs**: Check the `setState` callback for type errors. The most common cause is the old `cast<Map>()` pattern — ensure you use `map((e) => Map<String, dynamic>.from(e)).toList()` with proper type guards.

### 7.2 Backend returns 500 for filter queries
The SQL WHERE clause string might have syntax errors. Check the `filters` parameter being sent. Common issues:
- Missing space between conditions: `AND Name LIKE...AND Date...` (need space before second AND)
- Unquoted string values with apostrophes (SQL injection risk)
- Using `OrderDate` instead of `AccountDate` or `CreateDate`

### 7.3 "No data" shown when data exists
- Check `CompID` matches — Railway DB company 19036 ("SEMICOLANS E-SHOP") has most data
- Check date filter: default pre-fills 6 months ago to today, but date filter is NOT active until user checks the date checkbox
- Check that the correct date column is used for the table

### 7.4 Print preview is blank
- Ensure `PdfPageFormat.height` is finite (not `double.infinity`)
- Ensure `pw.Document` is created INSIDE the `Printing.layoutPdf(onLayout: ...)` callback
- Check that `ledgerData` has entries

### 7.5 Table shows "0.00" for all amounts
- Old code only read totals from summary endpoint. Fixed: now computes from ledger data
- If still happening, check that `r['creditAmount']` key name matches the backend response column name

---

## 8. How to Edit / Build / Test

```bash
# Set up Flutter path
$env:Path += ";C:\Users\USER\flutter\bin"

# Navigate to project
cd "C:\Users\USER\Desktop\New adding\Semicolans-SeReports-Flutter-V1.9-main"

# Run analysis
flutter analyze

# Run on connected device
flutter run

# Build APK
flutter build apk --release
```

### Backend (Java)
```bash
cd "C:\Users\USER\Desktop\New adding\repo"
mvn clean install
mvn spring-boot:run
```

---

## 9. Code Style Conventions

1. **No comments** — project code has no explanatory comments (they were removed per style guide)
2. **State management**: Direct `setState` (not BLoC for accounts pages)
3. **Number formatting**: Each page has its own `numberFormat`/`nf` method
4. **Error handling**: `try/catch` → `showErrorSnackBar(context, 'Failed: $e')`
5. **Mounted guards**: `if (!mounted) return;` before all success-path `setState` calls
6. **Import style**: `package:sereports/...` (not relative imports)
7. **Filter construction**: SQL WHERE clause as string, passed as `filters` parameter

---

## 10. Key Data Flow for Debugging

When investigating a bug, trace this path:

1. **UI Tap** → method call (e.g., `fetchData()`)
2. **Filter construction**: `fetchData()` builds SQL WHERE clause string
3. **API call**: `Api.get(url: Api.getAssetLedger, parameter: {'filters': '...'})`
4. **Interceptor**: JWT token attached
5. **Backend**: `AccountController.getAssetLedger(filters, token)`
6. **Backend**: `AccountQueryServiceImpl.getAssetLedger(filters, token)`
7. **Backend**: `jdbcTemplate.query("SELECT * FROM tbl_AssetDet WHERE CompID=? AND " + filters + " ORDER BY RowNo DESC", ...)`
8. **Response**: `StandardResponse(200, "OK", {"data": [...]})`
9. **Flutter**: `resp['data']` → if Map → `resp['data']['data']` → cast to list
10. **State**: `setState(() { ledgerData = ... })`
11. **Build**: `ledgerList()` builds DataTable from `ledgerData`

If any step fails:
- Step 3-4: Check network, token expiry
- Step 5-7: Check backend logs (Railway)
- Step 8-9: Check StandardResponse structure (might not match expected pattern)
- Step 10: Check for type casting errors
- Step 11: Check build method for null safety

---

## 11. Navigation Path

The accounts module is accessible from:
1. App Drawer → "Accounts" → Landing Page (6 cards)
2. Each card opens the respective page: `AssetsPage`, `CapitalPage`, `CardPage`, `CashAccountPage`, `ChequesPage`, `LiabilitiesPage`

All pages use `Appbar(scaffoldKey: scaffoldKey)` (shows company name + hamburger menu) and `AppDrawer()`.
