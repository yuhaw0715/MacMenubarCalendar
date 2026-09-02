import SwiftUI

public struct SettingsView: View {
    @ObservedObject var viewModel: CalendarViewModel
    let onClose: () -> Void

    public init(viewModel: CalendarViewModel, onClose: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onClose = onClose
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(AppStrings.localized("settings.title"))
                    .font(.headline)

                Spacer()

                Button(action: onClose) {
                    Text(AppStrings.localized("action.done"))
                        .font(.body)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Calendars Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(AppStrings.localized("settings.calendars.header"))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)

                        if viewModel.availableCalendars.isEmpty {
                            Text(AppStrings.localized("settings.calendars.none_available"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            VStack(spacing: 4) {
                                ForEach(viewModel.availableCalendars) { cal in
                                    let isSelected = viewModel.isCalendarSelected(id: cal.id)
                                    Button(action: {
                                        viewModel.toggleCalendar(id: cal.id)
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                                                .foregroundColor(isSelected ? .accentColor : .secondary)

                                            Circle()
                                                .fill(cal.swiftUIColor)
                                                .frame(width: 8, height: 8)

                                            Text(cal.title)
                                                .font(.body)
                                                .foregroundColor(.primary)

                                            if let account = cal.accountTitle, !account.isEmpty {
                                                Spacer()
                                                Text(account)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            } else {
                                                Spacer()
                                            }
                                        }
                                        .padding(.vertical, 4)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.primary.opacity(0.03))
                            )
                        }
                    }

                    Divider()

                    // General Preferences Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text(AppStrings.localized("settings.general.header"))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)

                        // Show Declined Events
                        Toggle(AppStrings.localized("settings.show_declined_events"), isOn: Binding(
                            get: { viewModel.showDeclinedEvents },
                            set: { _ in viewModel.toggleShowDeclinedEvents() }
                        ))

                        // Launch at Login
                        VStack(alignment: .leading, spacing: 4) {
                            Toggle(AppStrings.localized("settings.launch_at_login"), isOn: Binding(
                                get: { viewModel.launchAtLogin },
                                set: { _ in viewModel.toggleLaunchAtLogin() }
                            ))

                            if let error = viewModel.launchAtLoginError {
                                Text(error)
                                    .font(.caption2)
                                    .foregroundColor(.red)
                            }
                        }

                        // Appearance
                        HStack {
                            Text(AppStrings.localized("settings.appearance.title"))
                            Spacer()
                            Picker("", selection: Binding(
                                get: { viewModel.appearanceMode },
                                set: { viewModel.setAppearanceMode($0) }
                            )) {
                                ForEach(AppearanceMode.allCases) { mode in
                                    Text(mode.localizedTitle).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 220)
                        }
                    }

                    Divider()

                    // Privacy & Info Section
                    VStack(alignment: .leading, spacing: 6) {
                        Text(AppStrings.localized("settings.about.title"))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)

                        Text(AppStrings.localized("settings.about.privacy_note"))
                            .font(.caption)
                            .foregroundColor(.secondary)

                        HStack {
                            Text("Mac Menubar Calendar v1.0.0")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button(AppStrings.localized("settings.open_privacy_settings")) {
                                viewModel.openSystemPrivacySettings()
                            }
                            .font(.caption)
                            .buttonStyle(.link)
                        }
                    }

                    Divider()

                    // Quit App
                    HStack {
                        Spacer()
                        Button(action: {
                            NSApplication.shared.terminate(nil)
                        }) {
                            Label(AppStrings.localized("action.quit"), systemImage: "power")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.bordered)
                        Spacer()
                    }
                }
                .padding(20)
            }
        }
        .frame(minWidth: 360, minHeight: 400)
    }
}
