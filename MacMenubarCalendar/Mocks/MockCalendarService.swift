import Foundation

public final class MockCalendarService: CalendarServiceProtocol, @unchecked Sendable {
    private let lock = NSLock()
    public var stubbedAuthorizationStatus: AuthorizationStatus
    public var stubbedCalendars: [CalendarSource]
    public var stubbedEvents: [CalendarEvent]
    public var requestAccessResult: AuthorizationStatus
    public var eventsDidChangeHandler: (@Sendable () -> Void)?

    public init(
        authorizationStatus: AuthorizationStatus = .authorized,
        calendars: [CalendarSource] = [],
        events: [CalendarEvent] = [],
        requestAccessResult: AuthorizationStatus = .authorized
    ) {
        self.stubbedAuthorizationStatus = authorizationStatus
        self.stubbedCalendars = calendars
        self.stubbedEvents = events
        self.requestAccessResult = requestAccessResult
    }

    public var authorizationStatus: AuthorizationStatus {
        lock.lock()
        defer { lock.unlock() }
        return stubbedAuthorizationStatus
    }

    public func requestAccess() async -> AuthorizationStatus {
        lock.lock()
        stubbedAuthorizationStatus = requestAccessResult
        let status = stubbedAuthorizationStatus
        lock.unlock()
        return status
    }

    public func fetchCalendars() async -> [CalendarSource] {
        lock.lock()
        defer { lock.unlock() }
        return stubbedCalendars
    }

    public func fetchEvents(
        from startDate: Date,
        to endDate: Date,
        selectedCalendarIds: Set<String>?,
        includeDeclined: Bool
    ) async -> [CalendarEvent] {
        lock.lock()
        defer { lock.unlock() }

        return stubbedEvents.filter { event in
            if let selected = selectedCalendarIds, !selected.contains(event.calendarId) {
                return false
            }
            if !includeDeclined && event.isStatusDeclined {
                return false
            }
            // Overlap check: event.startDate < endDate && event.endDate > startDate
            return event.startDate < endDate && event.endDate > startDate
        }
    }

    public func setEventsDidChangeHandler(_ handler: (@Sendable () -> Void)?) {
        lock.lock()
        defer { lock.unlock() }
        self.eventsDidChangeHandler = handler
    }

    public func triggerEventsDidChange() {
        let handler: (@Sendable () -> Void)?
        lock.lock()
        handler = self.eventsDidChangeHandler
        lock.unlock()
        handler?()
    }
}
