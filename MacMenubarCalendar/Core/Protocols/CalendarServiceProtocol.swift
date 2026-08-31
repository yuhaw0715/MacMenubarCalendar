import Foundation

public protocol CalendarServiceProtocol: Sendable {
    var authorizationStatus: AuthorizationStatus { get }
    func requestAccess() async -> AuthorizationStatus
    func fetchCalendars() async -> [CalendarSource]
    func fetchEvents(
        from startDate: Date,
        to endDate: Date,
        selectedCalendarIds: Set<String>?,
        includeDeclined: Bool
    ) async -> [CalendarEvent]
    func setEventsDidChangeHandler(_ handler: (@Sendable () -> Void)?)
}
