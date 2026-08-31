import Foundation
import EventKit
import Combine
import CoreGraphics

public final class EventKitCalendarService: CalendarServiceProtocol, @unchecked Sendable {
    private let eventStore: EKEventStore
    private var eventsDidChangeHandler: (@Sendable () -> Void)?
    private var observer: NSObjectProtocol?
    private let lock = NSLock()

    public init(eventStore: EKEventStore = EKEventStore()) {
        self.eventStore = eventStore
        setupNotification()
    }

    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func setupNotification() {
        observer = NotificationCenter.default.addObserver(
            forName: .EKEventStoreChanged,
            object: eventStore,
            queue: nil
        ) { [weak self] _ in
            guard let self = self else { return }
            let handler: (@Sendable () -> Void)?
            self.lock.lock()
            handler = self.eventsDidChangeHandler
            self.lock.unlock()
            handler?()
        }
    }

    public var authorizationStatus: AuthorizationStatus {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .fullAccess, .authorized:
            return .authorized
        @unknown default:
            return .notDetermined
        }
    }

    public func requestAccess() async -> AuthorizationStatus {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            return granted ? .authorized : .denied
        } catch {
            return authorizationStatus
        }
    }

    public func fetchCalendars() async -> [CalendarSource] {
        let ekCalendars = eventStore.calendars(for: .event)
        return ekCalendars.map { ekCal in
            let hex = ekCal.cgColor.flatMap { cgColorToHex($0) } ?? "#3478F6"
            return CalendarSource(
                id: ekCal.calendarIdentifier,
                title: ekCal.title,
                colorHex: hex,
                accountTitle: ekCal.source?.title
            )
        }
    }

    public func fetchEvents(
        from startDate: Date,
        to endDate: Date,
        selectedCalendarIds: Set<String>?,
        includeDeclined: Bool
    ) async -> [CalendarEvent] {
        let allCalendars = eventStore.calendars(for: .event)
        let filteredCalendars: [EKCalendar]
        if let selected = selectedCalendarIds {
            filteredCalendars = allCalendars.filter { selected.contains($0.calendarIdentifier) }
        } else {
            filteredCalendars = allCalendars
        }

        guard !filteredCalendars.isEmpty else { return [] }

        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: filteredCalendars
        )

        let ekEvents = eventStore.events(matching: predicate)

        return ekEvents.compactMap { ekEvent -> CalendarEvent? in
            let isDeclined = checkIfDeclined(ekEvent)
            if !includeDeclined && isDeclined {
                return nil
            }

            let hex = ekEvent.calendar.cgColor.flatMap { cgColorToHex($0) } ?? "#3478F6"

            return CalendarEvent(
                id: ekEvent.eventIdentifier ?? UUID().uuidString,
                calendarId: ekEvent.calendar.calendarIdentifier,
                calendarTitle: ekEvent.calendar.title,
                calendarColorHex: hex,
                title: ekEvent.title ?? "",
                startDate: ekEvent.startDate,
                endDate: ekEvent.endDate,
                isAllDay: ekEvent.isAllDay,
                location: ekEvent.location,
                isStatusDeclined: isDeclined
            )
        }
    }

    public func setEventsDidChangeHandler(_ handler: (@Sendable () -> Void)?) {
        lock.lock()
        defer { lock.unlock() }
        self.eventsDidChangeHandler = handler
    }

    private func checkIfDeclined(_ event: EKEvent) -> Bool {
        if event.status == .canceled {
            return true
        }
        if let attendees = event.attendees {
            for attendee in attendees where attendee.isCurrentUser {
                if attendee.participantStatus == .declined {
                    return true
                }
            }
        }
        return false
    }

    private func cgColorToHex(_ color: CGColor) -> String {
        guard let components = color.components, color.numberOfComponents >= 3 else {
            return "#3478F6"
        }
        let r = Int(round(components[0] * 255.0))
        let g = Int(round(components[1] * 255.0))
        let b = Int(round(components[2] * 255.0))
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
