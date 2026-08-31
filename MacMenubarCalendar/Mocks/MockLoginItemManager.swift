import Foundation

public final class MockLoginItemManager: LoginItemManaging, @unchecked Sendable {
    private let lock = NSLock()
    private var _isEnabled: Bool
    public var shouldThrowError: Error?

    public init(isEnabled: Bool = false) {
        self._isEnabled = isEnabled
    }

    public var isEnabled: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _isEnabled
    }

    public func setEnabled(_ enabled: Bool) throws {
        lock.lock()
        defer { lock.unlock() }
        if let error = shouldThrowError {
            throw error
        }
        _isEnabled = enabled
    }
}
