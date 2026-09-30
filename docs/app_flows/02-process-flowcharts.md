# Process flowcharts

## Authentication and session restoration

```mermaid
flowchart TD
    OPEN[Open app] --> INIT[Initialize Firebase]
    INIT --> AUTH[Listen for first auth state]
    AUTH -->|User exists| FORCE[Set authProvider and RampState role to landlord]
    FORCE --> LOAD[Hydrate Firestore-backed state]
    LOAD -->|Success| SHELL[Show LandlordShell]
    LOAD -->|Firebase error| LOCAL[Keep authenticated session and local seed state]
    LOCAL --> SHELL
    AUTH -->|No user/error| LOGIN[Show LoginScreen]
    LOGIN --> VALIDATE{Valid email and 6+ character password?}
    VALIDATE -->|No| FORM_ERROR[Show field/snackbar error]
    VALIDATE -->|Yes| FIREBASE_LOGIN[Firebase email/password sign-in]
    FIREBASE_LOGIN -->|Success| LOAD
    FIREBASE_LOGIN -->|Failure| AUTH_ERROR[Show mapped auth error]
    LOGIN --> RESET[Forgot password dialog]
    RESET --> RESET_EMAIL[Firebase password reset email]
```

## Main navigation

```mermaid
flowchart LR
    SHELL[LandlordShell IndexedStack] --> H[0 Home]
    SHELL --> U[1 Units]
    SHELL --> T[2 Tenants]
    SHELL --> R[3 Repairs]
    SHELL --> P[4 Profile]
    H -->|Set bottomNavIndex| U
    H -->|Set bottomNavIndex| T
    H -->|Set bottomNavIndex| R
    H -->|Push route| PAYMENT[Payments]
    H -->|Push route| DETAIL[Exact record details/forms]
```

## Dashboard and calendar

```mermaid
flowchart TD
    HOME[HomeScreen] --> OVERVIEW[Overview cards]
    OVERVIEW --> COLLECTION[Monthly collection progress]
    COLLECTION --> PAYMENTS[PaymentsScreen]
    OVERVIEW --> UNITS[Units tab]
    OVERVIEW --> REPAIRS[Repairs tab]

    HOME --> MANAGE[Manage actions]
    MANAGE --> RECORD[PaymentsScreen opens payment form]
    MANAGE --> TICKET[TicketFormScreen create mode]
    MANAGE --> TENANT[TenantFormScreen create mode]

    HOME --> CAL[Calendar sheet]
    CAL --> DATE[Select date]
    DATE --> RENT[Rent due card: tenant plus amount]
    DATE --> MT[Maintenance ticket card]
    DATE --> EVENT[General app event]
    RENT --> TP[TenantProfileScreen]
    RENT --> RP[PaymentsScreen with selected tenant]
    RENT --> UD[UnitDetailScreen]
    MT --> TF[TicketFormScreen with exact ticket]
    MT --> UD
    EVENT -->|Has exact tenant/unit reference| TP
    EVENT -->|Broad event category only| TAB[Related list/tab]

    HOME --> DUE[Upcoming rent dues]
    DUE --> TP
    DUE --> RP
    HOME --> ACT[Recent activity]
    ACT -->|Text classification| RELATED[Related list/tab]
```

## Payment recording and tenant balance

```mermaid
flowchart TD
    ENTRY[Dashboard, tenant profile, calendar, or Payments FAB] --> PS[PaymentsScreen]
    PS --> FORM[Canonical payment bottom sheet]
    FORM --> TENANT{Tenant preselected?}
    TENANT -->|No| SELECT[Select active tenant and unit]
    TENANT -->|Yes| LOCK[Use passed tenant]
    SELECT --> DETAILS[Show exact tenant, unit, and amount due]
    LOCK --> DETAILS
    DETAILS --> METHOD[Choose GCash, Maya, bank, or cash]
    METHOD --> REF[Enter month and reference]
    REF --> CONFIRM{Confirm ledger entry?}
    CONFIRM -->|Cancel| FORM
    CONFIRM -->|Record| NOTIFIER[PaymentNotifier.addPayment]
    NOTIFIER --> LEDGER[Add PaymentData and persist payment]
    NOTIFIER --> MATCH[Match tenant by unit ID or tenant name]
    MATCH --> BALANCE[Reduce tenant balance and persist tenant]
    NOTIFIER --> ACTIVITY[Add payment activity]
    LEDGER --> RECEIPT[Payment list/receipt available]
```

## Payment review, edit, deletion, and receipt

```mermaid
flowchart TD
    LIST[PaymentsScreen] --> FILTER[Search, month, status, sort filters]
    FILTER --> ROW[Select payment row]
    ROW --> RECEIPT[Receipt detail sheet]
    ROW --> EDIT[Edit payment dialog]
    EDIT --> VALIDATE{Valid month and amount?}
    VALIDATE -->|Yes| UPDATE[Update PaymentData and persist]
    ROW --> DELETE{Confirm deletion?}
    DELETE -->|Yes| REMOVE[Remove payment and persisted record]
    RECEIPT --> LIST
```

## Tenant lifecycle

```mermaid
flowchart TD
    LIST[TenantsScreen] --> SEARCH[Search/filter/sort/archive toggle]
    LIST --> ADD[TenantFormScreen create mode]
    ADD --> VALIDATE{Valid tenant, unit, rent, and lease?}
    VALIDATE -->|Yes| CREATE[TenantNotifier.addTenant and persist]
    LIST --> CARD[Expand tenant card]
    CARD --> PROFILE[TenantProfileScreen]
    CARD --> EDIT[TenantFormScreen edit mode]
    EDIT --> UPDATE[TenantNotifier.updateTenant and persist]
    PROFILE --> PAYMENT[PaymentsScreen tenant-specific form/history]
    PROFILE --> TICKETS[Tenant-specific ticket history]
    PROFILE --> MESSAGE[Compose direct message UI]
    PROFILE --> ARCHIVE{Archive or restore?}
    ARCHIVE --> STATE[TenantNotifier archive/unarchive and persist]
    PROFILE --> DELETE{Permanent deletion confirmed?}
    DELETE --> REMOVE[TenantNotifier.deleteTenant]
```

## Unit lifecycle and billing policy

```mermaid
flowchart TD
    LIST[PropertiesScreen / Units] --> FILTER[Search, status, price filters]
    LIST --> ADD[Add unit modal]
    ADD --> CREATE[UnitNotifier.addUnit and persist]
    LIST --> CARD[Unit card]
    CARD --> DETAIL[UnitDetailScreen]
    DETAIL --> EDIT[Edit unit details]
    EDIT --> UPDATE[UnitNotifier.updateUnit and persist]
    DETAIL --> POLICY[Set rent due day and late fee]
    POLICY --> EFFECTIVE[effectiveUnitBillingPolicyProvider]
    DETAIL --> METERS[Update water/electric readings]
    METERS --> BILL[Calculate utility usage and estimated bill]
    DETAIL --> IMAGES[Add/remove unit image]
    DETAIL --> STATUS[Vacant, occupied, or maintenance state]
    DETAIL --> DELETE{Confirm deletion?}
    DELETE --> REMOVE[UnitNotifier.deleteUnit]
```

## Maintenance lifecycle

```mermaid
flowchart TD
    LIST[MaintenanceScreen] --> FILTER[Filter by workflow status]
    LIST --> ADD[TicketFormScreen create mode]
    ADD --> FIELDS[Unit/tenant, issue, priority, estimate, assignment, photos]
    FIELDS --> SLA[Compute SLA from priority]
    SLA --> CREATE[TicketNotifier.addTicket and persist]
    LIST --> CARD[Expand exact ticket]
    CARD --> DETAIL[TicketFormScreen edit mode]
    DETAIL --> UPDATE[TicketNotifier.updateTicket and persist]
    CARD --> ADVANCE{Landlord advances workflow}
    ADVANCE --> PENDING[Pending]
    PENDING --> PROGRESS[In Progress]
    PROGRESS --> AWAIT[Awaiting Payment]
    AWAIT --> COMPLETE[Completed]
    COMPLETE --> RATING[Tenant rating and feedback when tenant flow is active]
    CARD --> PHOTOS[Before/after image preview]
    CARD --> SLA_STATE[SLA due or breached indicator]
```

## Announcements

```mermaid
flowchart TD
    HOME[Home announcements preview] --> CREATE[Announcement editor]
    HOME --> BOARD[AnnouncementBoardScreen]
    BOARD --> FILTER[Active or archived]
    BOARD --> EDIT[Edit announcement]
    CREATE --> SAVE[AnnouncementNotifier add and persist]
    EDIT --> UPDATE[AnnouncementNotifier update and persist]
    BOARD --> ARCHIVE{Archive confirmed?}
    ARCHIVE --> A[Archive and persist]
    FILTER --> RESTORE[Restore archived announcement]
```

## Notifications

```mermaid
flowchart TD
    BELL[Home notification bell and unread badge] --> SHEET[Notifications sheet]
    SHEET --> READ[Mark one read]
    SHEET --> READALL[Mark all read]
    SHEET --> ARCHIVE[Archive notification]
    SHEET --> ACTION[Classify notification text]
    ACTION --> PAYMENT[Payments]
    ACTION --> REPAIR[Repairs]
    ACTION --> TENANT[Tenants]
    ACTION --> UNIT[Units]
    ACTION --> ANN[Announcements]
    SHEET --> ARCHIVE_VIEW[Archived notifications]
    ARCHIVE_VIEW --> RESTORE[Restore notification]
```

## Profile, settings, and logout

```mermaid
flowchart TD
    PROFILE[ProfileScreen] --> LANDLORD[ProfileLandlordScreen]
    LANDLORD --> EDIT[LandlordProfileEditScreen]
    EDIT --> SAVE[Update landlordProfileProvider and persist settings]
    LANDLORD --> LATE[Edit default late fee]
    LANDLORD --> DUE[Edit default due day]
    LANDLORD --> THEME[Toggle dark mode]
    LANDLORD --> REPORT[Export-report dialog]
    LANDLORD --> SETTINGS[SettingsScreen]
    SETTINGS --> PREFS[Notifications, biometrics, and related preferences]
    LANDLORD --> LOGOUT{Confirm logout?}
    LOGOUT -->|Yes| FIREBASE[Firebase sign out]
    FIREBASE --> CLEAR[Clear auth role]
    CLEAR --> LOGIN[LoginScreen]
```

## AI assistant

```mermaid
flowchart TD
    FAB[RAMP AI button] --> AI[AIAssistant sheet]
    AI --> QUERY[Typed or preset query]
    QUERY --> CLASSIFY[Keyword classification]
    CLASSIFY --> LATE[Read late tenant state]
    CLASSIFY --> REVENUE[Read revenue/payment state]
    CLASSIFY --> VACANCY[Read unit state]
    CLASSIFY --> REPAIRS[Read maintenance state]
    CLASSIFY --> REMINDER[Generate reminder-dispatched response]
    CLASSIFY --> FALLBACK[General hardcoded response]
```
