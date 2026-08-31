import Foundation

public protocol CalendarOpening: Sendable {
    func openCalendar(for event: CalendarEvent) async -> Bool
    func openCalendar(at date: Date) async -> Bool
}
