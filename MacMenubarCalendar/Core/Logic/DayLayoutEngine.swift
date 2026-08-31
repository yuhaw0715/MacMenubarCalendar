import Foundation
import CoreGraphics

public struct DayLayoutEngine: Sendable {
    public init() {}

    public func calculateLayout(
        events: [CalendarEvent],
        availableHeight: CGFloat,
        rowHeight: CGFloat = 20.0,
        headerHeight: CGFloat = 26.0
    ) -> (visible: [CalendarEvent], hiddenCount: Int) {
        guard !events.isEmpty else {
            return ([], 0)
        }

        let contentHeight = max(0, availableHeight - headerHeight)
        let maxSlots = max(1, Int(floor(contentHeight / rowHeight)))

        if events.count <= maxSlots {
            return (events, 0)
        }

        let slotsForEvents = max(0, maxSlots - 1)
        let visible = Array(events.prefix(slotsForEvents))
        let hiddenCount = events.count - slotsForEvents
        return (visible, hiddenCount)
    }
}
