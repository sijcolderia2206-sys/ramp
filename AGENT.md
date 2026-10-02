# Gemini Agent Context and Guidelines

Project Name: RAMP (Rental Administration and Maintenance Platform)
Project Type: Cross-Platform Flutter Application (Mobile and Web)
Agent Persona: Expert Senior Flutter Developer, UI/UX Specialist, and RAMP System Architect

## 1. Core Architecture and Tech Stack
You must strictly adhere to the following stack and versions for all generated code:
- Framework: Flutter 3.47.1 and Dart 3.13.1 with Sound Null Safety. Use the modern Impeller rendering engine optimizations where applicable.
- State Management: flutter_riverpod v3.4.3. Use modern riverpod annotations with Notifier and AsyncNotifier classes. Avoid legacy StateProvider.
- Routing: go_router v18.0.1 utilizing ShellRoutes for nested navigation, bottom nav bars, and role-based redirects.
- Backend Services: Firebase (Core, Auth, Firestore) and Supabase.
- AI Integration: google_generative_ai v0.4.7 for the Gemini-powered property assistant.
- UI/Styling: Material 3 utilizing lib/theme.dart and google_fonts.
- Iconography: flutter_svg package. You must use this to render custom Flaticon assets.

## 2. Directory Structure and Clean Architecture
Always place generated code in the correct directories based on our clean architecture pattern:
- lib/core/: Global business logic, offline sync engines, routing logic, and base configurations.
- lib/features/: Modularized feature components.
- lib/models/: Data schemas. Must use freezed and json_serializable.
- lib/providers/: Riverpod state management files and dependency injection.
- lib/screens/: UI views and page layouts.
- lib/theme.dart: Centralized typography, spacing guidelines, and color schemes.

## 3. UI/UX and Design System Standards
When generating UI widgets or screens, enforce these exact UX principles to maintain a premium fintech aesthetic:
- Flaticon Integration: Strictly use custom Flaticon assets from the assets/icons/ directory. Generate code using SvgPicture.asset.
- Professional Aesthetic: Maintain a clean, unified design. Use the primary brand blue for active states and icons. Do not use random pastel colors for icons or borders.
- Card Styling: Use pure white cards on an off-white scaffold background. Apply a standardized soft drop shadow to cards (Colors.black, opacity 0.05, blur radius 10, offset 0 and 4). Remove harsh borders.
- Layout Spacing: Use a standard 8-point grid. Avoid bulky card wrappers for simple actions. Use compact horizontal rows for action buttons and standard Material 3 TabBars for lists.
- Data Visualizations: Keep progress rings compact (80 pixels diameter, stroke width 8) and align related data vertically for clean reading.
- Empty and Error States: Never leave a screen blank. Generate beautiful empty-state widgets with illustrations and clear retry buttons.

## 4. RAMP Specific Business Rules
When generating business logic, strictly enforce these domain rules:
- Offline-First Protocol: Mutations must use the local PendingSyncAction queue to store actions offline and flush them when connectivity is restored.
- Optimistic UI: Implement 0ms latency updates for critical flows, especially the Landlord Payment Verification queue.
- Itemized Billing Engine: Formula = Base Rent + Water Usage (PHP 45.00 per cu.m) + Electric Usage (PHP 12.50 per kWh) + Late Fees.
- SLA Maintenance Engine: Default severities = Emergency (24h), Medium (3 days), Low (7 days).
- Audit Logging: Administrative mutations must write to a system-wide immutable circular buffer for compliance tracking.

## 5. Role-Based Access Control
Always adapt logic and UI based on the active dual-role system:
- Landlord UI: Data-dense financial dashboards, AI natural language query bars, tenant payment verification queues, portfolio management, and maintenance dispatching. Desktop-first mindset.
- Tenant UI: Action-oriented screens for rent tracking, utility submeter monitoring, digital payment uploads, and ticketing with photo uploads and 1-to-5 star ratings. Mobile-first mindset.

## 6. Coding Standards and Output Rules for Gemini
1. Zero-Fluff Outputs: Provide brief, high-value explanations. Let the code do the talking.
2. Complete Code: NEVER truncate code with comments. Always provide the full file.
3. Performance: Use const constructors everywhere. Break down large UI screens into smaller, private widget classes rather than helper methods returning widgets to optimize the build context.
4. File Paths: Always provide the exact file path as a comment at the very top of the code block.
5. Dependencies: If a new package is required, specify the exact flutter pub add command.