# MediTrack Application Test Document

## 1. Document control

| Field | Value |
|---|---|
| Application | MediTrack Medication Reminder and Tracker |
| Version | 1.0.0+1 |
| Test document version | 1.0 |
| Firebase project | `meditrack-3a657` |
| Test type | Functional, integration, authorization, usability, and regression testing |
| Target platforms | Flutter Web and Android |
| Execution status values | Not Run, Pass, Fail, Blocked |

This document covers the complete user-facing application. Record the result, tester, date, and defect reference for every test case during execution.

## 2. Scope

### In scope

- Application startup and authentication
- Patient registration and patient dashboard
- Medication creation, editing, deletion, dose status, and stock updates
- Patient reminders and missed-dose reminders
- Patient history and reports
- Caregiver registration and caregiver dashboard
- Caregiver patient creation, editing, removal, and selection
- Caregiver medication-plan management
- Caregiver Taken/Missed actions
- Caregiver history and patient-specific reports
- PDF report generation and report contents
- Firebase authorization and data isolation
- Navigation, logout, and error handling

### Out of scope

- Firebase Console administration
- App-store publishing and signing
- Third-party operating-system notification delivery guarantees
- Performance benchmarking at production scale
- Testing with real medical data

## 3. Test environments

### Web

- Supported browser: current Chrome or Edge
- Firebase web configuration enabled
- Browser notification permission available when notification testing is required

### Android

- Android device or emulator
- Notification permission enabled
- App notification channel enabled
- Firebase Android configuration installed

### Required test accounts

Create separate accounts for each role. Do not reuse production credentials.

| Account | Role | Example |
|---|---|---|
| Patient A | Patient | `patient.a@test.example` |
| Patient B | Patient | `patient.b@test.example` |
| Caregiver A | Caregiver | `caregiver.a@test.example` |
| Caregiver B | Caregiver | `caregiver.b@test.example` |

### Required sample data

- Patient A: at least two medications, with one medication having two dose times
- Patient B: at least one medication
- Caregiver A: Patient A and Patient B linked
- Caregiver B: no shared patients with Caregiver A
- At least one dose marked Taken and one dose marked Missed

## 4. General execution rules

1. Start each test from the stated precondition.
2. Use a fresh app reload after authentication or Firebase rule changes.
3. Record the exact error text for every failure.
4. Verify both the UI and the resulting Firebase-backed behavior.
5. Never use real patient names, phone numbers, addresses, or medical information.
6. For notification tests, use a dose time a few minutes in the future.

## 5. Test case template

| Field | Description |
|---|---|
| Test ID | Unique identifier |
| Preconditions | Required account or data state |
| Steps | Actions performed by the tester |
| Expected result | Measurable expected behavior |
| Status | Not Run / Pass / Fail / Blocked |
| Actual result / defect | Complete during execution |

## 6. Authentication and account routing

| ID | Test case | Preconditions and steps | Expected result | Status |
|---|---|---|---|---|
| AUTH-001 | Patient registration | Open Register, enter valid Patient details, submit | Account is created and patient is routed to the Patient home page | Not Run |
| AUTH-002 | Caregiver registration | Open Register, select Caregiver, enter valid details, submit | Account is created and caregiver is routed to the Caregiver home page, not the Patient home page | Not Run |
| AUTH-003 | Duplicate email registration | Register with an existing email | Registration fails with a clear Firebase/authentication message | Not Run |
| AUTH-004 | Required registration fields | Submit registration with required fields empty | Form validation identifies missing fields and does not create an account | Not Run |
| AUTH-005 | Valid patient login | Log in with Patient credentials | Patient home page opens | Not Run |
| AUTH-006 | Valid caregiver login | Log in with Caregiver credentials | Caregiver home page opens | Not Run |
| AUTH-007 | Invalid login | Enter incorrect email or password | Login fails with a visible error and does not open either dashboard | Not Run |
| AUTH-008 | Session restoration | Log in, close and reopen the app | The authenticated user is routed to the correct role dashboard | Not Run |
| AUTH-009 | Logout | Open Profile or the dashboard logout control and confirm logout | Session ends and Login page opens; protected data is no longer visible | Not Run |
| AUTH-010 | Invalid or missing role | Use an account whose profile role is missing or unsupported | A clear account-role error is shown; the app does not silently open the wrong dashboard | Not Run |

## 7. Patient medication management

| ID | Test case | Preconditions and steps | Expected result | Status |
|---|---|---|---|---|
| MED-001 | Open medication page | Log in as Patient and open Meds | Medication list and Add Medication control are displayed | Not Run |
| MED-002 | Add valid medication | Enter name, dosage, frequency, dose time, start date, and valid optional values; save | Medication is saved and appears in the medication list and home schedule | Not Run |
| MED-003 | Required medication validation | Leave name or dosage empty and save | Medication is not saved and validation message is shown | Not Run |
| MED-004 | Add multiple medications | Add two or more medications | All medications appear independently without replacing one another | Not Run |
| MED-005 | Edit medication | Open an existing medication, change its details, save | Updated details appear in Meds, Home, History context, and Reports | Not Run |
| MED-006 | Delete medication | Delete an existing medication and confirm | Medication is removed from the list and no longer appears in the schedule | Not Run |
| MED-007 | Medication image | On Android, attach an image while creating or editing medication | Image is displayed in the form and the medication remains usable after saving | Not Run |
| MED-008 | Invalid quantity values | Enter invalid quantity or refill threshold values | App safely handles invalid numeric input and does not crash | Not Run |
| MED-009 | Medication back navigation | Open Add Medication from Home or Meds and tap Back | Previous page is restored without losing unrelated data | Not Run |
| MED-010 | Medication persistence | Add or edit medication, reload app, reopen Meds | Changes persist after reload | Not Run |

## 8. Patient dose actions and reminders

| ID | Test case | Preconditions and steps | Expected result | Status |
|---|---|---|---|---|
| DOSE-001 | Mark dose Taken | Patient has a medication; tap Mark as Taken on Home | Medication shows Taken, an adherence log is created, and quantity decreases by one when stock is available | Not Run |
| DOSE-002 | Mark dose Missed | Patient has a medication; tap Mark as Missed | Medication shows Missed and a missed adherence log is created | Not Run |
| DOSE-003 | Taken/Missed mutual status | Mark a dose Taken, then verify status and mark the next applicable dose Missed | Current dose status is shown correctly and records are not silently overwritten | Not Run |
| DOSE-004 | Empty stock Taken action | Set medication quantity to zero and mark Taken | App does not produce a negative quantity and displays a safe result | Not Run |
| DOSE-005 | Scheduled reminder | Configure a dose a few minutes ahead and keep notifications enabled | Reminder notification appears at the scheduled time | Not Run |
| DOSE-006 | Missed reminder | Leave the scheduled dose unacknowledged | Missed medication reminder appears approximately 30 minutes after the scheduled dose | Not Run |
| DOSE-007 | Notification permission denied | Deny OS/browser notification permission | App remains usable and does not crash; the limitation is surfaced where applicable | Not Run |
| DOSE-008 | Multiple dose times | Configure multiple dose times for one medication | A reminder is scheduled for each configured dose time | Not Run |

## 9. Patient history and reports

| ID | Test case | Preconditions and steps | Expected result | Status |
|---|---|---|---|---|
| REP-001 | Patient history list | Create Taken and Missed records, open History | Records show medication name, status, date, and time | Not Run |
| REP-002 | History ordering | Create records at different times | Newer history records appear in the expected order | Not Run |
| REP-003 | Patient report summary | Open Reports as Patient | Report shows correct taken count, missed count, percentage, and daily adherence | Not Run |
| REP-004 | Patient PDF generation | Select a valid period and Generate PDF | PDF is saved/downloaded successfully | Not Run |
| REP-005 | Patient PDF contents | Open generated PDF | PDF contains patient details, medication plan, adherence metrics, events, and medication history | Not Run |
| REP-006 | Empty report period | Select a period with no logs | Report loads with zero counts and does not crash | Not Run |
| REP-007 | Report periods | Test This Week, This Month, and Custom | The displayed and exported records match the selected date range | Not Run |
| REP-008 | Report error handling | Simulate unavailable Firebase access or permission denial | A visible error is shown; no success message is displayed | Not Run |

## 10. Caregiver patient management

| ID | Test case | Preconditions and steps | Expected result | Status |
|---|---|---|---|---|
| CG-001 | Caregiver empty state | Log in as a new caregiver with no linked patients | Caregiver dashboard shows no-patient message and Add Patient option | Not Run |
| CG-002 | Create patient without patient ID | Tap Add Patient and submit the patient form | Patient is created with a generated ID; caregiver is not asked to enter a patient ID | Not Run |
| CG-003 | Add multiple patients | Create Patient A and Patient B | Both patients appear in My Patients and can be selected independently | Not Run |
| CG-004 | View patient list | Open My Patients | Each linked patient displays separately with patient actions and medication plan | Not Run |
| CG-005 | Edit patient details | Tap Edit patient, change demographic/care fields, save | Updated details appear on caregiver dashboard, patient list, and reports | Not Run |
| CG-006 | Required edit validation | Clear required patient name or relationship and save | Validation blocks the save and identifies the required field | Not Run |
| CG-007 | Remove patient confirmation | Tap Remove patient and cancel | Patient remains linked | Not Run |
| CG-008 | Remove patient | Tap Remove patient and confirm | Patient is removed from the caregiver list; historical records are preserved | Not Run |
| CG-009 | Patient-specific selection | Select Patient B after viewing Patient A | Dashboard schedule, adherence, notes, and details change to Patient B | Not Run |
| CG-010 | Caregiver patient isolation | Log in as Caregiver B | Caregiver B cannot see or edit Caregiver A's patients | Not Run |

## 11. Caregiver medication plans and dose actions

| ID | Test case | Preconditions and steps | Expected result | Status |
|---|---|---|---|---|
| CG-MED-001 | Add patient medication | Select a linked patient and add a medication | Medication is saved under the selected patient's ID and appears in that patient's plan | Not Run |
| CG-MED-002 | Edit patient medication | Edit a medication from My Patients or caregiver dashboard | Only the selected patient's medication is changed | Not Run |
| CG-MED-003 | Caregiver medication permission | Save a medication as caregiver | No Firestore permission error appears | Not Run |
| CG-MED-004 | Caregiver Taken action | Select a patient and tap Taken for a scheduled medication | The selected patient's medication updates, stock changes correctly, and an adherence log is created | Not Run |
| CG-MED-005 | Caregiver Missed action | Select a patient and tap Missed | A Missed log is created for the selected patient and status updates | Not Run |
| CG-MED-006 | Wrong-patient protection | Select Patient A, record a dose, then select Patient B | Patient B's medication and history are unchanged | Not Run |
| CG-MED-007 | Caregiver reminders | Select a patient with future dose times and keep notifications enabled | Caregiver device receives reminders for that selected patient's schedule | Not Run |
| CG-MED-008 | Medication plan persistence | Reload caregiver app after adding a plan | Plan remains associated with the correct patient | Not Run |

## 12. Caregiver history and reports

| ID | Test case | Preconditions and steps | Expected result | Status |
|---|---|---|---|---|
| CG-REP-001 | Caregiver History navigation | Open caregiver History from bottom navigation | Caregiver History page opens, not the Patient History page | Not Run |
| CG-REP-002 | Caregiver patient selector | Open caregiver History and change selected patient | History reloads with only the selected patient's records | Not Run |
| CG-REP-003 | Caregiver Taken/Missed history | Record Taken and Missed doses from caregiver Home, then open History | Both records appear with correct medication, status, date, and time | Not Run |
| CG-REP-004 | Caregiver report selector | Open caregiver Reports | Linked patients are available in the patient selector | Not Run |
| CG-REP-005 | Patient-specific caregiver report | Select Patient A and inspect report | Counts, medication plan, and events belong only to Patient A | Not Run |
| CG-REP-006 | Switch report patient | Switch from Patient A to Patient B | Summary, medication-level adherence, daily status, and PDF target change to Patient B | Not Run |
| CG-REP-007 | Medication-level report data | Record Taken/Missed events for multiple medications | Report displays each medication with its own taken count, missed count, and adherence percentage | Not Run |
| CG-REP-008 | Adherence History Log shortcut | Open caregiver Profile and tap Adherence History Log | Caregiver History opens with linked patient selection available | Not Run |
| CG-REP-009 | Report History Log shortcut | Open a caregiver report and tap Adherence History Log if present | The selected patient's History page opens with matching records | Not Run |
| CG-REP-010 | Caregiver PDF contents | Generate a report for Patient A | PDF contains caregiver details, Patient A details, Patient A medications, and Patient A adherence events | Not Run |
| CG-REP-011 | Separate patient PDFs | Generate reports for Patient A and Patient B | Each PDF contains the correct patient data and does not mix their medication or adherence records | Not Run |
| CG-REP-012 | Caregiver report period | Test This Week, This Month, and Custom | Only events in the selected period are included in summary and exported report | Not Run |

## 13. Navigation and role preservation

| ID | Test case | Preconditions and steps | Expected result | Status |
|---|---|---|---|---|
| NAV-001 | Patient bottom navigation | As Patient, open Home, Meds, History, Reports, and Profile | Each tab opens the correct Patient page | Not Run |
| NAV-002 | Caregiver bottom navigation | As Caregiver, open Home, My Patients, History, Reports, and Profile | Each tab opens the correct Caregiver-aware page | Not Run |
| NAV-003 | Caregiver Home return | From caregiver History, Reports, Profile, and My Patients tap Home | Caregiver Home opens, never the Patient Home page | Not Run |
| NAV-004 | Back from medication form | Open medication form from caregiver and patient flows, then tap Back | Correct previous page opens | Not Run |
| NAV-005 | Back from My Patients | Open My Patients and tap the AppBar back button | Caregiver Home opens | Not Run |
| NAV-006 | Patient report shortcut | From a patient card tap Patient report | Report opens with that patient preselected | Not Run |
| NAV-007 | Deep navigation reload | Navigate through several pages, reload, and use bottom navigation | Correct role and page behavior are preserved after reload | Not Run |

## 14. Authorization and data integrity

| ID | Test case | Preconditions and steps | Expected result | Status |
|---|---|---|---|---|
| SEC-001 | Patient profile isolation | Log in as Patient A and attempt to access Patient B data | Patient B data is not readable | Not Run |
| SEC-002 | Caregiver relationship isolation | Caregiver A attempts to read an unlinked patient | Firestore denies access and UI shows an error without exposing data | Not Run |
| SEC-003 | Caregiver profile update scope | Caregiver attempts to update an unlinked patient | Update is denied | Not Run |
| SEC-004 | Patient role preservation | Attempt to change a managed patient role through profile editing | Role remains Patient; unauthorized role change is rejected | Not Run |
| SEC-005 | Medication owner preservation | Attempt to update a medication with a different `userId` | Firestore rejects the update | Not Run |
| SEC-006 | Adherence owner preservation | Caregiver records a dose for a linked patient | Log uses the selected patient ID, not the caregiver ID | Not Run |
| SEC-007 | Removed patient access | Remove a patient relationship, then reload caregiver pages | Patient is no longer listed for that caregiver | Not Run |
| SEC-008 | Unauthenticated access | Sign out and try to open protected routes | User is routed to Login or shown a protected-access state | Not Run |

## 15. Error handling and usability

| ID | Test case | Preconditions and steps | Expected result | Status |
|---|---|---|---|---|
| UX-001 | Firebase unavailable | Disable network or use an unavailable Firebase configuration | Loading/error state is shown; the app does not crash | Not Run |
| UX-002 | Save failure feedback | Force a medication or patient save failure | Error SnackBar identifies the failed operation | Not Run |
| UX-003 | Loading feedback | Open pages while data is loading | Progress indicator or loading message is shown | Not Run |
| UX-004 | Long patient names | Use a long name and open caregiver cards | Text remains readable and does not break the layout | Not Run |
| UX-005 | Multiple patients on small screen | Add several patients on a narrow viewport | Cards and actions remain usable and scroll correctly | Not Run |
| UX-006 | Empty medication plan | Select a patient without medication | Empty schedule message and Add Medication action are shown | Not Run |
| UX-007 | Empty history | Open history with no adherence logs | No-history state is shown without an exception | Not Run |
| UX-008 | PDF permission failure | Deny file/download permission where applicable | User sees a clear report-download error | Not Run |

## 16. Regression checklist

Run this checklist after any Firebase rule, authentication, navigation, medication, or report change.

- [ ] Patient login opens Patient Home.
- [ ] Caregiver login opens Caregiver Home.
- [ ] Caregiver Home does not redirect to Patient Home after using another tab.
- [ ] Patient can add, edit, and remove medication.
- [ ] Caregiver can add multiple patients without entering patient IDs.
- [ ] Caregiver can edit and remove a linked patient.
- [ ] Caregiver can add and edit the selected patient's medication.
- [ ] Patient can mark medication Taken and Missed.
- [ ] Caregiver can mark selected-patient medication Taken and Missed.
- [ ] Taken/Missed records appear in the correct patient's History.
- [ ] Caregiver History patient selector changes the displayed records.
- [ ] Patient-specific reports do not mix patient data.
- [ ] Generated PDF contains caregiver, patient, medication, and adherence details.
- [ ] Firebase permission errors are not shown during valid workflows.
- [ ] Logout clears access to protected pages.
- [ ] `flutter analyze` completes without errors.
- [ ] Firestore rules compile and deploy successfully when rules change.

## 17. Defect report template

| Field | Value |
|---|---|
| Defect ID | |
| Test case ID | |
| Title | |
| Severity | Critical / High / Medium / Low |
| Environment | Web / Android, browser or device |
| Account role | Patient / Caregiver |
| Preconditions | |
| Steps to reproduce | |
| Expected result | |
| Actual result | |
| Error message | |
| Screenshot or log | |
| Reproducibility | Always / Sometimes / Once |
| Status | Open / Fixed / Retest / Closed |

## 18. Validation commands

Run these commands from the `flutter_app` directory:

```powershell
flutter analyze
flutter test
```

If Firestore rules are changed, deploy them with:

```powershell
firebase deploy --project meditrack-3a657 --only firestore:rules
```

The current project does not contain a `test` directory, so `flutter test` requires automated tests to be added before it can execute application test cases. The manual cases in this document remain applicable.

## 19. Test execution summary

Complete this section after executing the test cases.

| Metric | Result |
|---|---|
| Total test cases | 89 |
| Passed | |
| Failed | |
| Blocked | |
| Not Run | |
| Open critical defects | |
| Open high-severity defects | |
| Overall result | Not Executed |

### Defect severity guidance

- **Critical:** Data loss, unauthorized access, application cannot start, or a core workflow is unusable.
- **High:** A major workflow such as login, medication saving, adherence recording, or report generation fails for a valid user.
- **Medium:** A feature works incorrectly in a limited scenario, with a workaround available.
- **Low:** Cosmetic, wording, spacing, or minor usability issue with no data or workflow impact.

## 20. Entry and exit criteria

### Entry criteria

- Firebase project is available and the latest Firestore rules are deployed.
- A test build can start on the selected target platform.
- Separate Patient and Caregiver test accounts are available.
- Required sample medications and patient relationships can be created.
- The tester has access to record screenshots, logs, and downloaded PDFs.

### Exit criteria

Testing may be considered complete when:

- All Critical and High test cases have a result.
- All Critical and High defects are fixed and successfully retested.
- No unauthorized patient or caregiver data access is observed.
- Patient and caregiver medication Taken/Missed actions appear in the correct History page.
- Patient-specific reports and PDFs contain no cross-patient data.
- Authentication and role-based navigation pass.
- The regression checklist is completed.
- `flutter analyze` completes without compilation errors.
- Any remaining Medium or Low defects are documented and accepted.

## 21. Test evidence register

Record links or file names for evidence collected during execution.

| Evidence ID | Test case ID | Evidence type | Location or file name | Notes |
|---|---|---|---|---|
| E-001 | | Screenshot | | |
| E-002 | | Screen recording | | |
| E-003 | | Generated PDF | | |
| E-004 | | Firebase/log output | | |
| E-005 | | Defect report | | |

## 22. Test sign-off

| Role | Name | Signature | Date | Decision |
|---|---|---|---|---|
| Tester | | | | |
| Developer | | | | |
| Project supervisor | | | | |

### Final decision

- [ ] Approved for release
- [ ] Approved with documented known issues
- [ ] Not approved; retesting required

### Known issues and conditions of approval

Record any accepted defects, blocked cases, platform limitations, or follow-up work here:

1. 
2. 
3. 
