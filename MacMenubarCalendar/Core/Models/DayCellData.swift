import Foundation

public struct DayCellData: Identifiable, Hashable, Sendable {
    public var id: Date { date }
    public let date: Date
    public let dayNumber: Int
    public let isToday: Bool
    public let events: [CalendarEvent]
    public let visibleEvents: [CalendarEvent]
    public let hiddenCount: Int

    public init(
        date: Date,
        dayNumber: Int,
        isToday: Bool,
        events: [CalendarEvent],
        visibleEvents: [CalendarEvent] = [],
        hiddenCount: Int = 0
    ) {
        self.date = date
        self.dayNumber = dayNumber
        self.isToday = isToday
        self.events = events
        self.visibleEvents = visibleEvents
        self.hiddenCount = hiddenCount
    }
}
