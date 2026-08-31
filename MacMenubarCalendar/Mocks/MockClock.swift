import Foundation

public final class MockClock: ClockProtocol, @unchecked Sendable {
    private let lock = NSLock()
    private var _now: Date
    private var _timeZone: TimeZone

    public init(now: Date = Date(), timeZone: TimeZone = .current) {
        self._now = now
        self._timeZone = timeZone
    }

    public var now: Date {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _now
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _now = newValue
        }
    }

    public var timeZone: TimeZone {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _timeZone
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _timeZone = newValue
        }
    }

    public func advance(by seconds: TimeInterval) {
        lock.lock()
        defer { lock.unlock() }
        _now = _now.addingTimeInterval(seconds)
    }

    public func advance(days: Int) {
        lock.lock()
        defer { lock.unlock() }
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = _timeZone
        if let next = cal.date(byAdding: .day, value: days, to: _now) {
            _now = next
        }
    }
}
