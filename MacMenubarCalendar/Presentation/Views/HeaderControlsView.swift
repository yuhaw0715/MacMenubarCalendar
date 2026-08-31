import SwiftUI

public struct HeaderControlsView: View {
    @ObservedObject var viewModel: CalendarViewModel
    var onQuit: () -> Void

    public init(viewModel: CalendarViewModel, onQuit: @escaping () -> Void = { NSApplication.shared.terminate(nil) }) {
        self.viewModel = viewModel
        self.onQuit = onQuit
    }

    private var monthYearTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = viewModel.timeZone
        // In zh-Hant: 2026年8月; in en: August 2026
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMMM", options: 0, locale: Locale.current) ?? "yyyy MMMM"
        return formatter.string(from: viewModel.startDate)
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
                .help(NSLocalizedString("header.nav.prev_week", comment: ""))
                .accessibilityLabel(NSLocalizedString("header.nav.prev_week", comment: ""))

                Button(action: { viewModel.resetToToday() }) {
                    Text(NSLocalizedString("header.nav.today", comment: ""))
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .frame(height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help(NSLocalizedString("header.nav.today", comment: ""))
                .accessibilityLabel(NSLocalizedString("header.nav.today", comment: ""))

                Button(action: { viewModel.nextWeek() }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.85))
                        .frame(width: 26, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help(NSLocalizedString("header.nav.next_week", comment: ""))
                .accessibilityLabel(NSLocalizedString("header.nav.next_week", comment: ""))
            }
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.1))
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
                .help(NSLocalizedString("header.action.refresh", comment: ""))
                .accessibilityLabel(NSLocalizedString("header.action.refresh", comment: ""))

                Button(action: { viewModel.togglePin() }) {
                    Image(systemName: viewModel.isPinned ? "pin.fill" : "pin")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(viewModel.isPinned ? .accentColor : .white.opacity(0.75))
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.plain)
                .help(NSLocalizedString(viewModel.isPinned ? "header.action.unpin" : "header.action.pin", comment: ""))
                .accessibilityLabel(NSLocalizedString(viewModel.isPinned ? "header.action.unpin" : "header.action.pin", comment: ""))

                Button(action: { viewModel.isShowingSettings.toggle() }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(viewModel.isShowingSettings ? .accentColor : .white.opacity(0.75))
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.plain)
                .help(NSLocalizedString("header.action.settings", comment: ""))
                .accessibilityLabel(NSLocalizedString("header.action.settings", comment: ""))

                Button(action: onQuit) {
                    Image(systemName: "power")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.red.opacity(0.85))
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.plain)
                .help(NSLocalizedString("action.quit", comment: ""))
                .accessibilityLabel(NSLocalizedString("action.quit", comment: ""))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(Color(red: 0.12, green: 0.12, blue: 0.13))
    }
}
