import Foundation
import SwiftUI

public enum AppearanceMode: String, CaseIterable, Identifiable, Sendable, Codable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    public var id: String { rawValue }

    public var localizedKey: String {
        switch self {
        case .system:
            return "settings.appearance.system"
        case .light:
            return "settings.appearance.light"
        case .dark:
            return "settings.appearance.dark"
        }
    }

    public var localizedTitleKey: LocalizedStringKey {
        LocalizedStringKey(localizedKey)
    }

    public var localizedTitle: String {
        AppStrings.localized(localizedKey)
    }

    public var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
