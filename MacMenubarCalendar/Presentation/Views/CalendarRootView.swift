import SwiftUI

public struct CalendarRootView: View {
    @ObservedObject var viewModel: CalendarViewModel

    public init(viewModel: CalendarViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            // Dark solid background matching Apple Calendar dark mode (#1E1E1E)
            Color(red: 0.12, green: 0.12, blue: 0.13)
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
        .preferredColorScheme(viewModel.appearanceMode.colorScheme)
        .onAppear {
            viewModel.onAppear()
        }
    }
}
