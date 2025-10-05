# Cribe App Authentication Screens

Simple documentation about the authentication screens in the Cribe Flutter app - what they do and how they flow together.

## 🔐 Auth Screens Overview

There are 3 main authentication screens that handle the user's journey:

### **AuthScreen** - The Entry Point
- **Purpose**: Checks if user is already logged in when app starts
- **What it does**: Shows loading spinner while checking for stored tokens
- **Decision**: Routes user to either HomeScreen (if authenticated) or LoginScreen (if not)

### **LoginScreen** - Sign In 
- **Purpose**: Allows existing users to sign in
- **What it shows**: Email field, password field, "Sign In" button, "Sign Up" link
- **Actions**: Validates input, attempts login, navigates to HomeScreen on success

### **RegisterScreen** - Sign Up
- **Purpose**: Allows new users to create an account  
- **What it shows**: First name, last name, email, password, confirm password fields, "Create Account" button
- **Actions**: Validates all fields, creates account, navigates back to LoginScreen on success

## 🚀 Screen Flow

```mermaid
flowchart TD
    A[App Launch] --> B[AuthScreen]
    B --> C{Check Authentication}
    C -->|Has Valid Token| D[HomeScreen]
    C -->|No Token/Invalid| E[LoginScreen]
    
    E --> F{User Action}
    F -->|Enter Credentials & Sign In| G{Valid Login?}
    F -->|Press Sign Up Link| H[RegisterScreen]
    
    G -->|Success| D
    G -->|Failed| I[Show Error Message]
    I --> E
    
    H --> J{User Action}
    J -->|Fill Form & Create Account| K{Valid Registration?}
    J -->|Press Back or Sign In| E
    
    K -->|Success| L[Show Success Message]
    K -->|Failed| M[Show Error Message]
    L --> E
    M --> H
    
    D --> N{User Action}
    N -->|Press Logout| O[Clear Tokens]
    O --> E
```

## 📱 What Each Screen Does

### AuthScreen Process
```mermaid
flowchart TD
    A[AuthScreen Loads] --> B[Show Loading Spinner]
    B --> C[Check Stored Tokens]
    C --> D{Tokens Valid?}
    D -->|Yes| E[Navigate to HomeScreen]
    D -->|No| F[Navigate to LoginScreen]
```

### LoginScreen Process  
```mermaid
flowchart TD
    A[LoginScreen Loads] --> B[Show Login Form]
    B --> C[User Enters Email/Password]
    C --> D[User Presses Sign In]
    D --> E{Form Valid?}
    E -->|No| F[Show Field Errors]
    E -->|Yes| G[Attempt Login]
    G --> H{Login Success?}
    H -->|Yes| I[Navigate to HomeScreen]
    H -->|No| J[Show Error Message]
    F --> C
    J --> C
    
    B --> K[User Presses Sign Up]
    K --> L[Navigate to RegisterScreen]
```

### RegisterScreen Process
```mermaid
flowchart TD
    A[RegisterScreen Loads] --> B[Show Registration Form]
    B --> C[User Fills All Fields]
    C --> D[User Presses Create Account]
    D --> E{Form Valid?}
    E -->|No| F[Show Field Errors]
    E -->|Yes| G[Attempt Registration]
    G --> H{Registration Success?}
    H -->|Yes| I[Navigate to LoginScreen]
    H -->|No| J[Show Error Message]
    F --> C
    J --> C
    
    B --> K[User Presses Back/Sign In]
    K --> L[Navigate to LoginScreen]
```

That's it! The auth screens work together to handle user authentication in a simple, clear flow.