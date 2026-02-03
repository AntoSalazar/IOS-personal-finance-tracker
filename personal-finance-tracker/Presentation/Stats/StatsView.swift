import SwiftUI

struct StatsView: View {
    @State private var selectedPeriod: StatsPeriod = .month
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Period Selector
                        HStack(spacing: AppSpacing.xs) {
                            ForEach(StatsPeriod.allCases) { period in
                                PeriodButton(
                                    title: period.title,
                                    isSelected: selectedPeriod == period
                                ) {
                                    withAnimation(.appFast) {
                                        selectedPeriod = period
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        
                        // Overview Card
                        AppCard {
                            VStack(alignment: .leading, spacing: AppSpacing.md) {
                                Text("Overview")
                                    .font(.headline)
                                    .foregroundStyle(Color.appCardForeground)
                                
                                HStack(spacing: AppSpacing.lg) {
                                    StatBox(
                                        title: "Income",
                                        value: "$0.00",
                                        color: Color.appChart2
                                    )
                                    
                                    StatBox(
                                        title: "Expenses",
                                        value: "$0.00",
                                        color: Color.appChart1
                                    )
                                    
                                    StatBox(
                                        title: "Balance",
                                        value: "$0.00",
                                        color: Color.appPrimary
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        
                        // Chart Placeholder
                        AppCard {
                            VStack(spacing: AppSpacing.md) {
                                HStack {
                                    Text("Spending by Category")
                                        .font(.headline)
                                        .foregroundStyle(Color.appCardForeground)
                                    Spacer()
                                }
                                
                                // Placeholder chart
                                RoundedRectangle(cornerRadius: AppRadius.md)
                                    .fill(Color.appSecondary)
                                    .frame(height: 200)
                                    .overlay {
                                        VStack(spacing: AppSpacing.sm) {
                                            Image(systemName: "chart.pie.fill")
                                                .font(.system(size: 48))
                                                .foregroundStyle(Color.appMutedForeground)
                                            Text("No data yet")
                                                .font(.subheadline)
                                                .foregroundStyle(Color.appMutedForeground)
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        
                        // Crypto Section
                        AppCard {
                            HStack(spacing: AppSpacing.md) {
                                Image(systemName: "bitcoinsign.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(Color.appChart4)
                                    .frame(width: 48, height: 48)
                                    .background(Color.appSecondary)
                                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                                
                                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                    Text("Crypto Portfolio")
                                        .font(.headline)
                                        .foregroundStyle(Color.appCardForeground)
                                    
                                    Text("Track your cryptocurrency investments")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.appMutedForeground)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appMutedForeground)
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                    }
                    .padding(.vertical, AppSpacing.md)
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Stats Period

private enum StatsPeriod: String, CaseIterable, Identifiable {
    case week
    case month
    case year
    case all
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        case .all: return "All"
        }
    }
}

// MARK: - Period Button

private struct PeriodButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? Color.appPrimaryForeground : Color.appForeground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.sm)
                .background(isSelected ? Color.appPrimary : Color.appSecondary)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        }
    }
}

// MARK: - Stat Box

private struct StatBox: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.appMutedForeground)
            
            Text(value)
                .font(.headline)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    StatsView()
}
