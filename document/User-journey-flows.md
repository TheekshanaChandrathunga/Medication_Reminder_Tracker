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
    class M external; ```


