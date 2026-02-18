import SwiftUI

struct SettingsView: View {
    @Bindable var authViewModel: AuthViewModel
    @Bindable var categoriesViewModel: CategoriesViewModel
    let exportAPI: ExportAPI
    @State private var showSignOutAlert = false
    @State private var isExporting = false
    @State private var exportURL: URL?
    @State private var showShareSheet = false
    @State private var exportError: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                List {
                    // Profile Section
                    Section {
                        if let user = authViewModel.state.currentUser {
                            HStack(spacing: AppSpacing.md) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 48))
                                    .foregroundStyle(Color.appPrimary)

                                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                    Text(user.name)
                                        .font(.headline)
                                        .foregroundStyle(Color.appForeground)

                                    Text(user.email)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.appMutedForeground)
                                }
                            }
                            .padding(.vertical, AppSpacing.sm)
                        }
                    }

                    // Management Section
                    Section("Management") {
                        NavigationLink {
                            CategoriesView(viewModel: categoriesViewModel)
                        } label: {
                            SettingsRow(icon: "tag.fill", title: "Categories", color: .appChart3)
                        }
                    }

                    // Preferences Section
                    Section("Preferences") {
                        SettingsRow(icon: "bell.fill", title: "Notifications", color: .appChart1)
                        SettingsRow(icon: "paintbrush.fill", title: "Appearance", color: .appChart2)
                        SettingsRow(icon: "globe", title: "Currency", subtitle: "MXN", color: .appChart3)
                        SettingsRow(icon: "lock.fill", title: "Privacy", color: .appChart4)
                    }

                    // Data Section
                    Section("Data") {
                        Button {
                            exportData()
                        } label: {
                            HStack(spacing: AppSpacing.md) {
                                Image(systemName: "arrow.down.doc.fill")
                                    .font(.body)
                                    .foregroundStyle(.white)
                                    .frame(width: 28, height: 28)
                                    .background(Color.appPrimary)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))

                                Text("Export Data")
                                    .foregroundStyle(Color.appForeground)

                                Spacer()

                                if isExporting {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(Color.appMutedForeground)
                                }
                            }
                        }
                        .disabled(isExporting)

                        SettingsRow(icon: "arrow.up.doc.fill", title: "Import Data", color: .appPrimary)
                        SettingsRow(icon: "icloud.fill", title: "Backup & Sync", color: .appChart2)
                    }

                    // Support Section
                    Section("Support") {
                        SettingsRow(icon: "questionmark.circle.fill", title: "Help Center", color: .appMutedForeground)
                        SettingsRow(icon: "envelope.fill", title: "Contact Us", color: .appMutedForeground)
                        SettingsRow(icon: "star.fill", title: "Rate App", color: .appChart4)
                    }

                    // Sign Out Section
                    Section {
                        Button(role: .destructive) {
                            showSignOutAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Sign Out")
                            }
                            .foregroundStyle(Color.appDestructive)
                        }
                    }

                    // Version
                    Section {
                        HStack {
                            Text("Version")
                                .foregroundStyle(Color.appMutedForeground)
                            Spacer()
                            Text("1.0.0")
                                .foregroundStyle(Color.appMutedForeground)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    Task {
                        await authViewModel.signOut()
                    }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Export Error", isPresented: .init(get: { exportError != nil }, set: { if !$0 { exportError = nil } })) {
                Button("OK") { exportError = nil }
            } message: {
                Text(exportError ?? "")
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }

    private func exportData() {
        isExporting = true
        Task {
            do {
                let url = try await exportAPI.exportData()
                exportURL = url
                showShareSheet = true
            } catch {
                exportError = error.localizedDescription
            }
            isExporting = false
        }
    }
}

// MARK: - Share Sheet

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Settings Row

private struct SettingsRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let color: Color

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            Text(title)
                .foregroundStyle(Color.appForeground)

            Spacer()

            if let subtitle {
                Text(subtitle)
                    .foregroundStyle(Color.appMutedForeground)
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appMutedForeground)
        }
    }
}
