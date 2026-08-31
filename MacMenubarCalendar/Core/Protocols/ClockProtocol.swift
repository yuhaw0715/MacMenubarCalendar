import Foundation

public protocol ClockProtocol: Sendable {
    var now: Date { get }
    var timeZone: TimeZone { get }
    var calendar: Calendar { get }
}

extension ClockProtocol {
    public var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = timeZone
        return cal
    }
}
