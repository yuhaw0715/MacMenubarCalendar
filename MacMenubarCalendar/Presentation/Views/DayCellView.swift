import SwiftUI

public struct DayCellView: View {
    let cellData: DayCellData
    let onSelectDay: (Date) -> Void
    let onSelectEvent: (CalendarEvent) -> Void

    @State private var isHovered: Bool = false

    public init(
        cellData: DayCellData,
        onSelectDay: @escaping (Date) -> Void,
        onSelectEvent: @escaping (CalendarEvent) -> Void
    ) {
        self.cellData = cellData
        self.onSelectDay = onSelectDay
        self.onSelectEvent = onSelectEvent
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    private var accessibilityString: String {
        let dateStr = dateFormatter.string(from: cellData.date)
        let todayStr = cellData.isToday ? ", 今日" : ""
        let eventsCount = cellData.events.count
        let countStr = eventsCount > 0 ? ", \(eventsCount) 個行程" : ", 無行程"
        return "\(dateStr)\(todayStr)\(countStr)"
    }

    private var lunarInfo: (text: String, isFirstDayOfMonth: Bool) {
        LunarDateHelper.lunarString(for: cellData.date)
    }

    private var isZhLocale: Bool {
        AppStrings.currentLanguage.isChinese()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Header Row: Lunar Date on Left, Solar Date on Right
            HStack(alignment: .center) {
                // Lunar Date (Left)
                if isZhLocale && !lunarInfo.text.isEmpty {
                    Text(lunarInfo.text)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(lunarInfo.isFirstDayOfMonth ? Color(red: 0.95, green: 0.4, blue: 0.4) : Color.white.opacity(0.45))
                        .underline(lunarInfo.isFirstDayOfMonth, color: Color(red: 0.95, green: 0.4, blue: 0.4))
                }

                Spacer()

                // Solar Date (Right)
                if cellData.isToday {
                    HStack(spacing: 2) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 0.94, green: 0.28, blue: 0.28), Color(red: 0.82, green: 0.18, blue: 0.18)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 18, height: 18)
                            .shadow(color: Color.red.opacity(0.35), radius: 2, x: 0, y: 1)
                            .overlay(
                                Text("\(cellData.dayNumber)")
                                    .font(.system(size: 10.5, weight: .bold))
                                    .foregroundColor(.white)
                            )

                        if isZhLocale {
                            Text("日")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(.white.opacity(0.85))
                        }
                    }
                } else {
                    Text(LunarDateHelper.solarDayString(for: cellData.date, calendar: Calendar.current))
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.white.opacity(0.85))
                }
            }
            .padding(.top, 3)
            .padding(.horizontal, 3)

            // Events List in Cell
            VStack(alignment: .leading, spacing: 2) {
                ForEach(cellData.visibleEvents) { event in
                    Button(action: {
                        onSelectEvent(event)
                    }) {
                        if event.isAllDay {
                            // All-day Event Banner
                            HStack(spacing: 2) {
                                Text(event.title.isEmpty ? AppStrings.localized("event.untitled") : event.title)
                                    .font(.system(size: 9.5, weight: .semibold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 3)
                            .padding(.vertical, 1.5)
                            .frame(height: 16)
                            .background(
                                RoundedRectangle(cornerRadius: 2.5)
                                    .fill(event.calendarColor.opacity(0.92))
                            )
                        } else {
                            // Timed Event Row: Dot + Title on Left, Time on Right
                            HStack(spacing: 2.5) {
                                Circle()
                                    .fill(event.calendarColor)
                                    .frame(width: 4.5, height: 4.5)

                                Text(event.title.isEmpty ? AppStrings.localized("event.untitled") : event.title)
                                    .font(.system(size: 9.5, weight: .regular))
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .foregroundColor(event.isStatusDeclined ? .white.opacity(0.4) : .white.opacity(0.92))
                                    .strikethrough(event.isStatusDeclined, color: .white.opacity(0.4))

                                Spacer(minLength: 1)

                                Text(timeFormatter.string(from: event.startDate))
                                    .font(.system(size: 8.5, weight: .regular, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.55))
                            }
                            .padding(.horizontal, 2)
                            .frame(height: 16)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(event.title), \(event.calendarTitle)\(event.isStatusDeclined ? ", 已拒絕" : "")")
                }

                // Overflow Badge "+N 個"
                if cellData.hiddenCount > 0 {
                    Button(action: {
                        onSelectDay(cellData.date)
                    }) {
                        Text(AppStrings.localizedFormat("cell.more_events", cellData.hiddenCount))
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 2)
                            .padding(.vertical, 1)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(AppStrings.localizedFormat("cell.more_events", cellData.hiddenCount))
                }
            }
            .padding(.horizontal, 2)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(isHovered ? Color.white.opacity(0.08) : (cellData.isToday ? Color.white.opacity(0.05) : Color.white.opacity(0.025)))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.white.opacity(isHovered ? 0.16 : 0.06), lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .shadow(color: isHovered ? Color.black.opacity(0.2) : Color.clear, radius: 2, x: 0, y: 1)
        .contentShape(RoundedRectangle(cornerRadius: 4))
        .animation(.easeInOut(duration: 0.12), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            onSelectDay(cellData.date)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityString)
    }
}
