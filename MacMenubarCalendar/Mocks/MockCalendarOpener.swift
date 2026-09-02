import Foundation

public final class MockCalendarOpener: CalendarOpening, @unchecked Sendable {
    private let lock = NSLock()
    public var openedEvents: [CalendarEvent] = []
    public var openedDates: [Date] = []
    public var shouldSucceed: Bool

    public init(shouldSucceed: Bool = true) {
        self.shouldSucceed = shouldSucceed
    }

    public func openCalendar(for event: CalendarEvent) async -> Bool {
        lock.withLock {
            openedEvents.append(event)
            return shouldSucceed
        }
    }

    public func openCalendar(at date: Date) async -> Bool {
        lock.withLock {
            openedDates.append(date)
            return shouldSucceed
        }
    }
}
