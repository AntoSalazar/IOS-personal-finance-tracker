# Personal Finance Tracker

A native iOS application built with **SwiftUI** following **Clean Architecture** principles to help users manage and track their personal finances.

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%2017+-blue.svg)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-green.svg)

## ✨ Features

- **User Authentication** - Secure login and registration system
- **Modern UI** - Beautiful SwiftUI interface with custom theming
- **Clean Architecture** - Well-structured, maintainable, and testable codebase
- **Reactive State Management** - Powered by SwiftUI's `@Observable` and `@Published` patterns
- **Dependency Injection** - Modular design using the AppContainer pattern

## 🏗️ Architecture

This project follows **Clean Architecture with SwiftUI ergonomics**, organizing code into distinct layers:

```
personal-finance-tracker/
├── Core/                    # App-wide infrastructure
│   ├── Config/             # Environment settings, feature flags
│   ├── Network/            # HTTP client, error handling
│   └── Utils/              # Logging, extensions, helpers
│
├── Domain/                  # Business rules (pure Swift)
│   └── [Feature]/
│       ├── Models/         # Business entities
│       ├── Repositories/   # Data access protocols
│       └── UseCases/       # Business operations
│
├── Data/                    # Data sources & mapping
│   └── [Feature]/
│       ├── DTOs/           # API data structures
│       ├── Remote/         # Network calls
│       └── Services/       # Repository implementations
│
├── Presentation/            # SwiftUI layer
│   └── [Feature]/
│       ├── Views/          # SwiftUI Views
│       ├── ViewModels/     # State management
│       └── Components/     # Reusable UI components
│
└── Resources/
    └── Assets.xcassets     # Colors, images, assets
```

### Layer Responsibilities

| Layer | Purpose |
|-------|---------|
| **Presentation** | UI rendering, user interaction, state observation |
| **Domain** | Business logic, models, repository contracts |
| **Data** | API communication, data mapping, persistence |
| **Core** | Configuration, networking, utilities |

### Data Flow

```
View → ViewModel → UseCase → Repository (Protocol) → Service → API
                                    ↑
                              Domain Layer
```

**Key Principle:** Dependencies flow inward only. Domain depends on nothing.

## 🎨 Design System

The app includes a comprehensive design system with:

- **Color Palette**: Primary, Secondary, Accent, Destructive, and Muted colors
- **Chart Colors**: 5 chart-specific colors for data visualization
- **Dark Mode Support**: Full light and dark mode compatibility
- **Reusable Components**: Buttons, inputs, loading states, error views

## 🚀 Getting Started

### Prerequisites

- **Xcode 15.0+**
- **iOS 17.0+** (deployment target)
- **Swift 5.9+**

### Installation

1. Clone the repository:
   ```bash
   git clone git@github.com:AntoSalazar/IOS-personal-finance-tracker.git
   ```

2. Open the project in Xcode:
   ```bash
   cd IOS-personal-finance-tracker
   open personal-finance-tracker.xcodeproj
   ```

3. Build and run the project (⌘ + R)

## 📚 Documentation

- [Architecture Overview](docs/ARCHITECTURE.md) - Detailed architecture documentation
- [Feature Development Guide](docs/FEATURE_DEVELOPMENT_GUIDE.md) - How to add new features

## 🧪 Testing Strategy

| Layer | What to Test | How |
|-------|--------------|-----|
| Domain | UseCases, business logic | Unit tests with mock repositories |
| Data | Services, mapping | Unit tests with mock API responses |
| Presentation | ViewModels | Unit tests with mock use cases |
| UI | Views | SwiftUI previews, snapshot tests |

## 🛠️ Tech Stack

- **SwiftUI** - Declarative UI framework
- **Swift Concurrency** - async/await for asynchronous operations
- **Combine** - Reactive programming (where needed)
- **Clean Architecture** - Separation of concerns

## 📁 Project Structure

```
.
├── personal-finance-tracker/          # Main app source code
├── personal-finance-tracker.xcodeproj # Xcode project file
└── docs/                              # Documentation
    ├── ARCHITECTURE.md
    └── FEATURE_DEVELOPMENT_GUIDE.md
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made with ❤️ using SwiftUI
</p>
