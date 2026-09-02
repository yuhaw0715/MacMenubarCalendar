import Foundation

@MainActor
public protocol PreferencesStoreProtocol: AnyObject {
    var selectedCalendarIds: Set<String>? { get set }
    var showDeclinedEvents: Bool { get set }
    var appearanceMode: AppearanceMode { get set }
    var appLanguage: AppLanguage { get set }
    var firstDayOfWeek: FirstDayOfWeek { get set }
    var launchAtLogin: Bool { get set }
    var windowWidth: Double { get set }
    var windowHeight: Double { get set }
    var isPinned: Bool { get set }

    func registerDefaults()
}
