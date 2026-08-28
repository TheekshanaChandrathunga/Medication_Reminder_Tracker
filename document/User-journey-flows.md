## User Journey Flows
### Registration & Account Setup
```mermaid
flowchart TD

    A([Start]) --> B[Open Medication Reminder & Tracker App]

    B --> C[Select Register]

    C --> D[Enter Email and Password]

    D --> E{Are the registration details valid?}

    E -- No --> F[Display Registration Error]
    F --> D

    E -- Yes --> G[Create User Account]

    G --> H[Account Successfully Created]

    H --> I[Manage Profile]

    I --> J[Enter / Update Profile Details]

    J --> K[Select Language]

    K --> L{Choose Language}

    L -- Sinhala --> M[Set Interface Language to Sinhala]
    L -- English --> N[Set Interface Language to English]

    M --> O[Open Home Dashboard]
    N --> O[Open Home Dashboard]

    O --> P([End])


    %% Styling
    classDef startEnd fill:#ffffff,stroke:#222222,stroke-width:2px;
    classDef process fill:#eef5ff,stroke:#2563eb,stroke-width:1.5px;
    classDef decision fill:#fff7ed,stroke:#ea580c,stroke-width:1.5px;

    class A,P startEnd;
    class B,C,D,F,G,H,I,J,M,N,O process;
    class E,L decision;
```

### Login & Password Recovery 
```mermaid
flowchart TD

    A([Start]) --> B[Open Medication Reminder & Tracker App]

    B --> C[Select Login]

    C --> D[Enter Email and Password]

    D --> E{Are the Login Credentials Valid?}

    E -- No --> F[Display Login Error]
    F --> D

    E -- Yes --> G[Authenticate User]

    G --> H[Open Home Dashboard]

    H --> I([End])


    %% Password Recovery Flow

    C --> J[Select Forgot Password]

    J --> K[Enter Registered Email]

    K --> L[Send Password Reset Request]

    L --> M[Email Service Sends Password Reset Email]

    M --> N[Open Password Reset Link]

    N --> O[Enter New Password]

    O --> P[Password Successfully Reset]

    P --> Q[Return to Login]

    Q --> D


    %% Styling

    classDef startEnd fill:#ffffff,stroke:#222222,stroke-width:2px;
    classDef process fill:#eef5ff,stroke:#2563eb,stroke-width:1.5px;
    classDef decision fill:#fff7ed,stroke:#ea580c,stroke-width:1.5px;
    classDef external fill:#f5f5f5,stroke:#555555,stroke-width:1.5px;

    class A,I startEnd;
    class B,C,D,F,G,H,J,K,L,N,O,P,Q process;
    class E decision;
    class M external;
```

### Medication Management
```mermaid
flowchart TD

    A([Start]) --> B[Login]

    B --> C[Open Medication Management]

    C --> D[Select Add Medication]

    D --> E[Enter Medication Details]

    E --> F{Upload Medication Photo?}

    F -- Yes --> G[Upload Medication Photo]
    F -- No --> H[Save Medication]

    G --> H

    H --> I[Medication Added Successfully]

    I --> J[View Medications]

    J --> K[Search / Filter Medications]

    K --> L[Select Medication]

    L --> M{Choose Action}

    M -- Edit --> N[Edit Medication Details]
    N --> O[Save Updated Medication]
    O --> J

    M -- Delete --> P[Delete Medication]
    P --> Q{Confirm Deletion?}

    Q -- No --> J
    Q -- Yes --> R[Medication Deleted Successfully]
    R --> J

    M -- Finish --> S([End])


    %% Styling

    classDef startEnd fill:#ffffff,stroke:#222222,stroke-width:2px;
    classDef process fill:#eef5ff,stroke:#2563eb,stroke-width:1.5px;
    classDef decision fill:#fff7ed,stroke:#ea580c,stroke-width:1.5px;

    class A,S startEnd;
    class B,C,D,E,G,H,I,J,K,L,N,O,P,R process;
    class F,M,Q decision;
```

### Medication Schedule & Reminder
```mermaid
flowchart TD

    A([Start]) --> B[Login]

    B --> C[View Today's Schedule]

    C --> D[System Checks Medication Schedule]

    D --> E{Is it Medication Time?}

    E -- No --> D

    E -- Yes --> F[Send Push Notification]

    F --> G[Receive Medication Reminder]

    G --> H{What does the Patient do?}

    H -- Take Medication --> I[Take Medication]
    I --> J[Mark Dose as Taken]
    J --> K[Update Medication History]
    K --> L([End])

    H -- Snooze --> M[Select Snooze Duration]
    M --> N{Select 5 / 10 / 15 Minutes}
    N --> O[Wait for Snooze Duration]
    O --> F

    H -- Do Not Respond --> P[Wait 30 Minutes]
    P --> Q[Send Missed Dose Alert]
    Q --> R[Receive Missed Dose Alert]
    R --> S[Mark Dose as Missed]
    S --> K


    %% Refill Reminder Flow

    D --> T{Is Medication Stock Low?}

    T -- Yes --> U[Send Refill Reminder]
    U --> V[Receive Refill Reminder]
    V --> D

    T -- No --> D


    %% Daily Summary Flow

    D --> W{Daily Summary Time?}

    W -- Yes --> X[Send Daily Summary]
    X --> Y[Receive Daily Medication Summary]
    Y --> D

    W -- No --> D


    %% Styling

    classDef startEnd fill:#ffffff,stroke:#222222,stroke-width:2px;
    classDef process fill:#eef5ff,stroke:#2563eb,stroke-width:1.5px;
    classDef decision fill:#fff7ed,stroke:#ea580c,stroke-width:1.5px;
    classDef notification fill:#f5f5f5,stroke:#555555,stroke-width:1.5px;

    class A,L startEnd;
    class B,C,D,F,G,I,J,K,M,O,Q,R,S,U,V,X,Y process;
    class E,H,N,P,T,W decision;
```

### Dose Tracking & Adherence
```mermaid
flowchart TD

    A([Start]) --> B[Open Today's Schedule]

    B --> C[Select Scheduled Medication Dose]

    C --> D{Did the Patient Take the Dose?}

    D -- Yes --> E[Mark Dose as Taken]

    D -- No --> F[Mark Dose as Missed]

    E --> G{Add a Dose Note?}
    F --> G

    G -- Yes --> H[Enter Short Dose Note]
    G -- No --> I[Update Medication History]

    H --> I

    I --> J[View Medication History]

    J --> K[Calculate Adherence Statistics]

    K --> L[View Weekly / Monthly Adherence]

    L --> M([End])


    %% Styling

    classDef startEnd fill:#ffffff,stroke:#222222,stroke-width:2px;
    classDef process fill:#eef5ff,stroke:#2563eb,stroke-width:1.5px;
    classDef decision fill:#fff7ed,stroke:#ea580c,stroke-width:1.5px;

    class A,M startEnd;
    class B,C,E,F,H,I,J,K,L process;
    class D,G decision;
```

### Report Generation & Data Export
```mermaid
flowchart TD

    A([Start]) --> B[Login]

    B --> C[Open Reporting & Data Export]

    C --> D{Select an Action}

    %% PDF REPORT FLOW
    D -- Generate PDF Report --> E[Generate PDF Report]

    E --> F[PDF Report Created]

    F --> G([End])


    %% EMAIL REPORT FLOW
    D -- Email Report --> H[Generate PDF Report]

    H --> I[Enter Recipient Email]

    I --> J[Send Email Report]

    J --> K[Email Service Sends Report]

    K --> L[Report Successfully Emailed]

    L --> G


    %% ADHERENCE CHART FLOW
    D -- View Adherence Chart --> M[Retrieve Adherence Data]

    M --> N[Generate Weekly / Monthly Adherence Chart]

    N --> O[Display Adherence Chart]

    O --> G


    %% CSV EXPORT FLOW
    D -- Export Medication Data --> P[Prepare Medication Data]

    P --> Q[Generate CSV File]

    Q --> R[Export Medication Data]

    R --> G


    %% Styling

    classDef startEnd fill:#ffffff,stroke:#222222,stroke-width:2px;
    classDef process fill:#eef5ff,stroke:#2563eb,stroke-width:1.5px;
    classDef decision fill:#fff7ed,stroke:#ea580c,stroke-width:1.5px;
    classDef external fill:#f5f5f5,stroke:#555555,stroke-width:1.5px;

    class A,G startEnd;
    class B,C,E,F,H,I,J,L,M,N,O,P,Q,R process;
    class D decision;
    class K external;
```

### Caregiver Patient Monitoring
```mermaid
flowchart TD

    A([Start]) --> B[Caregiver Login]

    B --> C{Are Login Credentials Valid?}

    C -- No --> D[Display Login Error]
    D --> B

    C -- Yes --> E[Open Caregiver Dashboard]

    E --> F[View Patient List]

    F --> G[Select Patient]

    G --> H[View Patient Medication Schedule]

    H --> I[View Patient Adherence]

    I --> J[Monitor Patient]

    J --> K{Monitor Another Patient?}

    K -- Yes --> F

    K -- No --> L([End])


    %% Styling

    classDef startEnd fill:#ffffff,stroke:#222222,stroke-width:2px;
    classDef process fill:#eef5ff,stroke:#2563eb,stroke-width:1.5px;
    classDef decision fill:#fff7ed,stroke:#ea580c,stroke-width:1.5px;

    class A,L startEnd;
    class B,D,E,F,G,H,I,J process;
    class C,K decision;
```
