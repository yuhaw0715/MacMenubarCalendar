import Foundation
import SwiftUI

public enum AppLanguage: String, CaseIterable, Identifiable, Codable, Sendable {
    case system = "system"
    case zhHant = "zh-Hant"
    case en = "en"

    public var id: String { rawValue }

    public var localizedKey: String {
        switch self {
        case .system:
            return "settings.language.system"
        case .zhHant:
            return "settings.language.zh_hant"
        case .en:
            return "settings.language.en"
        }
    }

    public var localizedTitle: String {
        AppStrings.localized(localizedKey)
    }

    public func effectiveLocale(preferredLanguages: [String] = Locale.preferredLanguages) -> Locale {
        switch self {
        case .zhHant:
            return Locale(identifier: "zh-Hant")
        case .en:
            return Locale(identifier: "en")
        case .system:
            let firstPreferred = preferredLanguages.first ?? Locale.current.identifier
            if firstPreferred.starts(with: "zh") {
                return Locale(identifier: "zh-Hant")
            } else {
                return Locale(identifier: "en")
            }
        }
    }

    public func isChinese(preferredLanguages: [String] = Locale.preferredLanguages) -> Bool {
        let locale = effectiveLocale(preferredLanguages: preferredLanguages)
        return locale.identifier.starts(with: "zh")
    }
}
