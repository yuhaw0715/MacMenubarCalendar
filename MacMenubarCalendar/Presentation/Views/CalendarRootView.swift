import SwiftUI

public struct CalendarRootView: View {
    @ObservedObject var viewModel: CalendarViewModel

    public init(viewModel: CalendarViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            // Next-gen macOS Translucent Liquid Glass Material
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            // Subtle dark tint to guarantee high contrast across varied wallpapers
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            if viewModel.authorizationStatus != .authorized {
                PermissionPromptView(
                    status: viewModel.authorizationStatus,
                    onRequestAccess: {
                        Task { await viewModel.requestAuthorization() }
                    },
                    onOpenSettings: {
                        viewModel.openSystemPrivacySettings()
                    }
                )
            } else if viewModel.isShowingSettings {
                SettingsView(
                    viewModel: viewModel,
                    onClose: {
                        viewModel.isShowingSettings = false
                    }
                )
            } else if let event = viewModel.selectedEvent {
                EventDetailView(
                    event: event,
                    onOpenInCalendar: { event in
                        viewModel.openInCalendar(for: event)
                    },
                    onClose: {
                        viewModel.selectEvent(nil)
                    }
                )
            } else if let selectedDay = viewModel.selectedDay {
                let cellData = viewModel.dayCells.first(where: {
                    Calendar.current.isDate($0.date, inSameDayAs: selectedDay)
                })
                DayDetailView(
                    date: selectedDay,
                    events: cellData?.events ?? [],
                    onSelectEvent: { event in
                        viewModel.selectEvent(event)
                    },
                    onOpenInCalendar: { date in
                        viewModel.openInCalendar(at: date)
                    },
                    onClose: {
                        viewModel.selectDay(nil)
                    }
                )
            } else {
                VStack(spacing: 0) {
                    HeaderControlsView(viewModel: viewModel)
                    CalendarGridView(viewModel: viewModel)
                }
            }
        }
        .frame(minWidth: 560, minHeight: 420)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
        )
        .preferredColorScheme(viewModel.appearanceMode.colorScheme)
        .onAppear {
            viewModel.onAppear()
        }
    }
}
