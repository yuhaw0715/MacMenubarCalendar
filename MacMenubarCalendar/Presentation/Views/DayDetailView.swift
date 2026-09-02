import SwiftUI

public struct DayDetailView: View {
    let date: Date
    let events: [CalendarEvent]
    let onSelectEvent: (CalendarEvent) -> Void
    let onOpenInCalendar: (Date) -> Void
    let onClose: () -> Void

    public init(
        date: Date,
        events: [CalendarEvent],
        onSelectEvent: @escaping (CalendarEvent) -> Void,
        onOpenInCalendar: @escaping (Date) -> Void,
        onClose: @escaping () -> Void
    ) {
        self.date = date
        self.events = events
        self.onSelectEvent = onSelectEvent
        self.onOpenInCalendar = onOpenInCalendar
        self.onClose = onClose
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
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
                        Text(AppStrings.localized("action.back"))
                            .font(.system(size: 12, weight: .medium))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.primary.opacity(0.08)))
                }
                .buttonStyle(.plain)

                Spacer()

                Text(dateFormatter.string(from: date))
                    .font(.system(size: 13, weight: .bold))

                Spacer()

                Button(action: { onOpenInCalendar(date) }) {
                    Label(AppStrings.localized("action.open_in_calendar"), systemImage: "calendar")
                        .font(.system(size: 11, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.accentColor.opacity(0.15)))
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                .help(AppStrings.localized("action.open_in_calendar"))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.primary.opacity(0.03))

            Divider()

            // Event List
            if events.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    Text(AppStrings.localized("day_detail.no_events"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 6) {
                        ForEach(events) { event in
                            Button(action: {
                                onSelectEvent(event)
                            }) {
                                HStack(spacing: 10) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(event.calendarColor)
                                        .frame(width: 4)

                                    VStack(alignment: .leading, spacing: 3) {
                                        HStack {
                                            Text(event.title.isEmpty ? AppStrings.localized("event.untitled") : event.title)
                                                .font(.system(size: 12.5, weight: .semibold))
                                                .foregroundColor(event.isStatusDeclined ? .secondary : .primary)
                                                .strikethrough(event.isStatusDeclined, color: .secondary)

                                            Spacer()

                                            if event.isAllDay {
                                                Text(AppStrings.localized("event.all_day"))
                                                    .font(.system(size: 10, weight: .semibold))
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(Capsule().fill(event.calendarColor))
                                            } else {
                                                Text("\(timeFormatter.string(from: event.startDate)) – \(timeFormatter.string(from: event.endDate))")
                                                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                                                    .foregroundColor(.secondary)
                                            }
                                        }

                                        HStack(spacing: 8) {
                                            Text(event.calendarTitle)
                                                .font(.caption)
                                                .foregroundColor(.secondary)

                                            if let location = event.location, !location.isEmpty {
                                                HStack(spacing: 2) {
                                                    Image(systemName: "mappin.and.ellipse")
                                                        .font(.system(size: 10))
                                                    Text(location)
                                                        .font(.caption)
                                                }
                                                .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                }
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 7)
                                        .fill(Color.primary.opacity(0.04))
                                 )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 7)
                                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(12)
                }
            }
        }
        .frame(minWidth: 420, minHeight: 320)
    }
}
