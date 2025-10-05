# Cribe App Dev Helper

Simple documentation about the development helper system in the Cribe Flutter app - what it does and how developers use it.

## 🛠️ Dev Helper Overview

The **Dev Helper** system provides development tools that only appear in debug mode. It helps developers test, configure, and preview the app during development.

### **Main Components:**
- **DevHelperWrapper** - Adds a floating dev button to any screen
- **DevSettingsModal** - Main modal with development tools  
- **FeatureFlagsView** - Configure app settings and feature flags
- **StorybookView** - Preview UI components and screens in isolation

## 🚀 Dev Helper Flow

```mermaid
flowchart TD
    A[App in Debug Mode] --> B[DevHelperWrapper Wraps Screens]
    B --> C[Floating Dev Button Appears]
    C --> D{User Taps Dev Button?}
    D -->|No| E[Continue Using App Normally]
    D -->|Yes| F[Open DevSettingsModal]
    
    F --> G{Which Tab?}
    G -->|Feature Flags| H[FeatureFlagsView]
    G -->|Storybook| I[StorybookView]
    
    H --> J[Configure Settings]
    J --> K[Changes Applied Live]
    K --> L[Close Modal]
    
    I --> M{Component or Screen?}
    M -->|Component| N[View Component Variants]
    M -->|Screen| O[Preview Screen with Fake Data]
    
    N --> P[Test Different States]
    O --> P
    P --> L
    L --> E
```

## 🎛️ Feature Flags View

**Purpose**: Configure app settings and feature flags in real-time

### **What it shows:**
- Default email/password fields for quick login
- API endpoint override field
- Log level dropdown (Debug, Info, Warning, Error, None)
- Boolean feature flag toggle
- A/B test variant selector (A or B)
- Reset to defaults button

### **What it does:**
```mermaid
flowchart TD
    A[FeatureFlagsView Opens] --> B[Load Current Settings]
    B --> C[Display Configuration Options]
    
    C --> D{User Changes Setting?}
    D -->|No| E[Wait for Input]
    D -->|Yes| F[Update Setting Immediately]
    
    F --> G[Notify App Components]
    G --> H[Settings Take Effect Live]
    H --> E
    
    E --> I{Reset Button Pressed?}
    I -->|No| D
    I -->|Yes| J[Reset All to Defaults]
    J --> G
```

## 📚 Storybook View

**Purpose**: Preview and test UI components and screens in isolation

### **What it shows:**
Two tabs:
- **Widgets Tab**: List of UI components (buttons, text fields, etc.)
- **Screens Tab**: List of app screens (login, register, home)

### **Component Testing Flow:**
```mermaid
flowchart TD
    A[StorybookView Opens] --> B{Which Tab?}
    B -->|Widgets| C[Show Component List]
    B -->|Screens| D[Show Screen List]
    
    C --> E[User Selects Component]
    E --> F[Show Component Variants]
    F --> G[Display Different States]
    G --> H[Primary, Secondary, Disabled, etc.]
    
    D --> I[User Selects Screen]
    I --> J[Load Screen with Fake Data]
    J --> K[Preview Screen Isolated]
    
    H --> L[Developer Tests Visually]
    K --> L
    L --> M[Back to List]
```

### **Available Components:**
- **StyledButton**: Primary, secondary, danger, loading, disabled states
- **StyledText**: All text variants (headline, title, body, etc.)
- **StyledTextField**: Various input types with icons and validation
- **StyledTextButton**: Simple text buttons
- **StyledSwitch**: Toggle switches with labels
- **StyledDropdown**: Dropdown selectors

### **Available Screens:**
- **LoginScreen**: With fake login view model
- **RegisterScreen**: With fake register view model  
- **HomeScreen**: With fake home view model

## 🎯 Dev Helper Wrapper

**Purpose**: Provides access to dev tools from any screen

### **What it does:**
```mermaid
flowchart TD
    A[Screen Loads] --> B{Debug Mode?}
    B -->|No| C[Show Normal Screen]
    B -->|Yes| D[Wrap with DevHelperWrapper]
    
    D --> E[Add Floating Dev Button]
    E --> F[Position Button on Right Side]
    F --> G[Make Button Draggable]
    
    G --> H{User Drags Button?}
    H -->|Yes| I[Update Button Position]
    H -->|No| J{User Taps Button?}
    
    I --> H
    J -->|No| K[Wait for Interaction]
    J -->|Yes| L[Open DevSettingsModal]
    
    K --> H
    L --> M[Show Development Tools]
```

## 🔧 Key Features

### **Debug Mode Only**
- Only appears when app is running in debug mode
- Completely hidden in release builds
- No performance impact on production

### **Floating Access Button**
- Draggable circular button with build icon
- Stays within safe areas (avoids notch/navigation)
- Positioned on right side, 2/3 down the screen
- Always accessible from any screen

### **Live Configuration**
- Feature flag changes apply immediately
- No need to restart app to see changes
- Settings persist across app sessions

### **Component Isolation**
- View components without full app context
- Test different states and variants
- Preview screens with fake data
- Useful for UI development and testing

That's it! The dev helper system makes development faster by providing easy access to configuration and component testing tools.