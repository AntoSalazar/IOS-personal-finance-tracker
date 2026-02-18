import SwiftUI

struct AddDebtView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: DebtsViewModel

    @State private var personName = ""
    @State private var amount = ""
    @State private var description = ""
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var notes = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        AppTextField(
                            title: "Person Name",
                            placeholder: "Who owes you / who do you owe?",
                            text: $personName
                        )

                        AppTextField(
                            title: "Amount",
                            placeholder: "0.00",
                            text: $amount,
                            keyboardType: .decimalPad
                        )

                        AppTextField(
                            title: "Description (Optional)",
                            placeholder: "What is this debt for?",
                            text: $description
                        )

                        // Due Date Toggle
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Toggle(isOn: $hasDueDate) {
                                Text("Set Due Date")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color.appForeground)
                            }
                            .tint(Color.appPrimary)

                            if hasDueDate {
                                DatePicker("", selection: $dueDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                            }
                        }

                        AppTextField(
                            title: "Notes (Optional)",
                            placeholder: "Additional notes",
                            text: $notes
                        )

                        AppButton(
                            title: "Add Debt",
                            icon: "plus.circle.fill",
                            variant: .primary,
                            isLoading: isSaving,
                            isDisabled: !isValid,
                            fullWidth: true
                        ) {
                            Task {
                                isSaving = true
                                let amountValue = Double(amount) ?? 0
                                let success = await viewModel.createDebt(
                                    personName: personName,
                                    amount: amountValue,
                                    description: description.isEmpty ? nil : description,
                                    dueDate: hasDueDate ? dueDate : nil,
                                    notes: notes.isEmpty ? nil : notes
                                )
                                isSaving = false
                                if success { dismiss() }
                            }
                        }
                    }
                    .padding(AppSpacing.lg)
                }
            }
            .navigationTitle("New Debt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.appPrimary)
                }
            }
        }
    }

    private var isValid: Bool {
        !personName.isEmpty && !amount.isEmpty && (Double(amount) ?? 0) > 0
    }
}
