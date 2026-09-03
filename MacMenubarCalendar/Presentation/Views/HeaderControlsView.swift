import SwiftUI

public struct HeaderControlsView: View {
    @ObservedObject var viewModel: CalendarViewModel
    var onQuit: () -> Void

    public init(viewModel: CalendarViewModel, onQuit: @escaping () -> Void = { NSApplication.shared.terminate(nil) }) {
        self.viewModel = viewModel
        self.onQuit = onQuit
    }

    private var monthYearTitle: String {
        viewModel.monthYearTitle
    }

    public var body: some View {
        HStack(spacing: 12) {
            // Month & Year Big Title (e.g. 2026年8月)
            Text(monthYearTitle)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(monthYearTitle)

            Spacer()

            // Capsule Navigation Controls (< 今天 >)
            HStack(spacing: 0) {
                Button(action: { viewModel.previousWeek() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.85))
                        .frame(width: 26, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help(AppStrings.localized("header.nav.prev_week"))
                .accessibilityLabel(AppStrings.localized("header.nav.prev_week"))

                Button(action: { viewModel.resetToToday() }) {
                    Text(AppStrings.localized("header.nav.today"))
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .frame(height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help(AppStrings.localized("header.nav.today"))
                .accessibilityLabel(AppStrings.localized("header.nav.today"))

                Button(action: { viewModel.nextWeek() }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.85))
                        .frame(width: 26, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help(AppStrings.localized("header.nav.next_week"))
                .accessibilityLabel(AppStrings.localized("header.nav.next_week"))
            }
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
                    )
            )

            // Right Actions: Refresh, Pin, Settings, Quit App
            HStack(spacing: 4) {
                Button(action: {
                    Task { await viewModel.refreshData() }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.75))
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.plain)
                .help(AppStrings.localized("header.action.refresh"))
                .accessibilityLabel(AppStrings.localized("header.action.refresh"))

                Button(action: { viewModel.togglePin() }) {
                    Image(systemName: viewModel.isPinned ? "pin.fill" : "pin")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(viewModel.isPinned ? .accentColor : .white.opacity(0.75))
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.plain)
                .help(AppStrings.localized(viewModel.isPinned ? "header.action.unpin" : "header.action.pin"))
                .accessibilityLabel(AppStrings.localized(viewModel.isPinned ? "header.action.unpin" : "header.action.pin"))

                Button(action: { viewModel.isShowingSettings.toggle() }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(viewModel.isShowingSettings ? .accentColor : .white.opacity(0.75))
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.plain)
                .help(AppStrings.localized("header.action.settings"))
                .accessibilityLabel(AppStrings.localized("header.action.settings"))

                Button(action: onQuit) {
                    Image(systemName: "power")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.red.opacity(0.85))
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.plain)
                .help(AppStrings.localized("action.quit"))
                .accessibilityLabel(AppStrings.localized("action.quit"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(Color.clear)
    }
}
