import Foundation
import Combine

@MainActor
public final class AppPreferencesStore: ObservableObject, PreferencesStoreProtocol {
    private let userDefaults: UserDefaults

    public static let shared = AppPreferencesStore()

    private enum Keys {
        static let selectedCalendarIds = "selectedCalendarIds"
        static let showDeclinedEvents = "showDeclinedEvents"
        static let appearanceMode = "appearanceMode"
        static let appLanguage = "appLanguage"
        static let launchAtLogin = "launchAtLogin"
        static let windowWidth = "windowWidth"
        static let windowHeight = "windowHeight"
        static let isPinned = "isPinned"
    }

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        registerDefaults()
    }

    public func registerDefaults() {
        userDefaults.register(defaults: [
            Keys.showDeclinedEvents: false,
            Keys.appearanceMode: AppearanceMode.system.rawValue,
            Keys.appLanguage: AppLanguage.system.rawValue,
            Keys.launchAtLogin: false,
            Keys.windowWidth: 720.0,
            Keys.windowHeight: 500.0,
            Keys.isPinned: false
        ])
    }

    public var selectedCalendarIds: Set<String>? {
        get {
            guard let array = userDefaults.array(forKey: Keys.selectedCalendarIds) as? [String] else {
                return nil
            }
            return Set(array)
        }
        set {
            if let newValue = newValue {
                userDefaults.set(Array(newValue), forKey: Keys.selectedCalendarIds)
            } else {
                userDefaults.removeObject(forKey: Keys.selectedCalendarIds)
            }
            objectWillChange.send()
        }
    }

    public var showDeclinedEvents: Bool {
        get {
            userDefaults.bool(forKey: Keys.showDeclinedEvents)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.showDeclinedEvents)
            objectWillChange.send()
        }
    }

    public var appearanceMode: AppearanceMode {
        get {
            guard let raw = userDefaults.string(forKey: Keys.appearanceMode),
                  let mode = AppearanceMode(rawValue: raw) else {
                return .system
            }
            return mode
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: Keys.appearanceMode)
            objectWillChange.send()
        }
    }

    public var appLanguage: AppLanguage {
        get {
            guard let raw = userDefaults.string(forKey: Keys.appLanguage),
                  let lang = AppLanguage(rawValue: raw) else {
                return .system
            }
            return lang
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: Keys.appLanguage)
            objectWillChange.send()
        }
    }

    public var launchAtLogin: Bool {
        get {
            userDefaults.bool(forKey: Keys.launchAtLogin)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.launchAtLogin)
            objectWillChange.send()
        }
    }

    public var windowWidth: Double {
        get {
            let val = userDefaults.double(forKey: Keys.windowWidth)
            return val > 300 ? val : 720.0
        }
        set {
            userDefaults.set(newValue, forKey: Keys.windowWidth)
            objectWillChange.send()
        }
    }

    public var windowHeight: Double {
        get {
            let val = userDefaults.double(forKey: Keys.windowHeight)
            return val > 200 ? val : 500.0
        }
        set {
            userDefaults.set(newValue, forKey: Keys.windowHeight)
            objectWillChange.send()
        }
    }

    public var isPinned: Bool {
        get {
            userDefaults.bool(forKey: Keys.isPinned)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.isPinned)
            objectWillChange.send()
        }
    }
}
