import SwiftUI

public struct CalendarGridView: View {
    @ObservedObject var viewModel: CalendarViewModel

    public init(viewModel: CalendarViewModel) {
        self.viewModel = viewModel
    }

    private let columns = 7
    private let rows = 4

    private var weekdayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = viewModel.timeZone
        formatter.dateFormat = "E"
        return formatter
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Weekday Header Bar
            HStack(spacing: 0) {
                ForEach(0..<columns, id: \.self) { colIndex in
                    if colIndex < viewModel.dayCells.count {
                        let date = viewModel.dayCells[colIndex].date
                        Text(weekdayFormatter.string(from: date))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)

                        if colIndex < columns - 1 {
                            Divider()
                                .frame(height: 14)
                                .background(Color.white.opacity(0.12))
                        }
                    } else {
                        Spacer()
                    }
                }
            }
            .background(Color(red: 0.14, green: 0.14, blue: 0.15))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.white.opacity(0.12)),
                alignment: .bottom
            )

            // Continuous 7x4 Grid Table
            GeometryReader { geometry in
                let totalWidth = geometry.size.width
                let totalHeight = geometry.size.height
                let cellWidth = totalWidth / CGFloat(columns)
                let cellHeight = totalHeight / CGFloat(rows)

                ZStack(alignment: .topLeading) {
                    // Grid Cells
                    VStack(spacing: 0) {
                        ForEach(0..<rows, id: \.self) { rowIndex in
                            HStack(spacing: 0) {
                                ForEach(0..<columns, id: \.self) { colIndex in
                                    let index = rowIndex * columns + colIndex
                                    if index < viewModel.dayCells.count {
                                        let cellData = viewModel.dayCells[index]
                                        DayCellView(
                                            cellData: cellData,
                                            onSelectDay: { date in
                                                viewModel.selectDay(date)
                                            },
                                            onSelectEvent: { event in
                                                viewModel.selectEvent(event)
                                            }
                                        )
                                        .frame(width: cellWidth, height: cellHeight)
                                    } else {
                                        Spacer()
                                            .frame(width: cellWidth, height: cellHeight)
                                    }
                                }
                            }
                        }
                    }

                    // Continuous Grid Divider Lines
                    // Horizontal Lines
                    VStack(spacing: 0) {
                        ForEach(1..<rows, id: \.self) { _ in
                            Spacer()
                                .frame(height: cellHeight - 1)
                            Rectangle()
                                .fill(Color.white.opacity(0.12))
                                .frame(height: 1)
                        }
                    }
                    .allowsHitTesting(false)

                    // Vertical Lines
                    HStack(spacing: 0) {
                        ForEach(1..<columns, id: \.self) { _ in
                            Spacer()
                                .frame(width: cellWidth - 1)
                            Rectangle()
                                .fill(Color.white.opacity(0.12))
                                .frame(width: 1)
                        }
                    }
                    .allowsHitTesting(false)
                }
                .onAppear {
                    viewModel.updateAvailableCellHeight(cellHeight)
                }
                .onChange(of: geometry.size) { _, newSize in
                    let newCellHeight = newSize.height / CGFloat(rows)
                    viewModel.updateAvailableCellHeight(newCellHeight)
                }
            }
        }
        .background(Color(red: 0.12, green: 0.12, blue: 0.13))
    }
}
