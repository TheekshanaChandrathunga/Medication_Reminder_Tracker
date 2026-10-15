# My Contribution

**Name:** Theekshana Umayangi  
**Index Number:** D/BSE/24/0004

## My Role

I worked as a **Backend Developer and QA Engineer**. I focused on Firebase integration, medication and adherence features, caregiver functionality, notifications, reports, and application testing.

## What I Did

- Connected the Flutter application to Firebase Authentication and Cloud Firestore.
- Implemented database operations for users, roles, medications, medication stock, adherence logs, reports, and caregiver-patient relationships.
- Created Firestore security rules to protect patient data and limit caregivers to their assigned patients.
- Implemented caregiver features for adding multiple patients without requiring patient IDs.
- Added patient editing, patient removal, medication-plan management, and patient selection for caregivers.
- Implemented **Taken** and **Missed** medication actions.
- Added adherence history records and medication stock updates when doses are taken.
- Added local medication reminders and missed-dose reminders using Flutter local notifications.
- Implemented patient-specific weekly, monthly, and custom reports.
- Included caregiver details, patient details, medication plans, and adherence data in PDF reports.
- Connected caregiver History and Reports pages to the selected patient’s medication activity.
- Created the complete application test document covering functional, integration, security, usability, and regression testing.
- Used Flutter analysis and Firebase rules deployment to validate the application.

## QA and Bug Fixing

I tested and fixed issues involving:

- Caregiver accounts opening the Patient interface.
- Incorrect navigation between caregiver and patient pages.
- Firestore permission errors when caregivers added medications or recorded adherence.
- Patient creation and editing errors.
- Patient-specific reports displaying incorrect data.
- Taken/Missed records not appearing in the correct History page.
- Missing back navigation and unclear caregiver controls.

## Challenges

### Firebase integration

Connecting Authentication, Firestore, reports, and security rules was challenging. At first, valid caregiver actions were rejected with `permission-denied` errors because the rules only supported patients managing their own data. I solved this by adding caregiver-role checks, caregiver-patient relationship validation, secure update rules, and atomic patient creation using `getAfter()`.

### Connecting devices and notifications

The application needed to share the same Firebase data between Patient and Caregiver devices while showing the correct role-based interface. I configured Firebase for the target platforms, added Android notification permissions and channels, handled web notification limitations, and tested medication reminders on different devices.

### Integration and merge issues

Backend and frontend changes sometimes caused merge conflicts and navigation problems. I resolved these issues while preserving the UI and Firebase functionality, then retested the affected workflows.

## Related GitHub Work

My work is reflected in commits including:

- **Medication Backend**
- **Debug Backend**
- **Medication missed complete**
- **notification update**
- **backend for reports page**
- **Add medication reports service**
- **Generate the report with full details**
- **Backend Update**
- **Caregiver Side Completed**
- **Test Documentation**

## Outcome

My contribution helped deliver a secure Firebase-backed medication tracker with Patient and Caregiver roles, medication reminders, Taken/Missed tracking, caregiver patient management, synchronized history, and patient-specific reports.
