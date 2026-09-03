import AppKit
import Foundation
import Combine

public final class SystemNotificationWatcher: @unchecked Sendable {
    private var cancellables = Set<AnyCancellable>()
    private var onDateOrTimeZoneChanged: (@Sendable () -> Void)?
    private let lock = NSLock()

    public init() {
        setupObservers()
    }

    public func setHandler(_ handler: (@Sendable () -> Void)?) {
        lock.lock()
        defer { lock.unlock() }
        self.onDateOrTimeZoneChanged = handler
    }

    private func setupObservers() {
        let center = NotificationCenter.default
        let wsCenter = NSWorkspace.shared.notificationCenter

        Publishers.Merge4(
            center.publisher(for: .NSCalendarDayChanged),
            center.publisher(for: .NSSystemTimeZoneDidChange),
            center.publisher(for: .NSSystemClockDidChange),
            wsCenter.publisher(for: NSWorkspace.didWakeNotification)
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            guard let self = self else { return }
            let handler: (@Sendable () -> Void)?
            self.lock.lock()
            handler = self.onDateOrTimeZoneChanged
            self.lock.unlock()
            handler?()
        }
        .store(in: &cancellables)
    }
}
