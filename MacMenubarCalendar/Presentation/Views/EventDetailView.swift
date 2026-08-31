import SwiftUI

public struct EventDetailView: View {
    let event: CalendarEvent
    let onOpenInCalendar: (CalendarEvent) -> Void
    let onClose: () -> Void

    public init(
        event: CalendarEvent,
        onOpenInCalendar: @escaping (CalendarEvent) -> Void,
        onClose: @escaping () -> Void
    ) {
        self.event = event
        self.onOpenInCalendar = onOpenInCalendar
        self.onClose = onClose
    }

    private var dateTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onClose) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 11, weight: .semibold))
                        Text("action.back")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.primary.opacity(0.08)))
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: { onOpenInCalendar(event) }) {
                    Label("action.open_in_calendar", systemImage: "calendar")
                        .font(.system(size: 11, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.accentColor.opacity(0.15)))
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.primary.opacity(0.03))

            Divider()

            // Details
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    // Title & Calendar Card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(event.calendarColor)
                                .frame(width: 8, height: 8)

                            Text(event.calendarTitle)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Text(event.title.isEmpty ? NSLocalizedString("event.untitled", comment: "") : event.title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(event.isStatusDeclined ? .secondary : .primary)
                            .strikethrough(event.isStatusDeclined, color: .secondary)

                        if event.isStatusDeclined {
                            Text("event.status.declined")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red.opacity(0.12))
                                .foregroundColor(.red)
                                .cornerRadius(4)
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.primary.opacity(0.04))
                    )

                    // Time & Location Card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "clock")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .frame(width: 16)

                            VStack(alignment: .leading, spacing: 2) {
                                if event.isAllDay {
                                    Text("event.all_day")
                                        .font(.system(size: 12, weight: .semibold))
                                    Text(dateFormatter.string(from: event.startDate))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("\(dateTimeFormatter.string(from: event.startDate)) – \(dateTimeFormatter.string(from: event.endDate))")
                                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                                        .foregroundColor(.primary)
                                }
                            }
                        }

                        if let location = event.location, !location.isEmpty {
                            Divider()
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                    .frame(width: 16)

                                Text(location)
                                    .font(.system(size: 12))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.primary.opacity(0.04))
                    )
                }
                .padding(14)
            }
        }
        .frame(minWidth: 420, minHeight: 320)
    }
}
