import SwiftUI

public struct CalendarGridView: View {
    @ObservedObject var viewModel: CalendarViewModel

    public init(viewModel: CalendarViewModel) {
        self.viewModel = viewModel
    }

    private let columns = 7
    private let rows = 4

    public var body: some View {
        let weekdayHeaders = viewModel.weekdayHeaders

        VStack(spacing: 0) {
            // Weekday Header Bar
            HStack(spacing: 0) {
                ForEach(0..<columns, id: \.self) { colIndex in
                    if colIndex < weekdayHeaders.count {
                        Text(weekdayHeaders[colIndex])
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.65))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)

                        if colIndex < columns - 1 {
                            Divider()
                                .frame(height: 12)
                                .background(Color.white.opacity(0.08))
                        }
                    } else {
                        Spacer()
                    }
                }
            }
            .background(Color.white.opacity(0.04))
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color.white.opacity(0.08)),
                alignment: .bottom
            )

            // Continuous 7x4 Soft Island Grid (Style C-4)
            GeometryReader { geometry in
                let gap: CGFloat = 1.5
                let horizontalPadding: CGFloat = 4
                let verticalPadding: CGFloat = 4

                let availableWidth = geometry.size.width - (horizontalPadding * 2)
                let availableHeight = geometry.size.height - (verticalPadding * 2)

                let cellWidth = max(0, (availableWidth - CGFloat(columns - 1) * gap) / CGFloat(columns))
                let cellHeight = max(0, (availableHeight - CGFloat(rows - 1) * gap) / CGFloat(rows))

                VStack(spacing: gap) {
                    ForEach(0..<rows, id: \.self) { rowIndex in
                        HStack(spacing: gap) {
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
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .onAppear {
                    viewModel.updateAvailableCellHeight(cellHeight)
                }
                .onChange(of: geometry.size) { _, newSize in
                    let newAvailHeight = newSize.height - (verticalPadding * 2)
                    let newCellHeight = max(0, (newAvailHeight - CGFloat(rows - 1) * gap) / CGFloat(rows))
                    viewModel.updateAvailableCellHeight(newCellHeight)
                }
            }
        }
        .background(Color.clear)
    }
}
