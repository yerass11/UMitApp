# Contributing to UMitApp

Thank you for considering contributing to UMitApp!  
We welcome improvements in code, documentation, testing, and design.

## How to Contribute

### 1. Fork the repository
https://github.com/yerass11/UMitApp


### 2. Create a feature branch
git checkout -b feature/IOS-[number-of-feature(check hierarchy)]


### 3. Commit your changes
Follow clean commit messages:
[feat]: add appointment booking screen
[fix]: correct pharmacy API request
[docs]: update installation guide


### 4. Submit a Pull Request
Please describe:
- What you changed  
- Why the change is needed  
- How to test it  

## Code Style Guidelines
- Swift code must follow SwiftLint rules (if enabled)
- MVVM architecture should be preserved  
- UI components must support both light & dark mode  
- Networking must use async/await or structured concurrency  
- Sensitive data must not be hard-coded

## Reporting Issues
Use GitHub Issues and include:
- Steps to reproduce  
- Expected behavior  
- Actual behavior  
- Device/iOS version  

## Development Requirements
- Xcode latest version  
- iOS 15+  
- Swift 5.5+  
- Django backend configured and available  
