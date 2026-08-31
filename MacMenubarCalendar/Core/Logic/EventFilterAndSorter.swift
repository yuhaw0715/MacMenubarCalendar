import Foundation

public struct EventFilterAndSorter: Sendable {
    public init() {}

    public func filterEvents(
        _ events: [CalendarEvent],
        selectedCalendarIds: Set<String>?,
        showDeclinedEvents: Bool
    ) -> [CalendarEvent] {
        events.filter { event in
            if let selected = selectedCalendarIds, !selected.contains(event.calendarId) {
                return false
            }
            if !showDeclinedEvents && event.isStatusDeclined {
                return false
            }
            return true
        }
    }

    public func sortEventsForDay(_ events: [CalendarEvent]) -> [CalendarEvent] {
        events.sorted { lhs, rhs in
            // 1. All-day events first
            if lhs.isAllDay != rhs.isAllDay {
                return lhs.isAllDay && !rhs.isAllDay
            }
            // 2. Earlier start date first
            if lhs.startDate != rhs.startDate {
                return lhs.startDate < rhs.startDate
            }
            // 3. Stable sort by title or id
            if lhs.title != rhs.title {
                return lhs.title < rhs.title
            }
            return lhs.id < rhs.id
        }
    }

    public func eventsForDay(
        _ day: Date,
        from allEvents: [CalendarEvent],
        calendar: Calendar
    ) -> [CalendarEvent] {
        let dayStart = calendar.startOfDay(for: day)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
            return []
        }

        let matchingEvents = allEvents.filter { event in
            // An event matches if it overlaps with [dayStart, dayEnd)
            // Or if start == end and falls within [dayStart, dayEnd)
            if event.startDate == event.endDate {
                return event.startDate >= dayStart && event.startDate < dayEnd
            }
            return event.startDate < dayEnd && event.endDate > dayStart
        }

        return sortEventsForDay(matchingEvents)
    }
}
