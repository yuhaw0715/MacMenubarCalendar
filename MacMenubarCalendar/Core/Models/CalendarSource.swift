import Foundation
import SwiftUI
import AppKit

public struct CalendarSource: Identifiable, Hashable, Sendable, Codable {
    public let id: String
    public let title: String
    public let colorHex: String
    public let accountTitle: String?

    public init(id: String, title: String, colorHex: String, accountTitle: String? = nil) {
        self.id = id
        self.title = title
        self.colorHex = colorHex
        self.accountTitle = accountTitle
    }

    public var swiftUIColor: Color {
        Color(hex: colorHex) ?? .blue
    }
}

extension Color {
    public init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let length = hexSanitized.count
        let r, g, b, a: Double
        if length == 6 {
            r = Double((rgb & 0xFF0000) >> 16) / 255.0
            g = Double((rgb & 0x00FF00) >> 8) / 255.0
            b = Double(rgb & 0x0000FF) / 255.0
            a = 1.0
        } else if length == 8 {
            r = Double((rgb & 0xFF000000) >> 24) / 255.0
            g = Double((rgb & 0x00FF0000) >> 16) / 255.0
            b = Double((rgb & 0x0000FF00) >> 8) / 255.0
            a = Double(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }

        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    public func toHex() -> String? {
        guard let nsColor = NSColor(self).usingColorSpace(.sRGB) else { return nil }
        let r = Int(round(nsColor.redComponent * 0xFF))
        let g = Int(round(nsColor.greenComponent * 0xFF))
        let b = Int(round(nsColor.blueComponent * 0xFF))
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
