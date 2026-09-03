import AppKit
import Combine
import Foundation

@MainActor
public final class DynamicAppIconController {
    public static let shared = DynamicAppIconController()

    private var cancellables = Set<AnyCancellable>()
    private let notificationCenter: NotificationCenter
    private let workspaceNotificationCenter: NotificationCenter?
    private let clock: ClockProtocol
    private let preferencesStore: PreferencesStoreProtocol
    private let iconApplicator: @MainActor (NSImage) -> Void

    public private(set) var currentRenderedDate: Date?
    public private(set) var currentRenderedLanguage: AppLanguage?
    public private(set) var updateCount: Int = 0

    public init(
        notificationCenter: NotificationCenter = .default,
        workspaceNotificationCenter: NotificationCenter? = NSWorkspace.shared.notificationCenter,
        clock: ClockProtocol = SystemClock(),
        preferencesStore: PreferencesStoreProtocol = AppPreferencesStore.shared,
        iconApplicator: @escaping @MainActor (NSImage) -> Void = { NSApplication.shared.applicationIconImage = $0 }
    ) {
        self.notificationCenter = notificationCenter
        self.workspaceNotificationCenter = workspaceNotificationCenter
        self.clock = clock
        self.preferencesStore = preferencesStore
        self.iconApplicator = iconApplicator

        setupSubscriptions()
        updateIcon()
    }

    public func updateIcon(forceDate: Date? = nil, forceLanguage: AppLanguage? = nil) {
        let date = forceDate ?? clock.now
        let language = forceLanguage ?? preferencesStore.appLanguage

        let icon = AppIconRenderer.renderAppIcon(
            date: date,
            calendar: clock.calendar,
            language: language
        )

        self.currentRenderedDate = date
        self.currentRenderedLanguage = language
        self.updateCount += 1
        iconApplicator(icon)
    }

    private func setupSubscriptions() {
        var publishers: [AnyPublisher<Notification, Never>] = [
            notificationCenter.publisher(for: .NSCalendarDayChanged).eraseToAnyPublisher(),
            notificationCenter.publisher(for: .NSSystemTimeZoneDidChange).eraseToAnyPublisher(),
            notificationCenter.publisher(for: .NSSystemClockDidChange).eraseToAnyPublisher()
        ]

        if let wsCenter = workspaceNotificationCenter {
            publishers.append(wsCenter.publisher(for: NSWorkspace.didWakeNotification).eraseToAnyPublisher())
        }

        Publishers.MergeMany(publishers)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateIcon()
            }
            .store(in: &cancellables)
    }
}
