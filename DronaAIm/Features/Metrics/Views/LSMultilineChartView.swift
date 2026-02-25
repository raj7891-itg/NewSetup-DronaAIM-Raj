//
//  LSMultilineChart.swift
//  SampleChart
//
//  Created by Siva Kumar Reddy on 9/6/24.
//

import Foundation
import SwiftUI
import Charts

class LSMultilibeViewModel: ObservableObject {
    @Published var data: [LSMultilineChartModel] = []
    @Published var selectedTimeRange: TimeRange = .week
}

struct LSMultilineChartView: View {
    @ObservedObject var viewModel: LSMultilibeViewModel
    let height: CGFloat

    @State private var selectedCategory: String? = nil
    @State private var selectedDate: Date? = nil
    @State private var selectedValue: Double? = nil
    @State private var selectedColor: Color? = nil
    @State private var dragLocation: CGPoint = .zero
    @State private var dragEnabled = false

    var categories: [String: [LSMultilineChartModel]] {
        let groupedEvents = Dictionary(grouping: viewModel.data, by: { $0.title })
        return groupedEvents
    }
    
    var filteredData: [LSMultilineChartModel] {
        if let selectedCategory = selectedCategory {
            return viewModel.data.filter { $0.title == selectedCategory && $0.eventCount > 0 }
        } else {
            return viewModel.data.filter { $0.eventCount > 0 }
        }
    }
    
    func eventsCountFor(eventType: String) -> Int {
        let eventCounts = filteredData.filter { $0.title == eventType }
        return eventCounts.count
    }
    
    var body: some View {
        VStack {
            if filteredData.isEmpty {
                Text("Data not available")
                    .font(Font.system(size: 14))
                    .foregroundColor(.gray)
                    .padding()
            } else {
            // Multiline Chart
            Chart {
                ForEach(filteredData) { event in
                    LineMark(
                        x: .value("Date", event.date),
                        y: .value("Value", event.value)
                    )
                    .foregroundStyle(event.color)
                    .foregroundStyle(by: .value("Category", event.title))
                    .interpolationMethod(.linear)
                    if eventsCountFor(eventType: event.title) == 1 {
                        PointMark(
                            x: .value("Date", event.date),
                            y: .value("Value", event.value)
                        )
                        .symbol(Circle())
                        .foregroundStyle(event.color)
                    }
                }
                
                // Display value and date for the selected point
                if let selectedDate, let selectedValue, let selectedColor {
                    RuleMark(x: .value("Selected Date", selectedDate))
                        .foregroundStyle(Color.black)
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [4, 2]))
                    
                    PointMark(x: .value("Selected Date", selectedDate), y: .value("Selected Value", selectedValue))
                        .foregroundStyle(selectedColor)
                        .annotation(position: .top, alignment: .center) {
                            Text("\(selectedValue, specifier: "%.1f") | \(formattedDate(selectedDate))")
                                .font(.caption)
                                .padding(4)
                                .background(Color.white)
                                .cornerRadius(5)
                                .shadow(radius: 2)
                                .offset(y: -20)
                        }
                }
            }
            .chartLegend(.hidden)
            .frame(height: height)
            .padding()
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisValueLabel()
                    AxisGridLine()
                }
            }
            .chartXAxis {
                AxisMarks(values: xAxisLabels()) { value in
                    if let dateValue = value.as(Date.self) {
                        AxisValueLabel {
                            Text(xAxisValueFormatter(dateValue))
                        }
                    } else {
                        AxisValueLabel() // fallback if value isn't a date
                    }
                    AxisGridLine()
                }
            }
            .chartXScale(domain: xAxisDomain()) // Adjust the X-Axis scale domain
            .chartYScale(domain: minYValue...maxYValue)
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(
                            SpatialTapGesture()
                                .onChanged({ value in
                                })
                                .onEnded { value in
                                    dragLocation = value.location
                                }
                                .exclusively(before: LongPressGesture(minimumDuration: 0.5)
                                    .onEnded({ _ in
                                        let generator = UIImpactFeedbackGenerator(style: .medium)
                                        generator.impactOccurred()
                                        
                                        if let closestDataPoint = getClosestDataPoint(to: dragLocation.x) {
                                            selectedDate = closestDataPoint.date
                                            selectedValue = closestDataPoint.value
                                            selectedColor = closestDataPoint.color
                                        }
                                    })
                                        .simultaneously(with:
                                                            DragGesture(minimumDistance: 0)
                                            .onChanged({ value in
                                                if let closestDataPoint = getClosestDataPoint(to: value.location.x) {
                                                    selectedDate = closestDataPoint.date
                                                    selectedValue = closestDataPoint.value
                                                    selectedColor = closestDataPoint.color
                                                }
                                            })
                                                .onEnded { _ in
                                                    selectedDate = nil
                                                    selectedValue = nil
                                                    selectedColor = nil
                                                }
                                                       )
                                )
                        )
                }
            }
            // Category legends
            VStack {
                ForEach(categories.keys.sorted(), id: \.self) { category in
                    let color = categories[category]?.first?.color ?? .gray
                    
                    HStack {
                        Circle()
                            .fill(color)
                            .frame(width: 10, height: 10)
                        Text(category)
                            .onTapGesture {
                                toggleCategorySelection(category)
                            }
                            .foregroundColor(selectedCategory == category ? color : .black)
                        
                        Spacer()
                        Text("\(viewModel.data.filter { $0.title == category }.map { $0.value }.reduce(0, +), specifier: "%.0f") events")
                            .foregroundColor(selectedCategory == category ? color : .black)
                    }
                    Divider()
                }
            }
            .padding(.horizontal)
        }
        }
    }
    
    var minYValue: Double {
        return viewModel.data.map { $0.value }.min() ?? 0
    }

    var maxYValue: Double {
        return max(20, (viewModel.data.map { $0.value }.max() ?? 20) + 20)
    }

    // Toggle category selection
    private func toggleCategorySelection(_ category: String) {
        if selectedCategory == category {
            selectedCategory = nil // Show all if deselected
        } else {
            selectedCategory = category // Filter by category
        }
    }
    
    // Get the closest data point for the given x position
    private func getClosestDataPoint(to x: CGFloat) -> LSMultilineChartModel? {
        let chartWidth = UIScreen.main.bounds.width
        let index = Int((x / chartWidth) * CGFloat(filteredData.count))
        return filteredData[safe: min(max(index, 0), filteredData.count - 1)]
    }
        
    // Function to format date as "21 Jun"
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: date)
    }
    
    private func xAxisValueFormatter(_ date: Date) -> String {
            let formatter = DateFormatter()
            // Switch case to conditionally set the date format
            switch viewModel.selectedTimeRange {
            case .year:
                formatter.dateFormat = "MMM"  // Only display month for year range
            case .month, .custom, .week:
                formatter.dateFormat = "dd MMM"  // Display day and month for month range
            }

            return formatter.string(from: date)
    }
    
    // Function to calculate labels for X-Axis
    private func xAxisLabels() -> [Date] {
        let calendar = Calendar.current
        let today = Date()

        switch viewModel.selectedTimeRange {
        case .week:
            // Get last 7 days including today
            let allDays = (0..<7).compactMap { dayOffset in
                calendar.date(byAdding: .day, value: -dayOffset, to: today)
            }

            // Limit to 5 evenly spaced days, then reverse
            let selectedDays = stride(from: 0, to: allDays.count, by: max(1, allDays.count / 3)).map { allDays[$0] }
            return selectedDays.reversed() // Reverse after selection

        case .month(let month):
            // Assume current year for the selected month
            let currentYear = calendar.component(.year, from: today)
            let startOfMonth = calendar.date(from: DateComponents(year: currentYear, month: month))!
            let daysInMonth = calendar.range(of: .day, in: .month, for: startOfMonth)!.count
            
            // Get all days in the selected month
            let allDays = stride(from: 0, to: daysInMonth, by: 1).compactMap { dayOffset in
                calendar.date(byAdding: .day, value: dayOffset, to: startOfMonth)
            }

            // Limit to 5 evenly spaced days
            return stride(from: 0, to: allDays.count, by: max(1, allDays.count / 4)).map { allDays[$0] }

        case .year(let year):
            // Start of the year
            let startOfYear = calendar.date(from: DateComponents(year: year))!
            let allMonths = (0..<12).compactMap { monthOffset in
                calendar.date(byAdding: .month, value: monthOffset, to: startOfYear)
            }
            let currentDate = Date()
            let startOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
            var filterMonths = stride(from: 0, to: allMonths.count, by: max(1, allMonths.count / 5)).map { allMonths[$0] }
            filterMonths.append(startOfCurrentMonth)
            // Limit to 5 evenly spaced months
            return filterMonths
        case .custom(let start, let end):
            // Get all days between the start and end dates
            let allDays = stride(from: 0, to: Calendar.current.dateComponents([.day], from: start, to: end).day! + 1, by: 1).compactMap { dayOffset in
                Calendar.current.date(byAdding: .day, value: dayOffset, to: start)
            }

            // Limit to 5 evenly spaced days
            return stride(from: 0, to: allDays.count, by: max(1, allDays.count / 4)).map { allDays[$0] }

        }
    }

    // Function to define the X-axis domain
    private func xAxisDomain() -> ClosedRange<Date> {
        let calendar = Calendar.current
        let today = Date()
        
        switch viewModel.selectedTimeRange {
            case .week:
                let today = Date()
                let weekAgo = calendar.date(byAdding: .day, value: -7, to: today)!
                return weekAgo...today // Changed to '...'

            case .month(let month):
            let currentYear = calendar.component(.year, from: today)
                let startOfMonth = calendar.date(from: DateComponents(year: currentYear, month: month))!
                let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
                return startOfMonth...endOfMonth // Changed to '...'

            case .year(let year):
                let startOfYear = calendar.date(from: DateComponents(year: year))!
                let endOfYear = calendar.date(byAdding: .year, value: 1, to: startOfYear)!
                return startOfYear...endOfYear // Changed to '...'
            
        case .custom(let start, let end):
            return start...end

        }

    }


}
