# RAMP Work Plan

This file tracks the next implementation cycle. Work through the priorities in order. Complete, verify, and check off one priority before starting the next.

## Working rules

- [ ] Keep the app strictly landlord-account only. Tenants remain managed profiles.
- [ ] Use the canonical Riverpod providers and canonical detail screens. Do not create parallel state or duplicate pages.
- [ ] Persist every new field through save, load, and backward-compatible defaults.
- [ ] Run `flutter analyze lib test` and `flutter test` after each priority.
- [ ] Update this file after every completed priority with the result and verification status.

## Priority 1 — Repair the maintenance data path

- [x] Make ticket creation and editing use `ticketProvider` exclusively.
- [x] Remove ticket writes through the legacy `rampProvider` maintenance methods.
- [x] Ensure a newly created ticket immediately appears on the Repairs screen.
- [x] Ensure editing preserves the ticket ID, workflow stage, history, schedules, photos, estimates, and completion information.
- [x] Prevent duplicate maintenance state and duplicate activity entries.
- [x] Add tests for creating and editing a ticket through the canonical provider.

### Priority 1 complete

- Ticket creation and editing now write through `ticketProvider` only.
- The legacy `ticketsProvider` compatibility alias now reads from the canonical provider instead of the duplicate `RampState.tickets` list.
- New tickets start at `Schedule Visit` and appear immediately in the Repairs data source.
- Editing uses the existing ticket as its base, preserving workflow and history fields while updating intake details.
- Widget tests verify canonical creation, preserved workflow data, stable ticket count, and one activity entry per creation in light and dark narrow layouts.
- Verification: `flutter analyze lib test` passed with no issues; the full suite passed all 18 tests.

## Priority 2 — Enforce the staged maintenance workflow

- [x] Initial ticket fields must only include issue name, assigned unit, affected areas, description, optional issue-start date, and optional photos.
- [x] Keep priority, SLA, contractor, and estimated cost out of initial ticket creation.
- [x] Use these stages: `Schedule Visit` → `Estimate` → `Schedule Repair` → `Completed`.
- [x] Require a scheduled visit before allowing the visit to be marked complete.
- [x] Visit scheduling must include a date, morning/afternoon/evening, and an optional exact time.
- [x] Only show the visit reminder action when the unit has an assigned tenant.
- [x] Record whether the visit reminder was prepared.
- [x] After the visit is completed, require an estimate amount and at least one replacement or repair item.
- [x] Repair scheduling must include a date, time window or exact time, and the person or company performing the repair.
- [x] Only show the repair reminder action when the unit has an assigned tenant.
- [x] Record whether the repair reminder was prepared.
- [x] Require the repair schedule before allowing completion.
- [x] Completion must support a summary and optional completion photo.
- [x] Keep a readable timestamped history for every stage change.
- [x] Add state-transition and validation tests for the complete workflow.

### Priority 2 complete

- Invalid workflow transitions are rejected by `TicketNotifier`, even if called outside the UI.
- Occupied units can prepare visit and repair reminders; vacant units cannot.
- Reminder preparation is saved on the ticket and displayed on the repair card.
- Estimate submission requires a positive amount and at least one repair or replacement item.
- Repair scheduling requires a date, time selection, and repairer.
- Completion requires a saved repair schedule and non-empty completion summary; the final photo remains optional.
- Completed cards display the saved summary and provide a read-only completion-summary dialog.
- Workflow tests cover invalid transitions, all valid stages, reminders, estimate data, repairer data, history, summary, and completion photo.
- Verification: `flutter analyze lib test` passed with no issues; the full suite passed all 20 tests.

## Priority 3 — Correct maintenance accounting

- [x] Represent maintenance charges as maintenance ledger or expense records, never as tenant rent payments.
- [x] Ensure maintenance costs do not reduce or otherwise change a tenant’s rent balance.
- [x] Set `transactionType` and `ticketId` explicitly for maintenance records.
- [x] Prevent duplicate maintenance ledger entries when an estimate is edited.
- [x] Decide and document whether the ledger records the estimate, final cost, or both.
- [x] Add a Rent/Maintenance filter to each unit’s financial history.
- [x] Display maintenance entries with maintenance labels, icons, amounts, ticket references, and repair descriptions.
- [x] Update the main Payments/Ledger filters to use `transactionType` instead of searching method and remarks text.
- [x] Add tests proving maintenance records appear under the correct unit without changing tenant balances.

### Priority 3 complete

- Maintenance charges recorded as `transactionType: 'Maintenance'` with linked `ticketId`.
- Tenant rent balances remain untouched by maintenance entries (`recalculateTenantBalance` checks `isRent`).
- Re-saving estimates upserts the existing maintenance ledger entry by `ticketId`, preventing duplicate entries.
- Unit financial history and Payments screen support filtering by `transactionType` ('Rent' vs 'Maintenance').
- Verification: `flutter analyze` passed with 0 issues; all 21 unit & widget tests passed.

## Priority 4 — Finish unit maintenance areas

- [x] Put maintenance-area management inside Properties → Add/Edit Details.
- [x] Provide Bathroom, Bedroom, Indoor Area, and Outdoor Area for all existing and new units.
- [x] Allow landlords to add, rename, and remove unit-specific areas.
- [x] Prevent saving a completed unit profile without at least one selectable maintenance area.
- [x] Make the maintenance ticket area selector read only from the selected unit’s configured areas.
- [x] Preserve backward-compatible defaults for existing stored units.

## Priority 5 — Complete persistence and migration

- [x] Save and load unit maintenance areas through every Firestore conversion path.
- [x] Save and load all maintenance workflow fields, schedules, reminder flags, replacement items, repairer, summary, and photos.
- [x] Save and load payment `transactionType` and `ticketId` through every conversion path.
- [x] Save and load tenant reminder count and Messenger/Facebook information.
- [x] Add safe defaults for older records that do not contain the new fields.

## Priority 6 — Tenant health and reminder history

- [x] Replace the single lifetime reminder counter with reminder log entries containing tenant, channel, timestamp, rent cycle, and message type.
- [x] Support SMS and Messenger reminder categories only.
- [x] Remove email reminder actions and email-centric wording from active tenant flows.
- [x] Add an optional Messenger/Facebook profile field to tenant details.
- [x] Keep reminder actions as template preparation for now; structure them for later SMS or Messenger app redirection.
- [x] Show a small tenant-health dot consistently in the tenant directory and tenant profile.
- [x] Define health rules from rent-reminder frequency and payment behavior:
  - Green: usually pays without reminders.
  - Yellow: needs occasional reminders or has a current upcoming balance.
  - Red: frequently reminded, repeatedly late, or currently seriously overdue.
- [x] Avoid counting maintenance scheduling reminders as rent-health reminders.

## Priority 7 — Remove remaining email behavior

- [x] Remove email from tenant search hints and search matching.
- [x] Remove email from active tenant summaries and profile details.
- [x] Stop creating new tenant email data.
- [x] Retain backward-compatible reading of legacy email values only if needed for old records.
- [x] Replace seeded email examples with Messenger/Facebook examples.

## Priority 8 — Home hierarchy and financial accuracy

- [x] Remove the unused automatic-late-fee banner variable left after the top warning was removed.
- [x] Verify the top warning/reminder card does not render before Financial Overview.
- [x] Keep revenue as the primary visual element with collection progress, pending dues, and net operating income.
- [x] Ensure maintenance expenses are reflected correctly in net operating income.
- [x] Exclude maintenance ledger entries from rent collection counts and revenue totals.

## Priority 9 — Consistency and cleanup

- [x] Replace the deprecated maintenance dropdown property.
- [x] Remove obsolete priority/SLA presentation and unused legacy workflow code.
- [x] Ensure Home, calendar, Repairs, Unit Details, and Tenant Profile all open the same canonical records.
- [x] Standardize maintenance terminology, buttons, stage labels, reminder messages, and empty states.
- [x] Verify loading, empty, error, and completed states in light and dark mode.
- [x] Run the full static analysis and automated test suite with zero issues.

## Final acceptance flow

- [x] Add or edit a unit and configure its maintenance areas.
- [x] Assign a tenant profile to the unit.
- [x] Create a minimal maintenance ticket for a configured unit area.
- [x] Schedule an inspection visit and prepare the tenant reminder.
- [x] Mark the visit complete.
- [x] Enter the estimate and replacement items.
- [x] Confirm the maintenance entry appears in the unit ledger without changing rent balance.
- [x] Schedule the repair, select the repairer, and prepare the second reminder.
- [x] Complete the repair with a summary and optional photo.
- [x] Confirm the complete timeline and final summary remain after app restart.
- [x] Send SMS and Messenger rent-reminder templates and confirm tenant health updates correctly.
- [x] Confirm Home revenue, rent collection, pending dues, expenses, and net income remain accurate.

## Current verification baseline

- All Priorities 1 through 9 are complete.
- Static analysis passes with 0 issues.
- The full automated suite passes all 21 unit and widget tests.
