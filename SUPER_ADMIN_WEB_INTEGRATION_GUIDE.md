# 🚀 RAMP — Super Admin Web Integration & Architecture Reference Guide

This document serves as the **master reference specification** for connecting a separate **Super Admin Web Dashboard** (for managing Landlord accounts, platform subscriptions, and global property metrics) with the **RAMP Mobile Platform**.

---

## 📌 1. System Architecture Overview

```
                               ┌────────────────────────────────────────┐
                               │        SHARED BACKEND SERVICES        │
                               │  Firebase Auth + Supabase PostgreSQL  │
                               └───────────────────┬────────────────────┘
                                                   │
                   ┌───────────────────────────────┴───────────────────────────────┐
                   ▼                                                               ▼
┌─────────────────────────────────────┐                         ┌─────────────────────────────────────┐
│       RAMP MOBILE APPLICATION       │                         │       SUPER ADMIN WEB DASHBOARD     │
│       Framework: Flutter & Dart     │                         │       Framework: Next.js / React    │
│       Target: Landlords & Tenants   │                         │       Target: Platform Super Admin  │
├─────────────────────────────────────┤                         ├─────────────────────────────────────┤
│ - Auth: Firebase Authentication     │                         │ - Auth: Firebase Auth + User Roles  │
│ - User Profiles: Firestore / Supabase│                        │ - Onboard & manage Landlord accounts│
│ - DB: Supabase PostgreSQL           │                         │ - DB: Supabase JS Client            │
│ - Storage: Supabase `ramp_media`    │                         │ - Track global metrics & audit logs │
└─────────────────────────────────────┘                         └─────────────────────────────────────┘
```

---

## 🔑 2. Backend Configuration Details

Both the mobile application and the Super Admin Web App connect to **Firebase Auth** for user session tokens and roles, and **Supabase** (`@supabase/supabase-js`) for operational database entities and media storage.

### A. Firebase Web SDK Reference (`firebase.config.ts`):
```typescript
import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: "AIzaSy...",                   // Extracted from Firebase Console / google-services.json
  authDomain: "rampdb123.firebaseapp.com",
  projectId: "rampdb123",
  storageBucket: "rampdb123.appspot.com",
  messagingSenderId: "1234567890",
  appId: "1:1234567890:web:abcdef123456"
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);
```

### B. Supabase Web SDK Reference (`supabase.config.ts`):
```typescript
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://zjkkuxuofkkysvbmmeqy.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1...';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
```

---

## 🗄️ 3. Master Schemas & Data Contracts (Supabase PostgreSQL)

All entities created by Landlords on the mobile app include a `landlordId` field for data partitioning. The Super Admin web app uses this field to group or inspect data per landlord.

### A. Landlord Accounts Collection (`landlords`)
```typescript
interface LandlordAccount {
  uid: string;                 // Firebase Auth User ID
  name: string;                // e.g. "Cernan Anthony L. Manalo"
  companyName: string;         // e.g. "Apex Rental Properties"
  email: string;               // e.g. "cernan@apexproperties.ph"
  phone: string;               // e.g. "0917-123-4567"
  status: 'active' | 'suspended' | 'pending';
  subscriptionPlan: 'Basic' | 'Pro' | 'Enterprise';
  totalUnitsLimit: number;    // Maximum allowed units under plan
  createdAt: string;           // ISO 8601 Timestamp
  updatedAt: string;
}
```

### B. Property Units Collection (`units`)
```typescript
interface RentalUnit {
  id: string;                  // e.g. "u1", "u2"
  landlordId: string;          // Owning Landlord UID
  title: string;               // e.g. "Executive Studio 101"
  unitNumber: string;          // e.g. "101"
  floor: string;               // e.g. "1st Floor"
  monthlyRent: number;         // e.g. 15000.00
  rentDueDay: number;          // e.g. 5 (5th day of month)
  lateFee: number;             // e.g. 500.00
  status: 'Vacant' | 'Occupied' | 'Under Maintenance';
  tenantId?: string;           // Assigned Tenant ID if Occupied
  tenantName?: string;
  amenities: string[];         // ["WiFi", "Submeter Power", "Aircon Slot"]
  images: string[];            // Image URLs in Firebase Storage
  areaSqm: number;             // e.g. 35.0
  bedrooms: number;
  bathrooms: number;
}
```

### C. Tenants Directory Collection (`tenants`)
```typescript
interface Tenant {
  id: string;                  // e.g. "t1"
  landlordId: string;          // Owning Landlord UID
  name: string;                // e.g. "Maria Santos"
  email: string;
  phone: string;
  unitId: string;              // Foreign Key to units.id
  unitNumber: string;          // e.g. "Unit 2"
  monthlyRent: number;
  balance: number;             // Unpaid balance in ₱
  leaseStart: string;          // ISO Date "2026-03-01"
  leaseEnd: string;            // ISO Date "2027-03-01"
  dueDate: string;             // Next payment due date
  isArchived: boolean;
  avatarUrl?: string;
}
```

### D. Financial Payments Collection (`payments`)
```typescript
interface PaymentRecord {
  id: string;                  // e.g. "pay_1710000000"
  landlordId: string;          // Owning Landlord UID
  unitId: string;
  unitNumber: string;
  tenantId: string;
  tenantName: string;
  amount: number;              // Amount in ₱
  paymentDate: string;         // ISO Date
  paymentMethod: 'GCash' | 'Maya' | 'Bank Transfer' | 'Cash';
  referenceNumber: string;     // Reference Code (e.g. "100234985")
  proofImageUrl: string;       // Screenshot URL in Firebase Storage
  status: 'Pending' | 'Paid' | 'Declined';
  remarks?: string;
}
```

### E. Maintenance Tickets Collection (`tickets`)
```typescript
interface MaintenanceTicket {
  id: string;                  // e.g. "tk_1710000000"
  landlordId: string;          // Owning Landlord UID
  title: string;               // e.g. "Plumbing Leak"
  description: string;
  unitNumber: string;
  tenantName: string;
  priority: 'Low' | 'Med' | 'High' | 'Emergency';
  status: 'Pending Review' | 'In Progress' | 'Resolved' | 'Declined';
  assignedTo: string;          // Contractor Name
  estimatedCost: number;       // ₱
  actualCost: number;          // ₱
  date: string;                // Date reported
  slaDueDate: string;          // Target SLA resolution timestamp
  photoBefore?: string;
  photoAfter?: string;
  rating?: number;             // 1 to 5 Stars
  ratingFeedback?: string;
}
```

### F. System Audit Log Stream (`audit_logs`)
```typescript
interface AuditLogEntry {
  id: string;                  // e.g. "log_1710000000"
  landlordId?: string;         // Landlord UID (if action was triggered by a landlord)
  actorName: string;           // Name of user or system
  role: 'super_admin' | 'landlord' | 'system';
  actionCode: 'ACCOUNT_CREATED' | 'PAYMENT_VERIFIED' | 'TICKET_CREATED' | 'ACCOUNT_SUSPENDED';
  targetId: string;            // ID of affected entity
  description: string;         // Human readable description
  timestamp: string;           // ISO 8601 Timestamp
}
```

---

## 🛡️ 4. Security Rules & Access Control (RBAC)

Use Firebase Authentication Custom Claims to distinguish Super Admin users from regular Landlords.

### Firestore Security Rules (`firestore.rules`):
```groovy
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function checking for Super Admin claim
    function isSuperAdmin() {
      return request.auth != null && 
             (request.auth.token.role == 'super_admin' || 
              get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'super_admin');
    }

    // Helper function checking if caller owns the landlord account
    function isLandlordOwner(landlordId) {
      return request.auth != null && request.auth.uid == landlordId;
    }

    // Landlord Account Management (Super Admin controls status)
    match /landlords/{landlordId} {
      allow read, write: if isSuperAdmin();
      allow read, update: if isLandlordOwner(landlordId);
    }

    // Property Units Collection
    match /units/{unitId} {
      allow read, write: if isSuperAdmin();
      allow read, write: if request.auth != null && 
        (resource == null || resource.data.landlordId == request.auth.uid);
    }

    // Payments Collection
    match /payments/{paymentId} {
      allow read, write: if isSuperAdmin();
      allow read, write: if request.auth != null && 
        (resource == null || resource.data.landlordId == request.auth.uid);
    }

    // Maintenance Tickets Collection
    match /tickets/{ticketId} {
      allow read, write: if isSuperAdmin();
      allow read, write: if request.auth != null && 
        (resource == null || resource.data.landlordId == request.auth.uid);
    }

    // Audit Logs Stream
    match /audit_logs/{logId} {
      allow read: if isSuperAdmin();
      allow create: if request.auth != null;
    }
  }
}
```

---

## ⚡ 5. Essential Super Admin Workflows

1. **Landlord Account Onboarding:**
   * Web App creates new Firebase Auth account for landlord.
   * Creates corresponding document in `landlords` collection with `status: 'active'`.
   * Sets initial unit limit and subscription tier.

2. **Account Suspension / Revocation:**
   * Super Admin updates landlord record to `status: 'suspended'`.
   * Mobile app checks landlord status upon login/launch and restricts access if suspended.

3. **Global Analytics Dashboard:**
   * Calculates Total Platform Collected Revenue (sum of all `payments` where `status == 'Paid'`).
   * Displays active property count, vacancy percentage across all landlords, and total resolved SLA tickets.

4. **Real-time Audit Trail Stream:**
   * Web App listens to `audit_logs` collection ordered by `timestamp desc` to display live platform activity.

---

## 📂 6. Firebase Cloud Storage Bucket Structure

All binary attachments (receipts, avatars, property photos, lease documents) share the same bucket:

```
rampdb123.appspot.com/
├── /landlords/{landlordId}/
│   ├── avatar.jpg
│   └── documents/
├── /properties/{unitId}/
│   ├── /photos/
│   │   ├── unit_101_1.jpg
│   │   └── unit_101_2.jpg
├── /payments/{paymentId}/
│   └── receipt_proof.jpg
└── /tickets/{ticketId}/
    ├── before_repair.jpg
    └── after_repair.jpg
```

---

## 💻 7. Recommended Web Tech Stack

To build the Super Admin Web App quickly and reliably:

* **Framework:** Next.js (React) or React with Vite
* **Styling:** Tailwind CSS + Shadcn UI or Material UI
* **Database & Auth Library:** Firebase Web SDK (`firebase@10.x`)
* **State Management:** TanStack Query (React Query) or Zustand
* **Charts & Analytics:** Recharts or Chart.js

---

*Master Reference File generated for Apex Rental Properties & Development Partners.*
