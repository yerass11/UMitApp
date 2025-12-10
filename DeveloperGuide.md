# Developer Guide — UMitApp

This document helps developers understand the architecture and internal structure of UMitApp.

## Architecture Overview
UMitApp uses:
- **SwiftUI + UIKit hybrid UI**
- **MVVM architecture**
- **Firebase Authentication & Firestore**
- **Django REST API for business logic**
- **Stripe iOS SDK for payments**

## Folder Structure
UMitApp/
├── App/
├── Core/
├── Features/
├── Resources/
└── Services/

### MVVM Conventions
- `Model` — pure data objects  
- `ViewModel` — business logic, async API calls, state management  
- `View` — SwiftUI views, no business logic  

### Networking
- Uses URLSession + async/await  
- Endpoints stored in `BackendService`  
- Token handling must follow best practices  

### Firebase
- Authentication (Email, Apple, Google)  
- Push notifications  
- Firestore for chat/messages  

### Stripe Payments
- PaymentIntent created on Django backend  
- iOS handles PaymentSheet presentation

## Testing
- Every ViewModel must have unit tests  
- Use protocol-based dependency injection  
- Network calls must be mocked  
