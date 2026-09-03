#!/usr/bin/env swift

import AppKit
import Foundation

// Standalone renderer for offline script execution
struct OfflineAppIconRenderer {
    static func squirclePath(in rect: NSRect, radius: CGFloat) -> NSBezierPath {
        return NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
    }

    static func render(date: Date, isZh: Bool, size: NSSize) -> NSImage {
        let calendar = Calendar.current
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
        let scaleX = size.width / baseWidth
        let scaleY = size.height / baseHeight

        let image = NSImage(size: size, flipped: false) { _ in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }

            ctx.saveGState()
            ctx.scaleBy(x: scaleX, y: scaleY)

            let iconRect = NSRect(x: 56, y: 56, width: 400, height: 400)
            let radius: CGFloat = 88

            // Drop shadow
            ctx.saveGState()
            let shadow = NSShadow()
            shadow.shadowColor = NSColor.black.withAlphaComponent(0.28)
            shadow.shadowOffset = NSSize(width: 0, height: -14)
            shadow.shadowBlurRadius = 24
            shadow.set()

            let basePath = squirclePath(in: iconRect, radius: radius)
            NSColor.white.setFill()
            basePath.fill()
            ctx.restoreGState()

            // Clip content to squircle
            ctx.saveGState()
            basePath.addClip()

            // Right paper background
            let pageGrad = NSGradient(
                starting: NSColor(calibratedWhite: 1.0, alpha: 1.0),
                ending: NSColor(calibratedRed: 0.96, green: 0.96, blue: 0.97, alpha: 1.0)
            )
            pageGrad?.draw(in: iconRect, angle: -90)

            // Left Red Tab
            let leftWidth: CGFloat = 146
            let leftRect = NSRect(x: iconRect.minX, y: iconRect.minY, width: leftWidth, height: iconRect.height)
            let redGrad = NSGradient(
                starting: NSColor(calibratedRed: 0.88, green: 0.18, blue: 0.16, alpha: 1.0),
                ending: NSColor(calibratedRed: 0.72, green: 0.08, blue: 0.09, alpha: 1.0)
            )
            redGrad?.draw(in: leftRect, angle: -90)

            // Perforated seam line
            let seamPath = NSBezierPath()
            seamPath.move(to: NSPoint(x: leftRect.maxX, y: iconRect.minY))
            seamPath.line(to: NSPoint(x: leftRect.maxX, y: iconRect.maxY))
            NSColor.black.withAlphaComponent(0.25).setStroke()
            seamPath.lineWidth = 1.5
            let dashPattern: [CGFloat] = [5, 4]
            seamPath.setLineDash(dashPattern, count: 2, phase: 0)
            seamPath.stroke()

            // Drop shadow of red tab onto paper
            let seamShadowRect = NSRect(x: leftRect.maxX, y: iconRect.minY, width: 8, height: iconRect.height)
            let seamGrad = NSGradient(starting: NSColor.black.withAlphaComponent(0.16), ending: NSColor.clear)
            seamGrad?.draw(in: seamShadowRect, angle: 0)

            let pStyle = NSMutableParagraphStyle()
            pStyle.alignment = .center

            // Left text: Month
            let leftMonthFont = NSFont.systemFont(ofSize: isZh ? 34 : 32, weight: .heavy)
            let leftMonthAttrs: [NSAttributedString.Key: Any] = [
                .font: leftMonthFont,
                .foregroundColor: NSColor.white,
                .paragraphStyle: pStyle,
                .kern: isZh ? 0.0 : 1.5
            ]
            let leftMonthRect = NSRect(x: leftRect.minX, y: leftRect.midY + 28, width: leftRect.width, height: 45)
            (monthText as NSString).draw(in: leftMonthRect, withAttributes: leftMonthAttrs)

            // Divider inside red tab
            let subDiv = NSBezierPath()
            subDiv.move(to: NSPoint(x: leftRect.minX + 22, y: leftRect.midY + 12))
            subDiv.line(to: NSPoint(x: leftRect.maxX - 22, y: leftRect.midY + 12))
            NSColor.white.withAlphaComponent(0.35).setStroke()
            subDiv.lineWidth = 1.5
            subDiv.stroke()

            // Left text: Weekday
            let leftWeekFont = NSFont.systemFont(ofSize: isZh ? 26 : 23, weight: .bold)
            let leftWeekAttrs: [NSAttributedString.Key: Any] = [
                .font: leftWeekFont,
                .foregroundColor: NSColor.white.withAlphaComponent(0.95),
                .paragraphStyle: pStyle,
                .kern: isZh ? 1.0 : 1.5
            ]
            let leftWeekRect = NSRect(x: leftRect.minX, y: leftRect.midY - 48, width: leftRect.width, height: 35)
            (weekdayText as NSString).draw(in: leftWeekRect, withAttributes: leftWeekAttrs)

            // Top Metal Rings
            let ringXs: [CGFloat] = [leftRect.midX, iconRect.minX + 225, iconRect.minX + 335]
            for rx in ringXs {
                let holeRect = NSRect(x: rx - 9, y: iconRect.maxY - 28, width: 18, height: 18)
                let holePath = NSBezierPath(ovalIn: holeRect)
                NSColor(calibratedWhite: 0.15, alpha: 0.45).setFill()
                holePath.fill()

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

            // Right Date
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

            // Outer border
            NSColor.black.withAlphaComponent(0.08).setStroke()
            basePath.lineWidth = 1.5
            basePath.stroke()

            ctx.restoreGState()
            ctx.restoreGState()

            return true
        }

        return image
    }

    static func savePNG(image: NSImage, to url: URL) -> Bool {
        guard let tiffData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            return false
        }
        do {
            try pngData.write(to: url)
            return true
        } catch {
            print("Error saving PNG to \(url): \(error)")
            return false
        }
    }
}

let fileManager = FileManager.default
let scriptURL = URL(fileURLWithPath: CommandLine.arguments[0])
let rootURL = scriptURL.deletingLastPathComponent().deletingLastPathComponent()
let resourcesURL = rootURL.appendingPathComponent("MacMenubarCalendar/Resources")
let iconsetURL = rootURL.appendingPathComponent("build/AppIcon.iconset")
let outputIcnsURL = resourcesURL.appendingPathComponent("AppIcon.icns")

print("Generating AppIcon at \(outputIcnsURL.path)...")

// Ensure directory exists
try? fileManager.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

// Use fixed representative date for static .icns (September 3, Thursday)
var comp = DateComponents()
comp.year = 2026
comp.month = 9
comp.day = 3
let staticDate = Calendar.current.date(from: comp) ?? Date()

let iconSpecs: [(String, Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

for (filename, px) in iconSpecs {
    let size = NSSize(width: px, height: px)
    let img = OfflineAppIconRenderer.render(date: staticDate, isZh: true, size: size)
    let fileURL = iconsetURL.appendingPathComponent(filename)
    if OfflineAppIconRenderer.savePNG(image: img, to: fileURL) {
        print("  ✓ \(filename) (\(px)x\(px))")
    } else {
        print("  ✗ Failed to save \(filename)")
        exit(1)
    }
}

// Convert .iconset to .icns using macOS iconutil
let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconsetURL.path, "-o", outputIcnsURL.path]

do {
    try process.run()
    process.waitUntilExit()
    if process.terminationStatus == 0 {
        print("Successfully generated: \(outputIcnsURL.path)")
    } else {
        print("iconutil failed with code \(process.terminationStatus)")
        exit(1)
    }
} catch {
    print("Failed to run iconutil: \(error)")
    exit(1)
}
