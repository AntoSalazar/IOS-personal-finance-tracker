import SwiftUI

struct TransactionsView: View {
    @State private var searchText = ""
    @State private var selectedFilter: TransactionFilter = .all
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppSpacing.sm) {
                            ForEach(TransactionFilter.allCases) { filter in
                                FilterPill(
                                    title: filter.title,
                                    isSelected: selectedFilter == filter
                                ) {
                                    withAnimation(.appFast) {
                                        selectedFilter = filter
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.vertical, AppSpacing.sm)
                    }
                    
                    // Empty State
                    Spacer()
                    
                    VStack(spacing: AppSpacing.md) {
                        Image(systemName: "arrow.left.arrow.right.circle")
                            .font(.system(size: 64))
                            .foregroundStyle(Color.appMutedForeground)
                        
                        Text("No Transactions Yet")
                            .font(.title2.bold())
                            .foregroundStyle(Color.appForeground)
                        
                        Text("Start tracking your income and expenses by adding your first transaction")
                            .font(.subheadline)
                            .foregroundStyle(Color.appMutedForeground)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppSpacing.xl)
                        
                        AppButton(
                            title: "Add Transaction",
                            icon: "plus.circle.fill",
                            variant: .primary
                        ) {
                            // TODO: Add transaction
                        }
                        .padding(.top, AppSpacing.sm)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Transactions")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search transactions")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // TODO: Add transaction
                    } label: {
                        Image(systemName: "plus")
                            .font(.body.weight(.semibold))
                    }
                }
            }
        }
    }
}

// MARK: - Transaction Filter

private enum TransactionFilter: String, CaseIterable, Identifiable {
    case all
    case income
    case expenses
    case categories
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .all: return "All"
        case .income: return "Income"
        case .expenses: return "Expenses"
        case .categories: return "Categories"
        }
    }
}

// MARK: - Filter Pill

private struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? Color.appPrimaryForeground : Color.appForeground)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(isSelected ? Color.appPrimary : Color.appSecondary)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    TransactionsView()
}
