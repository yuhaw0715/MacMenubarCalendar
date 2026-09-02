import AppKit
import Foundation

@MainActor
public struct MenubarIconRenderer {
    public static func createStackedIcon(
        date: Date,
        calendar: Calendar = .current,
        language: AppLanguage = .system
    ) -> NSImage {
        let isZh = language.isChinese()

        let monthNumber = calendar.component(.month, from: date)
        let dayNumber = calendar.component(.day, from: date)

        let topText: String
        if isZh {
            topText = "\(monthNumber)月"
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "MMM"
            topText = formatter.string(from: date).uppercased()
        }

        let bottomText = String(format: "%02d", dayNumber)

        let topFont = NSFont.systemFont(ofSize: 8, weight: .bold)
        let bottomFont = NSFont.monospacedDigitSystemFont(ofSize: 10.5, weight: .bold)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let topAttrs: [NSAttributedString.Key: Any] = [
            .font: topFont,
            .foregroundColor: NSColor.black,
            .paragraphStyle: paragraphStyle
        ]
        let bottomAttrs: [NSAttributedString.Key: Any] = [
            .font: bottomFont,
            .foregroundColor: NSColor.black,
            .paragraphStyle: paragraphStyle
        ]

        let topSize = (topText as NSString).size(withAttributes: topAttrs)
        let bottomSize = (bottomText as NSString).size(withAttributes: bottomAttrs)

        let contentWidth = max(topSize.width, bottomSize.width)
        let totalWidth = max(20, ceil(contentWidth) + 4)
        let totalHeight: CGFloat = 22

        let image = NSImage(size: NSSize(width: totalWidth, height: totalHeight), flipped: false) { _ in
            let topY: CGFloat = 11.0
            let bottomY: CGFloat = 0.5

            let topRect = NSRect(
                x: 0,
                y: topY,
                width: totalWidth,
                height: topSize.height
            )
            let bottomRect = NSRect(
                x: 0,
                y: bottomY,
                width: totalWidth,
                height: bottomSize.height
            )

            (topText as NSString).draw(in: topRect, withAttributes: topAttrs)
            (bottomText as NSString).draw(in: bottomRect, withAttributes: bottomAttrs)

            return true
        }

        image.isTemplate = true
        return image
    }
}
