# Architecture Overview

Personal Finance Tracker follows **Clean Architecture with SwiftUI ergonomics** — a pragmatic approach that balances separation of concerns with SwiftUI's reactive nature.

## Folder Structure

```
App
├── App.swift
├── AppContainer.swift                # Dependency Injection root
│
├── Core                              # App-wide infrastructure
│   ├── Config
│   │   └── AppConfig.swift
│   ├── Network
│   │   ├── APIClient.swift
│   │   └── NetworkError.swift
│   └── Utils
│       └── Logger.swift
│
├── Domain                            # Business rules (pure Swift)
│   └── [Feature]
│       ├── Models
│       │   └── [Model].swift
│       ├── Repositories
│       │   └── [Feature]Repository.swift
│       └── UseCases
│           └── [Action][Feature]UseCase.swift
│
├── Data                              # Data sources & mapping
│   └── [Feature]
│       ├── DTOs
│       │   └── [Model]DTO.swift
│       ├── Remote
│       │   └── [Feature]API.swift
│       └── Services
│           └── [Feature]Service.swift
│
├── Presentation                      # SwiftUI layer
│   ├── [Feature]
│   │   ├── [Feature]View.swift
│   │   ├── [Feature]ViewModel.swift
│   │   ├── [Feature]State.swift
│   │   └── Components
│   │       └── [Feature]Row.swift
│   │
│   ├── Components                    # Shared UI components
│   │   ├── AppButton.swift
│   │   ├── LoadingView.swift
│   │   └── ErrorView.swift
│   │
│   └── Navigation
│       └── AppRouter.swift
│
└── Resources
    └── Assets.xcassets
```

## Layer Responsibilities

### 1. Presentation Layer (`Presentation/`)

**Purpose:** Show data and react to user input.

| Component | Responsibility |
|-----------|----------------|
| View | Renders UI, observes state, sends user intent |
| ViewModel | Manages state, coordinates use cases, publishes updates |
| State | Enum representing loading/success/error states |
| Components | Reusable, stateless UI building blocks |

**Rules:**
- Views observe `@Published` state from ViewModels
- Views never contain business logic
- Views never call APIs directly

### 2. Domain Layer (`Domain/`)

**Purpose:** Business rules that survive UI and API changes.

| Component | Responsibility |
|-----------|----------------|
| Models | Pure Swift entities representing business concepts |
| Repositories | Protocols defining data access contracts |
| UseCases | Single-purpose business operations |

**Rules:**
- Pure Swift only (no SwiftUI, no URLSession, no frameworks)
- Repository protocols live here, implementations live in Data
- UseCases are optional for simple CRUD, mandatory for complex logic

### 3. Data Layer (`Data/`)

**Purpose:** Talk to the outside world and clean the mess.

| Component | Responsibility |
|-----------|----------------|
| DTOs | API-shaped data structures (Codable) |
| API | Endpoint definitions and network calls |
| Services | Repository implementations, DTO → Domain mapping |

**Rules:**
- All API responses decode into DTOs first
- DTOs are mapped to Domain models before leaving this layer
- Services implement Repository protocols from Domain

### 4. Core Layer (`Core/`)

**Purpose:** App-wide configuration and infrastructure.

| Component | Responsibility |
|-----------|----------------|
| Config | Environment settings, feature flags |
| Network | HTTP client, error types, interceptors |
| Utils | Logging, extensions, helpers |

## Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  ┌──────────┐    ┌─────────────┐    ┌──────────────┐       │
│  │   View   │───▶│  ViewModel  │───▶│    State     │       │
│  └──────────┘    └─────────────┘    └──────────────┘       │
│                         │                                    │
└─────────────────────────┼────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                            │
│  ┌──────────────┐    ┌────────────────────┐                 │
│  │   UseCase    │───▶│ Repository Protocol│                 │
│  └──────────────┘    └────────────────────┘                 │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                             │
│  ┌──────────────┐    ┌───────┐    ┌──────────────────┐     │
│  │   Service    │───▶│  API  │───▶│ DTO → Domain Map │     │
│  └──────────────┘    └───────┘    └──────────────────┘     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Key principle:** Dependencies flow INWARD only.

- Presentation depends on Domain
- Data depends on Domain
- Domain depends on nothing

## Dependency Injection

We use a simple `AppContainer` pattern with SwiftUI's `@EnvironmentObject`.

```swift
final class AppContainer: ObservableObject {
    // Repositories
    let transactionsRepository: TransactionsRepository

    // Use Cases
    let getTransactionsUseCase: GetTransactionsUseCase
    let addTransactionUseCase: AddTransactionUseCase

    init() {
        let api = TransactionsAPI()
        let service = TransactionsService(api: api)
        self.transactionsRepository = service
        self.getTransactionsUseCase = GetTransactionsUseCase(repository: service)
        self.addTransactionUseCase = AddTransactionUseCase(repository: service)
    }
}
```

Injected at app root:

```swift
@main
struct PersonalFinanceTrackerApp: App {
    let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(container)
        }
    }
}
```

## State Management

Each feature uses a state enum for clear, exhaustive state handling:

```swift
enum TransactionsState {
    case idle
    case loading
    case success([Transaction])
    case error(Error)
}
```

ViewModels publish state changes:

```swift
@MainActor
final class TransactionsViewModel: ObservableObject {
    @Published private(set) var state: TransactionsState = .idle

    func loadTransactions() async {
        state = .loading
        do {
            let transactions = try await useCase.execute()
            state = .success(transactions)
        } catch {
            state = .error(error)
        }
    }
}
```

## Testing Strategy

| Layer | What to Test | How |
|-------|--------------|-----|
| Domain | UseCases, business logic | Unit tests with mock repositories |
| Data | Services, mapping | Unit tests with mock API responses |
| Presentation | ViewModels | Unit tests with mock use cases |
| UI | Views | SwiftUI previews, snapshot tests (optional) |

## When to Skip UseCases

UseCases are **optional** for simple operations:

**Skip UseCase when:**
- Simple CRUD with no business logic
- Direct pass-through from ViewModel to Repository

**Use UseCase when:**
- Combining multiple repository calls
- Business validation or transformation
- Logic that might be reused across ViewModels
- Complex operations that benefit from isolation
