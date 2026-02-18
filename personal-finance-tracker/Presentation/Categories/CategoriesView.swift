import SwiftUI

struct CategoriesView: View {
    @Bindable var viewModel: CategoriesViewModel
    @State private var selectedType: CategoryType = .expense
    @State private var showAddCategory = false
    @State private var editingCategory: Category?
    @State private var deletingCategory: Category?

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Type picker
                Picker("Type", selection: $selectedType) {
                    ForEach(CategoryType.allCases) { type in
                        Text(type.title).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.md)

                if viewModel.isLoading && viewModel.categories.isEmpty {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if filteredCategories.isEmpty {
                    Spacer()
                    VStack(spacing: AppSpacing.md) {
                        Image(systemName: "tag")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.appMutedForeground)

                        Text("No \(selectedType.title.lowercased()) categories")
                            .font(.subheadline)
                            .foregroundStyle(Color.appMutedForeground)

                        AppButton(
                            title: "Add Category",
                            icon: "plus",
                            variant: .primary
                        ) {
                            showAddCategory = true
                        }
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(filteredCategories) { category in
                            CategoryRow(category: category)
                                .listRowBackground(Color.appCard)
                                .listRowSeparatorTint(Color.appBorder)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        deletingCategory = category
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }

                                    Button {
                                        editingCategory = category
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(Color.appPrimary)
                                }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddCategory = true
                } label: {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showAddCategory) {
            AddCategoryView(viewModel: viewModel, defaultType: selectedType)
        }
        .sheet(item: $editingCategory) { category in
            EditCategoryView(viewModel: viewModel, category: category)
        }
        .alert("Delete Category", isPresented: .init(
            get: { deletingCategory != nil },
            set: { if !$0 { deletingCategory = nil } }
        )) {
            Button("Cancel", role: .cancel) { deletingCategory = nil }
            Button("Delete", role: .destructive) {
                if let category = deletingCategory {
                    Task {
                        _ = await viewModel.deleteCategory(id: category.id)
                    }
                    deletingCategory = nil
                }
            }
        } message: {
            if let category = deletingCategory {
                Text("Are you sure you want to delete \"\(category.name)\"? This cannot be undone.")
            }
        }
        .task {
            await viewModel.loadCategories()
        }
        .refreshable {
            await viewModel.loadCategories()
        }
    }

    private var filteredCategories: [Category] {
        viewModel.categoriesForType(selectedType)
    }
}

// MARK: - Category Row

private struct CategoryRow: View {
    let category: Category

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Circle()
                .fill(categoryColor)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .font(.body)
                    .foregroundStyle(Color.appForeground)

                if let description = category.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(Color.appMutedForeground)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(category.type.title)
                .font(.caption)
                .foregroundStyle(Color.appMutedForeground)
        }
        .padding(.vertical, AppSpacing.xs)
    }

    private var categoryColor: Color {
        if let hex = category.color {
            return Color(hex: hex)
        }
        return category.type == .expense ? Color.appChart1 : Color.appChart2
    }
}

// MARK: - Add Category

private struct AddCategoryView: View {
    let viewModel: CategoriesViewModel
    let defaultType: CategoryType
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var type: CategoryType
    @State private var description = ""
    @State private var isSaving = false

    init(viewModel: CategoriesViewModel, defaultType: CategoryType) {
        self.viewModel = viewModel
        self.defaultType = defaultType
        _type = State(initialValue: defaultType)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                Form {
                    Section("Details") {
                        AppTextField(
                            title: "Name",
                            placeholder: "e.g. Food, Transport, Salary",
                            text: $name
                        )

                        Picker("Type", selection: $type) {
                            ForEach(CategoryType.allCases) { t in
                                Text(t.title).tag(t)
                            }
                        }

                        AppTextField(
                            title: "Description",
                            placeholder: "Optional description",
                            text: $description
                        )
                    }
                    .listRowBackground(Color.appCard)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        save()
                    } label: {
                        if isSaving {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Text("Save")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(name.isEmpty || isSaving)
                }
            }
        }
    }

    private func save() {
        isSaving = true
        Task {
            let success = await viewModel.createCategory(
                name: name,
                type: type,
                description: description.isEmpty ? nil : description
            )
            if success {
                dismiss()
            }
            isSaving = false
        }
    }
}

// MARK: - Edit Category

private struct EditCategoryView: View {
    let viewModel: CategoriesViewModel
    let category: Category
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var type: CategoryType
    @State private var description: String
    @State private var isSaving = false

    init(viewModel: CategoriesViewModel, category: Category) {
        self.viewModel = viewModel
        self.category = category
        _name = State(initialValue: category.name)
        _type = State(initialValue: category.type)
        _description = State(initialValue: category.description ?? "")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                Form {
                    Section("Details") {
                        AppTextField(
                            title: "Name",
                            placeholder: "Category name",
                            text: $name
                        )

                        Picker("Type", selection: $type) {
                            ForEach(CategoryType.allCases) { t in
                                Text(t.title).tag(t)
                            }
                        }

                        AppTextField(
                            title: "Description",
                            placeholder: "Optional description",
                            text: $description
                        )
                    }
                    .listRowBackground(Color.appCard)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        save()
                    } label: {
                        if isSaving {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Text("Save")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(name.isEmpty || isSaving)
                }
            }
        }
    }

    private func save() {
        isSaving = true
        Task {
            let success = await viewModel.updateCategory(
                id: category.id,
                name: name,
                type: type,
                description: description.isEmpty ? nil : description
            )
            if success {
                dismiss()
            }
            isSaving = false
        }
    }
}

// MARK: - Color from Hex

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        if hex.count == 6 {
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        } else {
            r = 0; g = 0; b = 0
        }
        self.init(red: r, green: g, blue: b)
    }
}
