import AppKit
import Foundation

@MainActor
public struct AppIconRenderer {
    public static let defaultBaseSize = NSSize(width: 512, height: 512)
    public static let fullResolutionSize = NSSize(width: 1024, height: 1024)

    /// Standard icon sizes required for macOS .iconset / .icns
    public static let standardIconSizes: [Int] = [16, 32, 64, 128, 256, 512, 1024]

    /// Renders the Style 3A (Split-Panel Calendar with Red Spine & Rings) App Icon
    public static func renderAppIcon(
        date: Date,
        calendar: Calendar = .current,
        language: AppLanguage = .system,
        targetSize: NSSize = defaultBaseSize
    ) -> NSImage {
        let isZh = language.isChinese()

        let monthNumber = calendar.component(.month, from: date)
        let dayNumber = calendar.component(.day, from: date)
        let weekdayNumber = calendar.component(.weekday, from: date)

        let monthText: String
        let weekdayText: String

        if isZh {
            monthText = "\(monthNumber)月"
            let zhWeekdays = ["週日", "週一", "週二", "週三", "週四", "週五", "週六"]
            if weekdayNumber >= 1 && weekdayNumber <= 7 {
                weekdayText = zhWeekdays[weekdayNumber - 1]
            } else {
                weekdayText = "週四"
            }
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "MMM"
            monthText = formatter.string(from: date).uppercased()

            formatter.dateFormat = "EEE"
            weekdayText = formatter.string(from: date).uppercased()
        }

        let dayText = String(format: "%02d", dayNumber)

        let baseWidth: CGFloat = 512
        let baseHeight: CGFloat = 512
        let scaleX = targetSize.width / baseWidth
        let scaleY = targetSize.height / baseHeight

        let image = NSImage(size: targetSize, flipped: false) { _ in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }

            ctx.saveGState()
            ctx.scaleBy(x: scaleX, y: scaleY)

            let iconRect = NSRect(x: 56, y: 56, width: 400, height: 400)
            let radius: CGFloat = 88

            // Drop shadow for the squircle
            ctx.saveGState()
            let shadow = NSShadow()
            shadow.shadowColor = NSColor.black.withAlphaComponent(0.28)
            shadow.shadowOffset = NSSize(width: 0, height: -14)
            shadow.shadowBlurRadius = 24
            shadow.set()

            let basePath = NSBezierPath(roundedRect: iconRect, xRadius: radius, yRadius: radius)
            NSColor.white.setFill()
            basePath.fill()
            ctx.restoreGState()

            // Clip content to squircle
            ctx.saveGState()
            basePath.addClip()

            // Right white paper sheet background
            let pageGrad = NSGradient(
                starting: NSColor(calibratedWhite: 1.0, alpha: 1.0),
                ending: NSColor(calibratedRed: 0.96, green: 0.96, blue: 0.97, alpha: 1.0)
            )
            pageGrad?.draw(in: iconRect, angle: -90)

            // Left Red Tab (approx 36.5% width)
            let leftWidth: CGFloat = 146
            let leftRect = NSRect(x: iconRect.minX, y: iconRect.minY, width: leftWidth, height: iconRect.height)
            let redGrad = NSGradient(
                starting: NSColor(calibratedRed: 0.88, green: 0.18, blue: 0.16, alpha: 1.0),
                ending: NSColor(calibratedRed: 0.72, green: 0.08, blue: 0.09, alpha: 1.0)
            )
            redGrad?.draw(in: leftRect, angle: -90)

            // Perforated seam between red tab and right paper
            let seamPath = NSBezierPath()
            seamPath.move(to: NSPoint(x: leftRect.maxX, y: iconRect.minY))
            seamPath.line(to: NSPoint(x: leftRect.maxX, y: iconRect.maxY))
            NSColor.black.withAlphaComponent(0.25).setStroke()
            seamPath.lineWidth = 1.5
            let dashPattern: [CGFloat] = [5, 4]
            seamPath.setLineDash(dashPattern, count: 2, phase: 0)
            seamPath.stroke()

            // Soft drop shadow of red tab onto white paper
            let seamShadowRect = NSRect(x: leftRect.maxX, y: iconRect.minY, width: 8, height: iconRect.height)
            let seamGrad = NSGradient(starting: NSColor.black.withAlphaComponent(0.16), ending: NSColor.clear)
            seamGrad?.draw(in: seamShadowRect, angle: 0)

            let pStyle = NSMutableParagraphStyle()
            pStyle.alignment = .center

            // Left Month text
            let leftMonthFont = NSFont.systemFont(ofSize: isZh ? 34 : 32, weight: .heavy)
            let leftMonthAttrs: [NSAttributedString.Key: Any] = [
                .font: leftMonthFont,
                .foregroundColor: NSColor.white,
                .paragraphStyle: pStyle,
                .kern: isZh ? 0.0 : 1.5
            ]
            let leftMonthRect = NSRect(x: leftRect.minX, y: leftRect.midY + 28, width: leftRect.width, height: 45)
            (monthText as NSString).draw(in: leftMonthRect, withAttributes: leftMonthAttrs)

            // Horizontal separator inside red tab
            let subDiv = NSBezierPath()
            subDiv.move(to: NSPoint(x: leftRect.minX + 22, y: leftRect.midY + 12))
            subDiv.line(to: NSPoint(x: leftRect.maxX - 22, y: leftRect.midY + 12))
            NSColor.white.withAlphaComponent(0.35).setStroke()
            subDiv.lineWidth = 1.5
            subDiv.stroke()

            // Left Weekday text
            let leftWeekFont = NSFont.systemFont(ofSize: isZh ? 26 : 23, weight: .bold)
            let leftWeekAttrs: [NSAttributedString.Key: Any] = [
                .font: leftWeekFont,
                .foregroundColor: NSColor.white.withAlphaComponent(0.95),
                .paragraphStyle: pStyle,
                .kern: isZh ? 1.0 : 1.5
            ]
            let leftWeekRect = NSRect(x: leftRect.minX, y: leftRect.midY - 48, width: leftRect.width, height: 35)
            (weekdayText as NSString).draw(in: leftWeekRect, withAttributes: leftWeekAttrs)

            // Top Metal Binder Rings and Grommets
            let ringXs: [CGFloat] = [leftRect.midX, iconRect.minX + 225, iconRect.minX + 335]
            for rx in ringXs {
                // Punch hole eyelet
                let holeRect = NSRect(x: rx - 9, y: iconRect.maxY - 28, width: 18, height: 18)
                let holePath = NSBezierPath(ovalIn: holeRect)
                NSColor(calibratedWhite: 0.15, alpha: 0.45).setFill()
                holePath.fill()

                // Metallic Ring
                let ringRect = NSRect(x: rx - 12, y: iconRect.maxY - 40, width: 24, height: 48)
                let ringPath = NSBezierPath(roundedRect: ringRect, xRadius: 10, yRadius: 10)

                ctx.saveGState()
                let ringShadow = NSShadow()
                ringShadow.shadowColor = NSColor.black.withAlphaComponent(0.35)
                ringShadow.shadowOffset = NSSize(width: 0, height: -3)
                ringShadow.shadowBlurRadius = 4
                ringShadow.set()

                let ringGrad = NSGradient(
                    starting: NSColor(calibratedWhite: 0.95, alpha: 1.0),
                    ending: NSColor(calibratedWhite: 0.65, alpha: 1.0)
                )
                ringGrad?.draw(in: ringPath, angle: -45)

                NSColor(calibratedWhite: 0.4, alpha: 0.8).setStroke()
                ringPath.lineWidth = 1.0
                ringPath.stroke()
                ctx.restoreGState()
            }

            // Right Big Date numeral
            let rightRect = NSRect(x: leftRect.maxX, y: iconRect.minY, width: iconRect.width - leftWidth, height: iconRect.height)
            let desc = NSFont.systemFont(ofSize: 155, weight: .heavy).fontDescriptor.withDesign(.rounded)
            let dateFont = NSFont(descriptor: desc ?? NSFont.systemFont(ofSize: 155, weight: .heavy).fontDescriptor, size: 155) ?? NSFont.boldSystemFont(ofSize: 155)

            let dateAttrs: [NSAttributedString.Key: Any] = [
                .font: dateFont,
                .foregroundColor: NSColor(calibratedRed: 0.12, green: 0.12, blue: 0.14, alpha: 1.0),
                .paragraphStyle: pStyle
            ]
            let dateRect = NSRect(x: rightRect.minX, y: rightRect.minY + 68, width: rightRect.width, height: 180)
            (dayText as NSString).draw(in: dateRect, withAttributes: dateAttrs)

            // Bottom subtle page stack line
            let stackPath1 = NSBezierPath()
            stackPath1.move(to: NSPoint(x: rightRect.minX + 25, y: iconRect.minY + 28))
            stackPath1.line(to: NSPoint(x: rightRect.maxX - 40, y: iconRect.minY + 28))
            NSColor.black.withAlphaComponent(0.08).setStroke()
            stackPath1.lineWidth = 2.0
            stackPath1.stroke()

            // Outer border stroke
            NSColor.black.withAlphaComponent(0.08).setStroke()
            basePath.lineWidth = 1.5
            basePath.stroke()

            ctx.restoreGState()
            ctx.restoreGState()

            return true
        }

        return image
    }

    /// Renders a complete icon set covering standard macOS sizes (16, 32, 64, 128, 256, 512, 1024)
    public static func renderIconSet(
        date: Date,
        calendar: Calendar = .current,
        language: AppLanguage = .system
    ) -> [Int: NSImage] {
        var set: [Int: NSImage] = [:]
        for size in standardIconSizes {
            set[size] = renderAppIcon(
                date: date,
                calendar: calendar,
                language: language,
                targetSize: NSSize(width: size, height: size)
            )
        }
        return set
    }
}
