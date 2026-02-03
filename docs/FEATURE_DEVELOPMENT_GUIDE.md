# Feature Development Guide

Step-by-step guide for implementing new features in Personal Finance Tracker.

## Quick Reference

```
1. Domain  → Models, Repository Protocol, UseCase (if needed)
2. Data    → DTO, API, Service (implements Repository)
3. Present → State, ViewModel, View, Components
4. Wire    → Register in AppContainer
```

## Step-by-Step: Adding a New Feature

We'll use "Transactions" as an example feature.

---

### Step 1: Domain Layer

Start with the business core — no dependencies, pure Swift.

#### 1.1 Create the Domain Model

`Domain/Transactions/Models/Transaction.swift`

```swift
import Foundation

struct Transaction: Identifiable, Equatable {
    let id: UUID
    let amount: Decimal
    let description: String
    let category: TransactionCategory
    let date: Date
    let type: TransactionType
}

enum TransactionType: String, CaseIterable {
    case income
    case expense
}

enum TransactionCategory: String, CaseIterable {
    case food
    case transport
    case entertainment
    case utilities
    case salary
    case other
}
```

#### 1.2 Define the Repository Protocol

`Domain/Transactions/Repositories/TransactionsRepository.swift`

```swift
protocol TransactionsRepository {
    func getTransactions() async throws -> [Transaction]
    func addTransaction(_ transaction: Transaction) async throws
    func deleteTransaction(id: UUID) async throws
}
```

#### 1.3 Create UseCases (if needed)

`Domain/Transactions/UseCases/GetTransactionsUseCase.swift`

```swift
struct GetTransactionsUseCase {
    private let repository: TransactionsRepository

    init(repository: TransactionsRepository) {
        self.repository = repository
    }

    func execute() async throws -> [Transaction] {
        try await repository.getTransactions()
    }
}
```

For complex logic:

`Domain/Transactions/UseCases/GetMonthlyBalanceUseCase.swift`

```swift
struct GetMonthlyBalanceUseCase {
    private let repository: TransactionsRepository

    init(repository: TransactionsRepository) {
        self.repository = repository
    }

    func execute(for month: Date) async throws -> Decimal {
        let transactions = try await repository.getTransactions()
        let calendar = Calendar.current

        return transactions
            .filter { calendar.isDate($0.date, equalTo: month, toGranularity: .month) }
            .reduce(Decimal.zero) { balance, transaction in
                switch transaction.type {
                case .income: return balance + transaction.amount
                case .expense: return balance - transaction.amount
                }
            }
    }
}
```

---

### Step 2: Data Layer

Implement the data access.

#### 2.1 Create the DTO

`Data/Transactions/DTOs/TransactionDTO.swift`

```swift
import Foundation

struct TransactionDTO: Codable {
    let id: String
    let amount: Double
    let description: String
    let category: String
    let date: String
    let type: String
}

extension TransactionDTO {
    func toDomain() -> Transaction? {
        guard let uuid = UUID(uuidString: id),
              let category = TransactionCategory(rawValue: category),
              let type = TransactionType(rawValue: type),
              let date = ISO8601DateFormatter().date(from: date) else {
            return nil
        }

        return Transaction(
            id: uuid,
            amount: Decimal(amount),
            description: description,
            category: category,
            date: date,
            type: type
        )
    }
}

extension Transaction {
    func toDTO() -> TransactionDTO {
        TransactionDTO(
            id: id.uuidString,
            amount: NSDecimalNumber(decimal: amount).doubleValue,
            description: description,
            category: category.rawValue,
            date: ISO8601DateFormatter().string(from: date),
            type: type.rawValue
        )
    }
}
```

#### 2.2 Create the API

`Data/Transactions/Remote/TransactionsAPI.swift`

```swift
import Foundation

final class TransactionsAPI {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchTransactions() async throws -> [TransactionDTO] {
        try await client.request(endpoint: "/transactions")
    }

    func createTransaction(_ dto: TransactionDTO) async throws {
        try await client.post(endpoint: "/transactions", body: dto)
    }

    func deleteTransaction(id: String) async throws {
        try await client.delete(endpoint: "/transactions/\(id)")
    }
}
```

#### 2.3 Create the Service

`Data/Transactions/Services/TransactionsService.swift`

```swift
final class TransactionsService: TransactionsRepository {
    private let api: TransactionsAPI

    init(api: TransactionsAPI) {
        self.api = api
    }

    func getTransactions() async throws -> [Transaction] {
        let dtos = try await api.fetchTransactions()
        return dtos.compactMap { $0.toDomain() }
    }

    func addTransaction(_ transaction: Transaction) async throws {
        try await api.createTransaction(transaction.toDTO())
    }

    func deleteTransaction(id: UUID) async throws {
        try await api.deleteTransaction(id: id.uuidString)
    }
}
```

---

### Step 3: Presentation Layer

Build the UI.

#### 3.1 Define State

`Presentation/Transactions/TransactionsState.swift`

```swift
enum TransactionsState: Equatable {
    case idle
    case loading
    case success([Transaction])
    case error(String)
}
```

#### 3.2 Create the ViewModel

`Presentation/Transactions/TransactionsViewModel.swift`

```swift
import Foundation

@MainActor
final class TransactionsViewModel: ObservableObject {
    @Published private(set) var state: TransactionsState = .idle

    private let getTransactionsUseCase: GetTransactionsUseCase
    private let addTransactionUseCase: AddTransactionUseCase

    init(
        getTransactionsUseCase: GetTransactionsUseCase,
        addTransactionUseCase: AddTransactionUseCase
    ) {
        self.getTransactionsUseCase = getTransactionsUseCase
        self.addTransactionUseCase = addTransactionUseCase
    }

    func loadTransactions() async {
        state = .loading
        do {
            let transactions = try await getTransactionsUseCase.execute()
            state = .success(transactions)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func addTransaction(_ transaction: Transaction) async {
        do {
            try await addTransactionUseCase.execute(transaction)
            await loadTransactions() // Refresh list
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
```

#### 3.3 Create the View

`Presentation/Transactions/TransactionsView.swift`

```swift
import SwiftUI

struct TransactionsView: View {
    @StateObject private var viewModel: TransactionsViewModel

    init(viewModel: TransactionsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                Color.clear.onAppear {
                    Task { await viewModel.loadTransactions() }
                }
            case .loading:
                LoadingView()
            case .success(let transactions):
                transactionsList(transactions)
            case .error(let message):
                ErrorView(message: message) {
                    Task { await viewModel.loadTransactions() }
                }
            }
        }
        .navigationTitle("Transactions")
    }

    private func transactionsList(_ transactions: [Transaction]) -> some View {
        List(transactions) { transaction in
            TransactionRow(transaction: transaction)
        }
        .refreshable {
            await viewModel.loadTransactions()
        }
    }
}
```

#### 3.4 Create Components

`Presentation/Transactions/Components/TransactionRow.swift`

```swift
import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.headline)
                Text(transaction.category.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(transaction.amount, format: .currency(code: "USD"))
                .font(.headline)
                .foregroundStyle(transaction.type == .income ? .green : .red)
        }
        .padding(.vertical, 4)
    }
}
```

---

### Step 4: Wire Up Dependencies

#### 4.1 Register in AppContainer

`AppContainer.swift`

```swift
final class AppContainer: ObservableObject {
    // MARK: - Transactions
    let transactionsRepository: TransactionsRepository
    let getTransactionsUseCase: GetTransactionsUseCase
    let addTransactionUseCase: AddTransactionUseCase

    init() {
        // Transactions
        let transactionsAPI = TransactionsAPI()
        let transactionsService = TransactionsService(api: transactionsAPI)
        self.transactionsRepository = transactionsService
        self.getTransactionsUseCase = GetTransactionsUseCase(repository: transactionsService)
        self.addTransactionUseCase = AddTransactionUseCase(repository: transactionsService)
    }

    // MARK: - ViewModel Factories
    func makeTransactionsViewModel() -> TransactionsViewModel {
        TransactionsViewModel(
            getTransactionsUseCase: getTransactionsUseCase,
            addTransactionUseCase: addTransactionUseCase
        )
    }
}
```

#### 4.2 Use in Navigation

```swift
struct ContentView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        NavigationStack {
            TransactionsView(viewModel: container.makeTransactionsViewModel())
        }
    }
}
```

---

## Checklist for New Features

- [ ] **Domain Model** created with all business properties
- [ ] **Repository Protocol** defined with required operations
- [ ] **UseCase** created (if business logic needed)
- [ ] **DTO** created with `toDomain()` mapping
- [ ] **API** endpoints defined
- [ ] **Service** implements Repository protocol
- [ ] **State** enum covers all UI states
- [ ] **ViewModel** handles all user actions
- [ ] **View** renders all states exhaustively
- [ ] **Components** extracted for reusability
- [ ] **AppContainer** updated with new dependencies
- [ ] **Tests** written for UseCase and ViewModel

---

## Common Patterns

### Pagination

```swift
struct GetTransactionsUseCase {
    func execute(page: Int, pageSize: Int = 20) async throws -> PaginatedResult<Transaction> {
        try await repository.getTransactions(page: page, pageSize: pageSize)
    }
}
```

### Search/Filter

```swift
@MainActor
final class TransactionsViewModel: ObservableObject {
    @Published var searchQuery: String = ""

    var filteredTransactions: [Transaction] {
        guard case .success(let transactions) = state else { return [] }
        guard !searchQuery.isEmpty else { return transactions }
        return transactions.filter {
            $0.description.localizedCaseInsensitiveContains(searchQuery)
        }
    }
}
```

### Form Validation

```swift
struct AddTransactionUseCase {
    func execute(_ transaction: Transaction) async throws {
        guard transaction.amount > 0 else {
            throw ValidationError.invalidAmount
        }
        guard !transaction.description.isEmpty else {
            throw ValidationError.emptyDescription
        }
        try await repository.addTransaction(transaction)
    }
}
```

### Optimistic Updates

```swift
func deleteTransaction(_ transaction: Transaction) async {
    // Optimistically remove from UI
    if case .success(var transactions) = state {
        transactions.removeAll { $0.id == transaction.id }
        state = .success(transactions)
    }

    do {
        try await deleteTransactionUseCase.execute(id: transaction.id)
    } catch {
        // Rollback on failure
        await loadTransactions()
        state = .error(error.localizedDescription)
    }
}
```

---

## File Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Domain Model | `[Name].swift` | `Transaction.swift` |
| Repository | `[Feature]Repository.swift` | `TransactionsRepository.swift` |
| UseCase | `[Action][Feature]UseCase.swift` | `GetTransactionsUseCase.swift` |
| DTO | `[Model]DTO.swift` | `TransactionDTO.swift` |
| API | `[Feature]API.swift` | `TransactionsAPI.swift` |
| Service | `[Feature]Service.swift` | `TransactionsService.swift` |
| View | `[Feature]View.swift` | `TransactionsView.swift` |
| ViewModel | `[Feature]ViewModel.swift` | `TransactionsViewModel.swift` |
| State | `[Feature]State.swift` | `TransactionsState.swift` |
| Component | `[Name].swift` | `TransactionRow.swift` |
