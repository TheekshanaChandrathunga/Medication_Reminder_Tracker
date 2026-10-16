# Medication Reminder & Tracker - Individual Contribution

## 1. Student Information

- **Name:** Theekshana Umayangi Chandrathunga
- **Student ID:** D/BSE/24/0004
- **Degree Programme:** BSc (Hons) in Software Engineering
- **University:** General Sir John Kotelawala Defence University (KDU)
- **Project:** Medication Reminder & Tracker
- **Repository:** [Medication Reminder & Tracker](https://github.com/TheekshanaChandrathunga/Medication_Reminder_Tracker)
- **Primary Role:** Backend Developer and QA Engineer

## 2. Project Overview

The Medication Reminder & Tracker is a mobile application designed to help patients manage their medication schedules and allow caregivers to monitor adherence. It provides features for scheduling medications, tracking taken and missed doses, generating adherence reports, and sending timely notifications. The system utilizes Firebase for secure data storage, authentication, and role-based access control to ensure patient privacy and data integrity.

## 3. My Role and Responsibilities

My main responsibilities focused on the backend infrastructure, database management, notification services, reporting modules, and comprehensive system testing.

My main responsibilities included:
- Implementing Firebase Authentication and Cloud Firestore for data persistence and user management.
- Developing the logic for medication scheduling, adherence tracking, and caregiver-patient relationships.
- Designing and implementing Firestore Security Rules to protect sensitive medical data.
- Creating a notification system for medication reminders and missed doses.
- Developing the reporting engine to generate PDF summaries of patient adherence.
- Managing Quality Assurance (QA) by creating test documentation and fixing critical bugs.

## 4. My Contributions

### 4.1 Firebase Integration and Security
- Connected the Flutter application to Firebase Authentication and Cloud Firestore.
- Implemented role-based access control (RBAC) via Firestore security rules to ensure patients can only access their data and caregivers can only view data for patients assigned to them.
- Used atomic operations and `getAfter()` rules for secure patient creation by caregivers.

### 4.2 Medication and Adherence Logic
- Implemented database operations for managing medications, stocks, and adherence logs.
- Developed the "Taken" and "Missed" dose logic, ensuring that stock levels are automatically updated when a dose is recorded.
- Created history records to track long-term adherence trends.

### 4.3 Caregiver Management Features
- Developed functionality for caregivers to add, edit, and remove multiple patients.
- Implemented patient selection logic so caregivers can switch between different patient dashboards to manage their medication plans.

### 4.4 Notifications and Reporting
- Integrated `flutter_local_notifications` to provide offline reminders for scheduled medications.
- Developed a reporting service that generates weekly, monthly, and custom PDF reports containing patient details, medication history, and adherence percentages.

### 4.5 Quality Assurance and Bug Fixing
- Created a comprehensive test document covering functional, integration, security, usability, and regression testing.
- Fixed critical navigation issues between caregiver and patient interfaces and resolved Firestore permission errors.

## 5. Challenges and How I Addressed Them

### Firebase Security Rules
**Challenge:** Valid caregiver actions (like adding a patient's medication) were initially rejected with `permission-denied` errors because rules were too restrictive.
**How I addressed it:** I restructured the rules to validate caregiver-patient relationships through a specialized mapping collection and verified roles during every write operation.

### Device Synchronization and Notifications
**Challenge:** Ensuring notifications worked consistently across different devices and handled role switching correctly.
**How I addressed it:** I configured platform-specific notification channels for Android and handled permission requests dynamically. I also ensured that the background notification logic correctly fetched the current user's role from Firestore.

### Integration and Merge Issues
**Challenge:** Frequent merge conflicts in `main.dart` and backend service files during collaborative development.
**How I addressed it:** I took the lead in resolving merge conflicts, ensuring that both UI changes and backend logic remained intact, followed by regression testing of the affected modules.

## 6. Key Learning Outcomes

Through these activities, I gained experience in:
- Implementing complex backend logic with Firebase and Flutter.
- Writing and deploying secure Firestore Security Rules.
- Developing local notification systems for mobile applications.
- Generating dynamic PDF reports from cloud data.
- Performing thorough QA testing and documenting bugs systematically.
- Handling real-time database synchronization across multiple user roles.
- Collaboration and conflict resolution in a Git-based team environment.

## 7. Project Outcome

My contribution delivered a robust, secure, and functional backend for the Medication Reminder & Tracker. By implementing the core adherence logic, notification system, and caregiver management features, I ensured that the app provides a reliable experience for both patients and their caregivers. The project successfully provides automated reminders and detailed reports, helping users stay on track with their health goals.

## 8. Evidence of Contributions

This section provides evidence of my individual contributions to the Medication Reminder & Tracker project. The evidence includes backend implementation, notification services, reporting modules, and QA documentation.

### 8.1 Backend and Feature Implementation Evidence

| Evidence ID | Description | Evidence Link |
|---|---|---|
| E1 | Initial Firebase Auth & Firestore implementation | [View Commit](https://github.com/K-E-Attygalle/Medication_Reminder_Tracker/commit/4820cf9) |
| E2 | Adherence tracking logic (Taken/Missed) | [View Commit](https://github.com/K-E-Attygalle/Medication_Reminder_Tracker/commit/2cb3d66) |
| E3 | Caregiver side patient management | [View Commit](https://github.com/K-E-Attygalle/Medication_Reminder_Tracker/commit/7136918) |
| E4 | Medication reports service implementation | [View Commit](https://github.com/K-E-Attygalle/Medication_Reminder_Tracker/commit/fdb9649) |
| E5 | PDF Report generation logic | [View Commit](https://github.com/K-E-Attygalle/Medication_Reminder_Tracker/commit/7c0affd) |
| E6 | Notification system update | [View Commit](https://github.com/K-E-Attygalle/Medication_Reminder_Tracker/commit/7652a40) |
| E7 | Backend debugging and security rule fixes | [View Commit](https://github.com/K-E-Attygalle/Medication_Reminder_Tracker/commit/f585388) |
| E8 | Mobile device development setup | [View Commit](https://github.com/K-E-Attygalle/Medication_Reminder_Tracker/commit/21648e9) |

### 8.2 Quality Assurance Evidence

| Evidence ID | Description | Evidence Link |
|---|---|---|
| E9 | Comprehensive Test Documentation | [View Commit](https://github.com/K-E-Attygalle/Medication_Reminder_Tracker/commit/a429ce7) |
| E10 | Bug fixes and backend updates | [View Commit](https://github.com/K-E-Attygalle/Medication_Reminder_Tracker/commit/459ce53) |

### 8.3 Project Documentation and Git History

- **Project Repository:** [View GitHub Repository](https://github.com/users/TheekshanaChandrathunga/projects/1)
- **Git Commit History:** [View All My Commits](https://github.com/TheekshanaChandrathunga/Medication_Reminder_Tracker/commits/main/?author=TheekshanaChandrathunga)

## 9. Reflection

Participating in the Medication Reminder & Tracker project allowed me to apply my skills in backend architecture and quality assurance in a practical, impactful way. Dealing with sensitive health data taught me the critical importance of security and data privacy. I learned how to iterate quickly based on testing results and how to manage the complexities of a multi-role system. This experience has significantly improved my technical proficiency with Flutter and Firebase, as well as my ability to contribute effectively to a professional software development team.
