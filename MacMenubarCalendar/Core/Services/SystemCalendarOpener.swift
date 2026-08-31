import Foundation
import AppKit

public final class SystemCalendarOpener: CalendarOpening, Sendable {
    public init() {}

    @MainActor
    public func openCalendar(for event: CalendarEvent) async -> Bool {
        // Fallback or primary: calshow:<secondsSinceReferenceDate>
        let timestamp = event.startDate.timeIntervalSinceReferenceDate
        if let url = URL(string: "calshow:\(timestamp)") {
            let success = NSWorkspace.shared.open(url)
            if success { return true }
        }

        return await openCalendarApp()
    }

    @MainActor
    public func openCalendar(at date: Date) async -> Bool {
        let timestamp = date.timeIntervalSinceReferenceDate
        if let url = URL(string: "calshow:\(timestamp)") {
            let success = NSWorkspace.shared.open(url)
            if success { return true }
        }

        return await openCalendarApp()
    }

    @MainActor
    private func openCalendarApp() async -> Bool {
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.iCal") {
            let configuration = NSWorkspace.OpenConfiguration()
            do {
                _ = try await NSWorkspace.shared.openApplication(at: appURL, configuration: configuration)
                return true
            } catch {
                return false
            }
        }
        return false
    }
}
