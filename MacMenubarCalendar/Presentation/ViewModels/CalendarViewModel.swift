import Foundation
import SwiftUI
import Combine
import AppKit

@MainActor
public final class CalendarViewModel: ObservableObject {
    private let calendarService: CalendarServiceProtocol
    private let clock: ClockProtocol
    private let preferencesStore: PreferencesStoreProtocol
    private let loginItemManager: LoginItemManaging
    private let calendarOpener: CalendarOpening
    private let notificationWatcher: SystemNotificationWatcher
    private let gridCalculator: CalendarGridCalculator
    private let filterAndSorter: EventFilterAndSorter
    private let layoutEngine: DayLayoutEngine

    @Published public private(set) var authorizationStatus: AuthorizationStatus
    @Published public private(set) var availableCalendars: [CalendarSource] = []
    @Published public private(set) var selectedCalendarIds: Set<String>?
    @Published public private(set) var startDate: Date
    @Published public private(set) var dayCells: [DayCellData] = []
    @Published public private(set) var todayDateNumber: String = ""
    @Published public private(set) var currentDate: Date = Date()
    @Published public var selectedDay: Date?
    @Published public var selectedEvent: CalendarEvent?
    @Published public var isShowingSettings: Bool = false
    @Published public var isPinned: Bool = false
    @Published public var appearanceMode: AppearanceMode = .system
    @Published public var appLanguage: AppLanguage = .system
    @Published public var firstDayOfWeek: FirstDayOfWeek = .system
    @Published public var showDeclinedEvents: Bool = false
    @Published public var launchAtLogin: Bool = false
    @Published public private(set) var isLoading: Bool = false
    @Published public var launchAtLoginError: String?

    public var timeZone: TimeZone { clock.timeZone }
    public var calendar: Calendar { clock.calendar }

    public var monthYearTitle: String {
        let locale = appLanguage.effectiveLocale()
        return gridCalculator.monthTitle(for: startDate, calendar: clock.calendar, locale: locale)
    }

    public var weekdayHeaders: [String] {
        let locale = appLanguage.effectiveLocale()
        return gridCalculator.weekdayHeaders(firstDayOfWeek: firstDayOfWeek, calendar: clock.calendar, locale: locale)
    }

    private var rawEventsInRange: [CalendarEvent] = []
    private var lastAvailableCellHeight: CGFloat = 80.0

    public init(
        calendarService: CalendarServiceProtocol,
        clock: ClockProtocol = SystemClock(),
        preferencesStore: PreferencesStoreProtocol = AppPreferencesStore.shared,
        loginItemManager: LoginItemManaging = AppLoginItemManager(),
        calendarOpener: CalendarOpening = SystemCalendarOpener(),
        notificationWatcher: SystemNotificationWatcher = SystemNotificationWatcher(),
        gridCalculator: CalendarGridCalculator = CalendarGridCalculator(),
        filterAndSorter: EventFilterAndSorter = EventFilterAndSorter(),
        layoutEngine: DayLayoutEngine = DayLayoutEngine()
    ) {
        self.calendarService = calendarService
        self.clock = clock
        self.preferencesStore = preferencesStore
        self.loginItemManager = loginItemManager
        self.calendarOpener = calendarOpener
        self.notificationWatcher = notificationWatcher
        self.gridCalculator = gridCalculator
        self.filterAndSorter = filterAndSorter
        self.layoutEngine = layoutEngine

        self.authorizationStatus = calendarService.authorizationStatus
        self.selectedCalendarIds = preferencesStore.selectedCalendarIds
        self.showDeclinedEvents = preferencesStore.showDeclinedEvents
        self.appearanceMode = preferencesStore.appearanceMode
        self.appLanguage = preferencesStore.appLanguage
        self.firstDayOfWeek = preferencesStore.firstDayOfWeek
        self.startDate = gridCalculator.resetToToday(now: clock.now, firstDayOfWeek: preferencesStore.firstDayOfWeek, calendar: clock.calendar)
        self.launchAtLogin = loginItemManager.isEnabled
        self.isPinned = preferencesStore.isPinned

        AppStrings.currentLanguage = self.appLanguage
        updateTodayDateNumber()
        setupNotificationListeners()
    }

    private func setupNotificationListeners() {
        calendarService.setEventsDidChangeHandler { [weak self] in
            Task { @MainActor [weak self] in
                await self?.refreshEventsOnly()
            }
        }

        notificationWatcher.setHandler { [weak self] in
            Task { @MainActor [weak self] in
                self?.handleDateOrTimeZoneChanged()
            }
        }
    }

    public func onAppear() {
        updateTodayDateNumber()
        Task {
            if authorizationStatus == .authorized {
                await refreshData()
            }
        }
    }

    public func onPanelOpen() {
        // Requirement: reset date range to today on each open
        startDate = gridCalculator.resetToToday(now: clock.now, firstDayOfWeek: firstDayOfWeek, calendar: clock.calendar)
        updateTodayDateNumber()
        selectedDay = nil
        selectedEvent = nil
        isShowingSettings = false

        Task {
            if authorizationStatus == .authorized {
                await refreshData()
            }
        }
    }

    public func requestAuthorization() async {
        let status = await calendarService.requestAccess()
        self.authorizationStatus = status
        if status == .authorized {
            await refreshData()
        }
    }

    public func refreshData() async {
        isLoading = true
        defer { isLoading = false }

        // 1. Fetch calendars
        let fetchedCalendars = await calendarService.fetchCalendars()
        self.availableCalendars = fetchedCalendars

        // 2. Synchronize selectedCalendarIds
        let validIds = Set(fetchedCalendars.map(\.id))
        if let currentSelection = preferencesStore.selectedCalendarIds {
            // Keep valid IDs, and if new calendars were added, select them by default
            let cleaned = currentSelection.intersection(validIds)
            // If unknown new calendars appeared, add them to selection
            let knownBefore = preferencesStore.selectedCalendarIds ?? Set()
            let newlyAdded = validIds.subtracting(knownBefore)
            let updated = cleaned.union(newlyAdded)
            self.selectedCalendarIds = updated
            preferencesStore.selectedCalendarIds = updated
        } else {
            // Default: all selected
            self.selectedCalendarIds = validIds
            preferencesStore.selectedCalendarIds = validIds
        }

        await refreshEventsOnly()
    }

    public func refreshEventsOnly() async {
        let range = gridCalculator.calculateDateRange(startDate: startDate, calendar: clock.calendar)
        let events = await calendarService.fetchEvents(
            from: range.start,
            to: range.end,
            selectedCalendarIds: selectedCalendarIds,
            includeDeclined: showDeclinedEvents
        )
        self.rawEventsInRange = events
        rebuildDayCells()
    }

    public func nextWeek() {
        startDate = gridCalculator.nextWeek(from: startDate, calendar: clock.calendar)
        Task {
            await refreshEventsOnly()
        }
    }

    public func previousWeek() {
        startDate = gridCalculator.previousWeek(from: startDate, calendar: clock.calendar)
        Task {
            await refreshEventsOnly()
        }
    }

    public func resetToToday() {
        startDate = gridCalculator.resetToToday(now: clock.now, firstDayOfWeek: firstDayOfWeek, calendar: clock.calendar)
        Task {
            await refreshEventsOnly()
        }
    }

    public func toggleCalendar(id: String) {
        var selection = selectedCalendarIds ?? Set(availableCalendars.map(\.id))
        if selection.contains(id) {
            selection.remove(id)
        } else {
            selection.insert(id)
        }
        selectedCalendarIds = selection
        preferencesStore.selectedCalendarIds = selection
        Task {
            await refreshEventsOnly()
        }
    }

    public func isCalendarSelected(id: String) -> Bool {
        guard let selection = selectedCalendarIds else { return true }
        return selection.contains(id)
    }

    public func toggleShowDeclinedEvents() {
        showDeclinedEvents.toggle()
        preferencesStore.showDeclinedEvents = showDeclinedEvents
        Task {
            await refreshEventsOnly()
        }
    }

    public func setAppearanceMode(_ mode: AppearanceMode) {
        appearanceMode = mode
        preferencesStore.appearanceMode = mode
    }

    public func setAppLanguage(_ language: AppLanguage) {
        appLanguage = language
        preferencesStore.appLanguage = language
        AppStrings.currentLanguage = language
        rebuildDayCells()
    }

    public func setFirstDayOfWeek(_ firstDayOfWeek: FirstDayOfWeek) {
        self.firstDayOfWeek = firstDayOfWeek
        preferencesStore.firstDayOfWeek = firstDayOfWeek
        let midWeekAnchor = clock.calendar.date(byAdding: .day, value: 3, to: startDate) ?? startDate
        startDate = gridCalculator.startOfWeek(for: midWeekAnchor, firstDayOfWeek: firstDayOfWeek, calendar: clock.calendar)
        rebuildDayCells()
        Task {
            await refreshEventsOnly()
        }
    }

    public func toggleLaunchAtLogin() {
        let nextValue = !launchAtLogin
        do {
            try loginItemManager.setEnabled(nextValue)
            launchAtLogin = loginItemManager.isEnabled
            preferencesStore.launchAtLogin = launchAtLogin
            launchAtLoginError = nil
        } catch {
            launchAtLoginError = error.localizedDescription
            launchAtLogin = loginItemManager.isEnabled
        }
    }

    public func togglePin() {
        isPinned.toggle()
        preferencesStore.isPinned = isPinned
    }

    public func selectDay(_ date: Date?) {
        selectedDay = date
        selectedEvent = nil
    }

    public func selectEvent(_ event: CalendarEvent?) {
        selectedEvent = event
    }

    public func openInCalendar(for event: CalendarEvent) {
        Task {
            _ = await calendarOpener.openCalendar(for: event)
        }
    }

    public func openInCalendar(at date: Date) {
        Task {
            _ = await calendarOpener.openCalendar(at: date)
        }
    }

    public func openSystemPrivacySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars") {
            NSWorkspace.shared.open(url)
        }
    }

    public func updateAvailableCellHeight(_ height: CGFloat) {
        guard abs(height - lastAvailableCellHeight) > 2.0 else { return }
        lastAvailableCellHeight = height
        rebuildDayCells()
    }

    public func handleDateOrTimeZoneChanged() {
        AppStrings.currentLanguage = appLanguage
        updateTodayDateNumber()
        startDate = gridCalculator.resetToToday(now: clock.now, firstDayOfWeek: firstDayOfWeek, calendar: clock.calendar)
        Task {
            await refreshEventsOnly()
        }
    }

    private func updateTodayDateNumber() {
        let cal = clock.calendar
        let now = clock.now
        currentDate = now
        let day = cal.component(.day, from: now)
        todayDateNumber = "\(day)"
    }

    private func rebuildDayCells() {
        let cal = clock.calendar
        let dates = gridCalculator.calculateGridDates(startDate: startDate, calendar: cal)
        let todayStart = cal.startOfDay(for: clock.now)

        dayCells = dates.map { date in
            let dayStart = cal.startOfDay(for: date)
            let isToday = (dayStart == todayStart)
            let dayNumber = cal.component(.day, from: date)
            let dayEvents = filterAndSorter.eventsForDay(date, from: rawEventsInRange, calendar: cal)
            let layout = layoutEngine.calculateLayout(events: dayEvents, availableHeight: lastAvailableCellHeight)

            return DayCellData(
                date: date,
                dayNumber: dayNumber,
                isToday: isToday,
                events: dayEvents,
                visibleEvents: layout.visible,
                hiddenCount: layout.hiddenCount
            )
        }
    }
}
