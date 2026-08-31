import Foundation
import SwiftUI

public struct CalendarEvent: Identifiable, Hashable, Sendable {
    public let id: String
    public let calendarId: String
    public let calendarTitle: String
    public let calendarColorHex: String
    public let title: String
    public let startDate: Date
    public let endDate: Date
    public let isAllDay: Bool
    public let location: String?
    public let isStatusDeclined: Bool

    public init(
        id: String,
        calendarId: String,
        calendarTitle: String,
        calendarColorHex: String,
        title: String,
        startDate: Date,
        endDate: Date,
        isAllDay: Bool,
        location: String? = nil,
        isStatusDeclined: Bool = false
    ) {
        self.id = id
        self.calendarId = calendarId
        self.calendarTitle = calendarTitle
        self.calendarColorHex = calendarColorHex
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.location = location
        self.isStatusDeclined = isStatusDeclined
    }

    public var calendarColor: Color {
        Color(hex: calendarColorHex) ?? .blue
    }
}
