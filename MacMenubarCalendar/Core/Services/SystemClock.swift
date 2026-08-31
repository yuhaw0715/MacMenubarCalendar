import Foundation

public struct SystemClock: ClockProtocol, Sendable {
    public init() {}

    public var now: Date {
        Date()
    }

    public var timeZone: TimeZone {
        .current
    }

    public var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .current
        return cal
    }
}
