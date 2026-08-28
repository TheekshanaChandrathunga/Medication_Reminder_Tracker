# System Architecture

## Medication Reminder & Tracker App

The Medication Reminder & Tracker App is a mobile-first application developed using
**Flutter** and **Firebase**. The architecture follows a layered client-cloud
architecture in which the Flutter application provides the user interface and
application logic, while Firebase provides authentication, cloud data storage,
file storage, push notifications, and backend services.

---

## 1. Architecture Overview

```mermaid
flowchart TB

    %% =========================================================
    %% USERS
    %% =========================================================

    subgraph ACTORS["SYSTEM USERS"]
        PATIENT["Patient"]
        CAREGIVER["Caregiver"]
    end


    %% =========================================================
    %% USER DEVICE / FLUTTER
    %% =========================================================

    subgraph DEVICE["USER DEVICE"]

        subgraph FLUTTER["FLUTTER MOBILE APPLICATION"]

            subgraph PRESENTATION["PRESENTATION LAYER"]
                SPLASH["Splash Screen"]
                AUTH_UI["Login / Register"]
                HOME_UI["Home / Dashboard"]
                MED_UI["Medication Management"]
                SCHEDULE_UI["Medication Schedule"]
                HISTORY_UI["Medication History"]
                REPORT_UI["Reports"]
                SETTINGS_UI["Settings"]
                CAREGIVER_UI["Caregiver Dashboard"]
            end

            subgraph APPLICATION["APPLICATION LAYER"]
                AUTH_SERVICE["Authentication Service"]
                MED_SERVICE["Medication Service"]
                SCHEDULE_SERVICE["Schedule Service"]
                HISTORY_SERVICE["History / Adherence Service"]
                REPORT_SERVICE["Report Service"]
                CAREGIVER_SERVICE["Caregiver Service"]
                NOTIFICATION_SERVICE["Notification Service"]
                SYNC_SERVICE["Offline Sync Service"]
            end

            subgraph LOCAL["LOCAL DATA / CACHE"]
                LOCAL_DB[("Local Cache")]
                PENDING_QUEUE[("Pending Offline Changes")]
            end

            subgraph FIREBASE_SDK["FIREBASE SDK LAYER"]
                AUTH_SDK["Firebase Authentication SDK"]
                FIRESTORE_SDK["Cloud Firestore SDK"]
                STORAGE_SDK["Firebase Storage SDK"]
                MESSAGING_SDK["Firebase Messaging SDK"]
            end

        end
    end


    %% =========================================================
    %% FIREBASE CLOUD
    %% =========================================================

    subgraph CLOUD["FIREBASE CLOUD"]

        FIREBASE_AUTH["Firebase Authentication"]

        subgraph FIRESTORE["CLOUD FIRESTORE"]

            USERS[("Users")]

            MEDICATIONS[("Medications")]

            SCHEDULES[("Medication Schedules")]

            HISTORY[("Medication History")]

            CAREGIVER_REL[("Caregiver Relationships")]

        end

        STORAGE["Firebase Storage"]

        FUNCTIONS["Firebase Cloud Functions"]

        FCM["Firebase Cloud Messaging"]

        HOSTING["Firebase Hosting"]
    end


    %% =========================================================
    %% USER INTERACTION
    %% =========================================================

    PATIENT --> AUTH_UI
    PATIENT --> HOME_UI
    PATIENT --> MED_UI
    PATIENT --> SCHEDULE_UI
    PATIENT --> HISTORY_UI
    PATIENT --> REPORT_UI
    PATIENT --> SETTINGS_UI

    CAREGIVER --> AUTH_UI
    CAREGIVER --> CAREGIVER_UI


    %% =========================================================
    %% PRESENTATION → APPLICATION
    %% =========================================================

    AUTH_UI --> AUTH_SERVICE

    HOME_UI --> MED_SERVICE
    HOME_UI --> SCHEDULE_SERVICE

    MED_UI --> MED_SERVICE

    SCHEDULE_UI --> SCHEDULE_SERVICE

    HISTORY_UI --> HISTORY_SERVICE

    REPORT_UI --> REPORT_SERVICE

    SETTINGS_UI --> AUTH_SERVICE
    SETTINGS_UI --> NOTIFICATION_SERVICE

    CAREGIVER_UI --> CAREGIVER_SERVICE


    %% =========================================================
    %% APPLICATION → LOCAL CACHE
    %% =========================================================

    MED_SERVICE --> LOCAL_DB
    SCHEDULE_SERVICE --> LOCAL_DB
    HISTORY_SERVICE --> LOCAL_DB

    MED_SERVICE --> PENDING_QUEUE
    SCHEDULE_SERVICE --> PENDING_QUEUE
    HISTORY_SERVICE --> PENDING_QUEUE


    %% =========================================================
    %% APPLICATION → FIREBASE SDK
    %% =========================================================

    AUTH_SERVICE --> AUTH_SDK

    MED_SERVICE --> FIRESTORE_SDK
    SCHEDULE_SERVICE --> FIRESTORE_SDK
    HISTORY_SERVICE --> FIRESTORE_SDK
    CAREGIVER_SERVICE --> FIRESTORE_SDK

    REPORT_SERVICE --> FIRESTORE_SDK
    REPORT_SERVICE --> STORAGE_SDK

    NOTIFICATION_SERVICE --> MESSAGING_SDK


    %% =========================================================
    %% OFFLINE SYNCHRONIZATION
    %% =========================================================

    LOCAL_DB --> SYNC_SERVICE

    PENDING_QUEUE --> SYNC_SERVICE

    SYNC_SERVICE -->|"Internet Restored"| FIRESTORE_SDK

    FIRESTORE_SDK -->|"Synced Data"| LOCAL_DB


    %% =========================================================
    %% FIREBASE AUTHENTICATION
    %% =========================================================

    AUTH_SDK -->|"Secure Authentication"| FIREBASE_AUTH

    FIREBASE_AUTH -->|"Authenticated User"| AUTH_SERVICE


    %% =========================================================
    %% FIRESTORE CONNECTION
    %% =========================================================

    FIRESTORE_SDK -->|"HTTPS / Firebase SDK"| FIRESTORE


    %% =========================================================
    %% FIRESTORE DATA RELATIONSHIPS
    %% =========================================================

    USERS --> MEDICATIONS

    MEDICATIONS --> SCHEDULES

    USERS --> HISTORY

    MEDICATIONS --> HISTORY

    USERS --> CAREGIVER_REL


    %% =========================================================
    %% FILE STORAGE
    %% =========================================================

    STORAGE_SDK -->|"Upload / Download"| STORAGE

    STORAGE -->|"Medication Images / Report Files"| REPORT_SERVICE


    %% =========================================================
    %% SERVER-SIDE PROCESSING
    %% =========================================================

    SCHEDULES -->|"Scheduled Dose Data"| FUNCTIONS

    MEDICATIONS -->|"Medication Information"| FUNCTIONS

    HISTORY -->|"Dose / Adherence Data"| FUNCTIONS

    FUNCTIONS -->|"Reminder Trigger"| FCM

    FUNCTIONS -->|"Adherence Processing"| HISTORY


    %% =========================================================
    %% PUSH NOTIFICATIONS
    %% =========================================================

    FCM -->|"Push Notification"| MESSAGING_SDK

    MESSAGING_SDK --> NOTIFICATION_SERVICE

    NOTIFICATION_SERVICE -->|"Medication Reminder"| PATIENT


    %% =========================================================
    %% CAREGIVER MONITORING
    %% =========================================================

    CAREGIVER_REL --> CAREGIVER_SERVICE

    HISTORY --> CAREGIVER_SERVICE

    SCHEDULES --> CAREGIVER_SERVICE

    CAREGIVER_SERVICE --> CAREGIVER_UI


    %% =========================================================
    %% HOSTING
    %% =========================================================

    HOSTING -.->|"Web / Hosting Support"| DEVICE


    %% =========================================================
    %% STYLING
    %% =========================================================

    classDef actor fill:#E8F5E9,stroke:#2E7D32,stroke-width:2px,color:#000;

    classDef presentation fill:#E3F2FD,stroke:#1565C0,stroke-width:2px,color:#000;

    classDef application fill:#FFF3E0,stroke:#EF6C00,stroke-width:2px,color:#000;

    classDef local fill:#F3E5F5,stroke:#6A1B9A,stroke-width:2px,color:#000;

    classDef firebase fill:#FFF8E1,stroke:#F57F17,stroke-width:2px,color:#000;

    classDef database fill:#EDE7F6,stroke:#4527A0,stroke-width:2px,color:#000;

    classDef notification fill:#FCE4EC,stroke:#C2185B,stroke-width:2px,color:#000;


    class PATIENT,CAREGIVER actor;

    class SPLASH,AUTH_UI,HOME_UI,MED_UI,SCHEDULE_UI,HISTORY_UI,REPORT_UI,SETTINGS_UI,CAREGIVER_UI presentation;

    class AUTH_SERVICE,MED_SERVICE,SCHEDULE_SERVICE,HISTORY_SERVICE,REPORT_SERVICE,CAREGIVER_SERVICE,NOTIFICATION_SERVICE,SYNC_SERVICE application;

    class LOCAL_DB,PENDING_QUEUE local;

    class AUTH_SDK,FIRESTORE_SDK,STORAGE_SDK,MESSAGING_SDK firebase;

    class FIREBASE_AUTH,STORAGE,FUNCTIONS,HOSTING firebase;

    class USERS,MEDICATIONS,SCHEDULES,HISTORY,CAREGIVER_REL database;

    class FCM notification;
```

---

# 2. Architecture Layers

```mermaid
flowchart TB

    USER["Patient / Caregiver"]

    subgraph PRESENTATION["Presentation Layer"]
        UI["Flutter UI<br/>Screens / Widgets"]
    end

    subgraph APPLICATION["Application Layer"]
        SERVICES["Application Services<br/>Authentication<br/>Medication<br/>Schedule<br/>History<br/>Reports<br/>Caregiver"]
    end

    subgraph DATA["Data Layer"]
        REPOSITORY["Repository / Data Access"]
        CACHE[("Local Cache")]
    end

    subgraph FIREBASE["Firebase Services"]
        AUTH["Firebase Authentication"]
        DB[("Cloud Firestore")]
        STORAGE["Firebase Storage"]
        FCM["Firebase Cloud Messaging"]
    end

    USER --> UI
    UI --> SERVICES
    SERVICES --> REPOSITORY

    REPOSITORY --> CACHE

    REPOSITORY --> AUTH
    REPOSITORY --> DB
    REPOSITORY --> STORAGE
    REPOSITORY --> FCM
```

---

# 3. Authentication Flow

```mermaid
sequenceDiagram

    actor User
    participant Flutter as Flutter App
    participant Auth as Firebase Authentication
    participant Firestore as Cloud Firestore

    User->>Flutter: Enter email and password

    Flutter->>Auth: Register / Login request

    Auth-->>Flutter: Authentication result

    alt New User
        Flutter->>Firestore: Create user profile
        Firestore-->>Flutter: Profile created
    else Existing User
        Auth-->>Flutter: Authenticated session
    end

    Flutter-->>User: Open Dashboard
```

---

# 4. Medication Management Flow

```mermaid
sequenceDiagram

    actor Patient
    participant Flutter as Flutter App
    participant Service as Medication Service
    participant Firestore as Cloud Firestore
    participant Storage as Firebase Storage

    Patient->>Flutter: Open Add Medication

    Patient->>Flutter: Enter medication details

    opt Medication photo
        Flutter->>Storage: Upload medication image
        Storage-->>Flutter: Image URL
    end

    Flutter->>Service: Save medication

    Service->>Firestore: Create medication document

    Firestore-->>Service: Medication saved

    Service-->>Flutter: Updated medication

    Flutter-->>Patient: Display medication
```

---

# 5. Medication Reminder Flow

```mermaid
sequenceDiagram

    participant Firestore as Cloud Firestore
    participant Function as Firebase Cloud Function
    participant FCM as Firebase Cloud Messaging
    participant App as Flutter App
    actor Patient

    Firestore->>Function: Read scheduled medication

    Function->>Function: Check current date/time

    Function->>FCM: Send medication reminder

    FCM->>App: Push notification

    App->>Patient: "Time to take your medication"

    Patient->>App: Open reminder

    App->>Firestore: Update dose status

    Firestore-->>App: Status updated
```

> **Implementation note:** The Cloud Function shown above should only be considered part of the implemented architecture if the team has actually configured Firebase Cloud Functions for scheduled processing.

---

# 6. Taken / Missed Dose Flow

```mermaid
flowchart LR

    USER["Patient"]

    APP["Flutter App"]

    SCHEDULE["Medication Schedule"]

    STATUS{"Dose Status"}

    TAKEN["Taken"]

    MISSED["Missed"]

    HISTORY["Medication History"]

    ADHERENCE["Adherence Calculation"]

    USER --> APP

    APP --> SCHEDULE

    SCHEDULE --> STATUS

    STATUS -->|"Taken"| TAKEN

    STATUS -->|"Missed"| MISSED

    TAKEN --> HISTORY

    MISSED --> HISTORY

    HISTORY --> ADHERENCE

    ADHERENCE --> APP
```

---

# 7. Offline Synchronization Flow

The application is required to support offline access and synchronize changes
when connectivity is restored.

```mermaid
flowchart LR

    USER["User"]

    APP["Flutter Application"]

    ONLINE{"Internet Available?"}

    LOCAL[("Local Cache")]

    QUEUE[("Pending Changes")]

    FIRESTORE[("Cloud Firestore")]

    SYNC["Synchronization"]

    USER --> APP

    APP --> ONLINE

    ONLINE -->|"No"| LOCAL

    LOCAL --> QUEUE

    QUEUE --> SYNC

    ONLINE -->|"Yes"| FIRESTORE

    SYNC -->|"Connection Restored"| FIRESTORE

    FIRESTORE -->|"Latest Data"| SYNC

    SYNC --> LOCAL

    LOCAL --> APP

    APP --> USER
```

---

# 8. Caregiver Monitoring Flow

```mermaid
flowchart LR

    CAREGIVER["Caregiver"]

    APP["Flutter Caregiver Dashboard"]

    SERVICE["Caregiver Service"]

    RELATIONSHIP[("Caregiver Relationships")]

    SCHEDULE[("Medication Schedules")]

    HISTORY[("Medication History")]

    PATIENT["Patient Medication Data"]

    CAREGIVER --> APP

    APP --> SERVICE

    SERVICE --> RELATIONSHIP

    SERVICE --> SCHEDULE

    SERVICE --> HISTORY

    RELATIONSHIP --> PATIENT

    SCHEDULE --> PATIENT

    HISTORY --> PATIENT

    PATIENT --> APP

    APP --> CAREGIVER
```

---

# 9. Report Generation Flow

```mermaid
sequenceDiagram

    actor User
    participant App as Flutter App
    participant Service as Report Service
    participant DB as Cloud Firestore
    participant Storage as Firebase Storage

    User->>App: Request report

    App->>Service: Generate report

    Service->>DB: Retrieve medication history

    DB-->>Service: Medication / adherence data

    Service->>Service: Generate PDF / report

    Service->>Storage: Store report file

    Storage-->>Service: Report file URL

    Service-->>App: Report available

    App-->>User: View / Download / Share report
```

---

# 10. Data Model

The main persistent entities are:

```mermaid
erDiagram

    USER ||--o{ MEDICATION : owns

    MEDICATION ||--o{ MEDICATION_SCHEDULE : has

    USER ||--o{ DOSE_HISTORY : records

    MEDICATION ||--o{ DOSE_HISTORY : generates

    USER ||--o{ CAREGIVER_RELATIONSHIP : caregiver

    USER ||--o{ CAREGIVER_RELATIONSHIP : patient


    USER {
        string id PK
        string email
        string full_name
        string role
        string language
        string timezone
        boolean notification_enabled
        boolean email_enabled
        datetime created_at
        datetime updated_at
    }

    MEDICATION {
        string id PK
        string user_id FK
        string name
        string dosage
        string category
        string frequency
        string times
        string days
        string take_with
        string special_instructions
        date start_date
        date end_date
        int total_quantity
        int remaining_quantity
        int low_stock_threshold
        string image_url
        boolean is_active
        datetime created_at
        datetime updated_at
    }

    MEDICATION_SCHEDULE {
        string id PK
        string medication_id FK
        time scheduled_time
        int day_of_week
        boolean is_taken
        datetime taken_at
        string status
        string missed_reason
        string notes
        datetime created_at
        datetime updated_at
    }

    DOSE_HISTORY {
        string id PK
        string user_id FK
        string medication_id FK
        string action
        datetime timestamp
        string ip_address
        string user_agent
    }

    CAREGIVER_RELATIONSHIP {
        string id PK
        string caregiver_id FK
        string patient_id FK
        string relationship
        string permission_level
        datetime created_at
        datetime updated_at
    }
```

---

# 11. Technology Stack

| Layer | Technology |
|---|---|
| Mobile Application | Flutter |
| Programming Language | Dart |
| Authentication | Firebase Authentication |
| Database | Cloud Firestore |
| Push Notifications | Firebase Cloud Messaging |
| File Storage | Firebase Storage |
| Backend Services | Firebase |
| Server-side Processing | Firebase Cloud Functions |
| Hosting | Firebase Hosting |
| Local Data / Offline Support | Flutter local cache + Firestore offline capabilities |

---

# 12. Main System Flow

```mermaid
flowchart TD

    START([Application Start])

    AUTH{"Authenticated?"}

    LOGIN["Login / Register"]

    DASHBOARD["Dashboard"]

    MED["Medication Management"]

    SCHEDULE["Medication Schedule"]

    REMINDER["Medication Reminder"]

    ACTION{"User Action"}

    TAKEN["Mark Taken"]

    MISSED["Mark Missed"]

    HISTORY["Medication History"]

    REPORT["Generate Report"]

    CAREGIVER["Caregiver Monitoring"]

    FIRESTORE[("Cloud Firestore")]

    FCM["Firebase Cloud Messaging"]

    END([End])


    START --> AUTH

    AUTH -->|"No"| LOGIN

    LOGIN --> DASHBOARD

    AUTH -->|"Yes"| DASHBOARD

    DASHBOARD --> MED

    DASHBOARD --> SCHEDULE

    MED --> FIRESTORE

    SCHEDULE --> FIRESTORE

    SCHEDULE --> REMINDER

    REMINDER --> FCM

    FCM --> ACTION

    ACTION -->|"Taken"| TAKEN

    ACTION -->|"Missed"| MISSED

    TAKEN --> HISTORY

    MISSED --> HISTORY

    HISTORY --> FIRESTORE

    DASHBOARD --> REPORT

    REPORT --> FIRESTORE

    DASHBOARD --> CAREGIVER

    CAREGIVER --> FIRESTORE

    HISTORY --> END
```

---

# 13. Security Boundary

```mermaid
flowchart TB

    subgraph CLIENT["TRUST BOUNDARY: USER DEVICE"]
        APP["Flutter Application"]

        AUTH_SDK["Firebase Authentication SDK"]

        FIRESTORE_SDK["Cloud Firestore SDK"]

        STORAGE_SDK["Firebase Storage SDK"]

        MESSAGING_SDK["Firebase Messaging SDK"]
    end

    subgraph CLOUD["TRUST BOUNDARY: FIREBASE CLOUD"]

        AUTH["Firebase Authentication"]

        RULES["Firebase Security Rules"]

        DB[("Cloud Firestore")]

        STORAGE["Firebase Storage"]

        FCM["Firebase Cloud Messaging"]
    end

    APP --> AUTH_SDK
    APP --> FIRESTORE_SDK
    APP --> STORAGE_SDK
    APP --> MESSAGING_SDK

    AUTH_SDK -->|"Encrypted Connection"| AUTH

    FIRESTORE_SDK -->|"Encrypted Connection"| RULES

    RULES --> DB

    STORAGE_SDK -->|"Authenticated Access"| STORAGE

    FCM --> MESSAGING_SDK
```

---

## Architecture Summary

The system uses **Flutter as the client application** and **Firebase as the cloud backend**. Firebase Authentication manages user authentication, Cloud Firestore stores application data, Firebase Storage stores files such as medication images and generated reports, and Firebase Cloud Messaging provides push notifications.

The Flutter application is organized into presentation, application, and data-access layers. Medication and schedule data can be cached locally to support intermittent connectivity, while synchronization keeps local data consistent with Cloud Firestore when connectivity is restored.

The architecture supports the major system modules: authentication, medication management, medication scheduling, reminders, adherence tracking, history, reporting, and caregiver monitoring.
