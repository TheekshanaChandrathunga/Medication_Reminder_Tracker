# Sprint Journals

## Sprint 1: Authentication & Core Medication Management

**Sprint Duration:** Weeks 1–2
**Sprint Goal:** Establish the technical foundation of the Medication Reminder & Tracker application and enable users to securely access the system and begin managing their medication information.

---

## Key Activities

### 1. Requirement Analysis

The team reviewed the Software Requirements Specification (SRS) for the Medication Reminder & Tracker application and identified the core functionality required for the first sprint.

The following major functional areas were identified for the overall system:

* User Authentication
* Medication Management
* Medication Scheduling
* Medication Reminders
* Adherence Tracking
* Medication History
* Reports and Analytics
* Caregiver Management

Based on the product backlog and feature priorities, the team selected the following high-priority user stories for Sprint 1:

* **US-01:** User Registration
* **US-02:** User Login
* **US-03:** Add Medication
* **US-04:** View Medications

These stories were selected because they provide the initial foundation required for users to access the system and begin maintaining their medication information.

---

### 2. Tooling and Project Setup

The team established the development environment and collaboration tools required for the project.

The following setup activities were completed:

* GitHub repository initialized.
* GitHub Project Board configured.
* Sprint 1 milestone created.
* Collaborators added to the repository.
* Product backlog prepared using GitHub Issues.
* Priority labels created for user stories.
* Development responsibilities discussed and assigned among team members.

The GitHub Project Board was configured to track the progress of each task using the following workflow:

* **Todo**
* **In Progress**
* **Review / QA**
* **Done**

---

### 3. Product Backlog Creation

The Product Owner and development team reviewed the requirements defined in the SRS and converted the selected functional requirements into user-centred user stories.

Each user story follows the standard Agile format:

> **As a [persona], I want [capability], so that [benefit].**

Each GitHub Issue includes:

* User Story ID
* User Story Description
* Priority
* Acceptance Criteria
* Sprint Assignment
* Labels
* Story Point Estimate

The selected Sprint 1 stories are listed below.

| User Story | Description                                                                                                                                         | Priority |
| ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| **US-01**  | As a new user, I want to create an account using my email and password so that I can securely access and manage my personal medication information. | High     |
| **US-02**  | As a registered user, I want to log in securely so that I can access my personal medication information and use the application's features.         | High     |
| **US-03**  | As a patient, I want to add my medication details, including dosage and schedule, so that I can manage my medication routine effectively.           | High     |
| **US-04**  | As a patient, I want to view all my medications so that I can easily review and manage my current medication information.                           | High     |

The remaining user stories were retained in the Product Backlog for implementation in future sprints.

---

## 4. Sprint 1 Planning

During Sprint Planning, the team reviewed the high-priority items in the Product Backlog and selected four user stories for Sprint 1.

### Stories Assigned to Sprint 1

* **US-01: User Registration**
* **US-02: User Login**
* **US-03: Add Medication**
* **US-04: View Medications**

### Sprint Goal

> **"Enable users to create an account, securely log into the Medication Reminder & Tracker application, add their medication information, and view their registered medications."**

The team agreed that completing these four stories would provide a usable initial foundation for the Medication Reminder & Tracker application.

---

## 5. UI/UX Design

The UI/UX design activities for Sprint 1 focused on designing the core screens required for the selected user stories.

The following screens were identified and designed:

* User Registration Screen
* User Login Screen
* Add Medication Screen
* Medication List Screen

The UI/UX design focused on:

* Simple and user-friendly navigation.
* Clear form fields.
* Readable medication information.
* Appropriate validation messages.
* Consistent user interface components.
* Accessibility and ease of use.

The designs were reviewed by the team and refined before implementation.

---

## 6. Frontend Development

Frontend development was initiated for the core functionality included in Sprint 1.

The following areas were developed:

### User Registration

The registration interface allows a new user to:

* Enter an email address.
* Enter a password.
* Provide the required account information.
* Submit the registration form.
* Receive validation feedback when required information is missing or invalid.

### User Login

The login functionality allows registered users to:

* Enter their registered credentials.
* Authenticate securely.
* Access the application's protected features.
* Receive an error message when invalid credentials are provided.

### Add Medication

The medication management interface allows users to add medication information, including:

* Medication name.
* Dosage.
* Medication category or relevant details.
* Medication schedule.
* Additional medication instructions where applicable.

Form validation is implemented to ensure that required medication information is provided before the medication is saved.

### View Medications

Users can access a medication list containing the medications registered under their account.

The medication list displays relevant medication information and allows users to easily review their current medications.

---

## 7. Backend and Database Development

The backend and database foundation was developed to support the selected Sprint 1 functionality.

The development activities included:

* User account creation.
* Secure user authentication.
* Storing user information.
* Creating medication records.
* Associating medication records with the relevant user.
* Retrieving medication records for the authenticated user.
* Validating required input data.

The database design follows the system requirements defined in the SRS and supports the relationship between users and their medication records.

---

# Ceremonies

## Sprint Planning 1

**Date:** To be updated
**Attendees:** Scrum Master, Product Owner, Development Team, UI/UX Team

### Outcome

The team:

* Reviewed the Product Backlog.
* Selected four high-priority user stories.
* Defined the Sprint Goal.
* Discussed technical implementation requirements.
* Assigned story point estimates.
* Identified team responsibilities.

The four selected user stories were moved from the Product Backlog into the Sprint 1 milestone.

---

## Daily Standup Logs

| Date        | Key Updates                                                                                                                             | Blockers                                                                     |
| ----------- | --------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| **Day 1**   | Sprint Planning completed. Sprint Goal defined and Sprint 1 user stories selected. GitHub repository and Project Board setup initiated. | None                                                                         |
| **Day 2–3** | Product Backlog and GitHub Issues prepared. User Registration and Login requirements reviewed. UI/UX design activities started.         | None                                                                         |
| **Day 4–5** | Registration and Login interfaces developed. Authentication functionality integrated with the backend.                                  | Integration and validation issues may require additional testing.            |
| **Day 6–7** | Add Medication functionality developed. Medication data model and database operations implemented.                                      | Medication field validation and data consistency required testing.           |
| **Day 8–9** | View Medications functionality integrated with the backend and database. Medication records retrieved for authenticated users.          | None                                                                         |
| **Day 10**  | Sprint functionality tested against the acceptance criteria. Bugs and UI issues reviewed and corrected.                                 | Any remaining issues moved to the Sprint backlog or addressed before review. |

> **Note:** Replace the above Day labels with your team's actual standup dates and update the progress and blockers according to what your team actually completed.

---

# Sprint 1 Review

The Sprint 1 functionality was reviewed against the acceptance criteria defined for the selected user stories.

## Demonstrated Functionality

The Sprint Review demonstration includes:

* User Registration
* User Login
* Add Medication
* View Medication List

The team demonstrated how a new user can create an account, log into the application, add medication information, and subsequently view the medications associated with their account.

---

## User Story Completion

### US-01: User Registration

**Acceptance Criteria:**

* **Given** I am a new user, **when** I enter valid registration details and submit the form, **then** my account is created successfully.
* **Given** an email address is already registered, **when** I attempt to register, **then** the system displays an appropriate error message.

### US-02: User Login

**Acceptance Criteria:**

* **Given** I have a registered account, **when** I enter valid credentials, **then** I am successfully logged into the application.
* **Given** I enter invalid credentials, **when** I attempt to log in, **then** the system displays an appropriate error message.

### US-03: Add Medication

**Acceptance Criteria:**

* **Given** I am logged into the application, **when** I enter valid medication details and save the medication, **then** the medication is successfully added to my account.
* **Given** required medication information is missing, **when** I attempt to save the medication, **then** the system displays appropriate validation messages.

### US-04: View Medications

**Acceptance Criteria:**

* **Given** I have added one or more medications, **when** I open my medication list, **then** the system displays all medications associated with my account.
* **Given** I have not added any medications, **when** I open my medication list, **then** the system displays an appropriate empty-state message.

---

# Sprint 1 Outcome

At the end of Sprint 1, the application is expected to provide the following core workflow:

> **Register → Login → Add Medication → View Medications**

The completion of these features establishes the initial foundation of the Medication Reminder & Tracker application.

Future sprints can build upon this foundation by implementing medication scheduling, reminders, adherence tracking, medication history, reports, and caregiver-related functionality.

---

# Sprint 1 Reflection

| Metric                           | Status        |
| -------------------------------- | ------------- |
| **Stories Planned**              | 4             |
| **Stories Completed**            | To be updated |
| **Total Story Points Planned**   | To be updated |
| **Total Story Points Completed** | To be updated |
| **Velocity**                     | To be updated |
| **Completion Rate**              | To be updated |

## What Went Well

* The Sprint 1 scope focused on high-priority core functionality.
* The selected user stories provide direct value to the application's primary users.
* The stories establish a clear foundation for future medication reminder and tracking features.
* The Product Backlog and Sprint scope were clearly defined.
* The acceptance criteria provide clear conditions for testing each feature.

## Challenges

* Authentication and database integration require careful testing.
* Medication information must be correctly associated with the authenticated user.
* Input validation must be implemented consistently across all forms.
* Dependencies between frontend, backend, and database development require effective team coordination.

## Improvements for the Next Sprint

For the next sprint, the team will:

* Review the velocity achieved during Sprint 1.
* Select a realistic number of user stories based on the team's capacity.
* Improve integration testing between frontend and backend components.
* Address any bugs or incomplete functionality identified during the Sprint Review.
* Continue implementing high-priority features from the Product Backlog.

---

# Story Point Estimation

The development team uses the Fibonacci sequence to estimate the relative effort and complexity of User Stories.

| Story Points | Meaning                                                  |
| ------------ | -------------------------------------------------------- |
| **1**        | Very simple                                              |
| **2**        | Simple                                                   |
| **3**        | Moderate                                                 |
| **5**        | Medium/High complexity                                   |
| **8**        | Complex                                                  |
| **13**       | Very large; should ideally be split into smaller stories |

Story points are estimated based on:

* Technical complexity.
* Development effort.
* Integration requirements.
* Uncertainty and risk.
* Testing effort.

Story points represent relative complexity and effort rather than development hours.

## Proposed Sprint 1 Story Point Estimates

| User Story                   | Story Points |
| ---------------------------- | -----------: |
| **US-01: User Registration** |            3 |
| **US-02: User Login**        |            3 |
| **US-03: Add Medication**    |            5 |
| **US-04: View Medications**  |            3 |

**Total Planned Story Points: 14**

> These estimates should be reviewed and agreed upon by the entire development team during Sprint Planning.

---

# Sprint 1 Completion Status

**Sprint Status:** In Progress / Completed *(update according to your actual project status)*

**Stories Planned:** 4

**Stories Completed:** To be updated after Sprint Review.

The Sprint 1 implementation establishes the authentication and core medication management foundation required for the Medication Reminder & Tracker application. The team will use the Sprint Review feedback and Sprint Retrospective outcomes to plan the next development iteration.
