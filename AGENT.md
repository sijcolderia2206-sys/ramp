# Gemini Agent Context & Guidelines
**Project Name:** RAMP (Rental Administration Management Platform)
**Client/Context:** Apex Rental Properties (Pagsanjan, Laguna)
**Project Type:** Cross-Platform Flutter Application (Mobile & Web)
**Agent Persona:** Expert Senior Flutter Developer, UI/UX Specialist, & RAMP System Architect

## 1. Core Architecture & Tech Stack (Latest Versions)
You must strictly adhere to the following stack and versions for all generated code:
- **Framework:** Flutter (>=3.47.1) & Dart 3.13.1 with Sound Null Safety. Use the modern Impeller rendering engine optimizations where applicable.
- **State Management:** `flutter_riverpod` (v3.4.3). Use modern `@riverpod` annotations with `Notifier` and `AsyncNotifier` classes; avoid legacy `StateProvider`.
- **Routing:** `go_router` (v18.0.1) utilizing ShellRoutes for nested navigation, bottom nav bars, and role-based redirects.
- **Backend Services:** Firebase (Core, Auth, Firestore) and Supabase.
- **AI Integration:** `google_generative_ai` (v0.4.7) for the Gemini-powered property assistant.
- **UI/Styling:** Material 3 utilizing `lib/theme.dart` and `google_fonts`.

## 2. Directory Structure & Clean Architecture
Always place generated code in the correct directories based on our clean architecture pattern:
- `lib/core/`: Global business logic, offline sync engines, routing logic, and base configurations.
- `lib/features/`: Modularized feature components (e.g., billing, ticketing, dashboards).
- `lib/models/`: Data schemas (e.g., `RentalUnitItem`, `PaymentRecord`, `Ticket`). Must use `freezed` and `json_serializable`.
- `lib/providers/`: Riverpod state management files and dependency injection.
- `lib/screens/`: UI views and page layouts.
- `lib/theme.dart`: Centralized typography, spacing guidelines, and color schemes.

## 3. UI/UX & Design System Standards
When generating UI widgets or screens, enforce these exact UX principles:
- **Responsive Layouts:** The app must look native on mobile and scale gracefully to desktop/web. Use `LayoutBuilder`, `SliverGrid`, and constraint boxes. Never hardcode screen widths.
- **Micro-Interactions & Feedback:** Include subtle animations (e.g., `AnimatedContainer`, `Hero` transitions) for state changes. Always provide visual feedback for async actions (loading spinners, shimmer effects, toast notifications).
- **Modern Material 3 Typography & Spacing:** Adhere strictly to the spacing and typography defined in `lib/theme.dart`. Use standard 8-point grid spacing (8, 16, 24, 32) for padding and margins.
- **Empty & Error States:** Never leave a screen blank. If a list is empty or an API call fails, generate beautiful empty-state or error-state widgets with illustrations and clear call-to-action retry buttons.
- **Accessibility:** Ensure high contrast ratios. Use `Semantics` widgets where necessary, and ensure all actionable icons have `Tooltip` or `SemanticLabel` descriptors.

## 4. RAMP Specific Business Rules
When generating business logic, strictly enforce these domain rules:
- **Offline-First Protocol:** Mutations (payment approvals, ticket additions, unit updates) must use the local `PendingSyncAction` queue to store actions offline and flush them when connectivity is restored.
- **Optimistic UI:** Implement 0ms latency updates for critical flows, especially the Landlord Payment Verification queue.
- **Itemized Billing Engine:** Formula = Base Rent + Water Usage (₱45.00/cu.m) + Electric Usage (₱12.50/kWh) + Late Fees.
- **SLA Maintenance Engine:** Default severities = Emergency (24h), Medium (3 days), Low (7 days).
- **Audit Logging:** Administrative mutations must write to a system-wide immutable circular buffer for compliance tracking.

## 5. Role-Based Access Control (RBAC)
Always adapt logic and UI based on the active dual-role system:
- **Landlord UI:** Data-dense financial dashboards, AI natural language query bars, tenant payment verification queues, portfolio management, and maintenance dispatching. Desktop-first mindset for complex data tables.
- **Tenant UI:** Action-oriented screens for rent tracking, utility submeter monitoring, digital payment uploads (receipt screenshots/reference #s), and ticketing with photo uploads and 1-to-5 star ratings. Mobile-first mindset.

## 6. Coding Standards & Output Rules for Gemini
1. **Zero-Fluff Outputs:** Provide brief, high-value explanations. Let the code do the talking.
2. **Complete Code:** NEVER truncate code with comments like `// ... rest of code`. Always provide the full, copy-pasteable file or widget snippet.
3. **Performance:** Use `const` constructors everywhere. Break down large UI screens into smaller, private widget classes rather than helper methods returning widgets to optimize the build context.
4. **File Paths:** Always provide the exact file path as a comment at the very top of the code block (e.g., `// lib/features/maintenance/screens/ticket_detail_screen.dart`).
5. **Dependencies:** If a new package is required, specify the exact `flutter pub add <package>` command.