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
        lock.withLock {
            stubbedAuthorizationStatus
        }
    }

    public func requestAccess() async -> AuthorizationStatus {
        lock.withLock {
            stubbedAuthorizationStatus = requestAccessResult
            return stubbedAuthorizationStatus
        }
    }

    public func fetchCalendars() async -> [CalendarSource] {
        lock.withLock {
            stubbedCalendars
        }
    }

    public func fetchEvents(
        from startDate: Date,
        to endDate: Date,
        selectedCalendarIds: Set<String>?,
        includeDeclined: Bool
    ) async -> [CalendarEvent] {
        lock.withLock {
            stubbedEvents.filter { event in
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
    }

    public func setEventsDidChangeHandler(_ handler: (@Sendable () -> Void)?) {
        lock.withLock {
            self.eventsDidChangeHandler = handler
        }
    }

    public func triggerEventsDidChange() {
        let handler: (@Sendable () -> Void)? = lock.withLock {
            self.eventsDidChangeHandler
        }
        handler?()
    }
}
