//
//  LSDashboardDriverScoreLineChartView.swift
//  DronaAIm
//
//  Line chart view for displaying driver score trends over time.
//  Supports multiple time ranges (week, month, year, custom) and interactive data visualization.
//

import Foundation
import SwiftUI
import Charts

enum TimeRange {
    case week
    case month(month: Int) // month is 1 for Jan, 12 for Dec
    case year(year: Int)
    case custom(start: Date, end: Date)
}

struct DataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}


class DriverScoreViewModel: ObservableObject {
    @Published var data: [Datum] = []
    @Published var selectedTimeRange: TimeRange = .week
}

struct LSDashboardDriverScoreLineChartView: View {
    @ObservedObject var viewModel: DriverScoreViewModel
    let height: CGFloat

    @State private var selectedDate: Date? = nil
    @State private var selectedPrice: Double? = nil
    @GestureState private var dragLocation: CGPoint = .zero

    var body: some View {
          VStack {
              if viewModel.data.isEmpty {
                  Text("Data not available")
                      .font(Font.system(size: 14))
                      .foregroundColor(.gray)
                      .padding()
              } else {
                  Chart {
                      // Solid Line for Mean Score
                      ForEach(meanScoreData(), id: \.date) { dataPoint in
                          LineMark(
                              x: .value("Date", dataPoint.date),
                              y: .value("Mean Score", dataPoint.value)
                          )
                          .foregroundStyle(Color.appValue)
                          .lineStyle(StrokeStyle(lineWidth: 2))
                          .foregroundStyle(by: .value("Plot", "Mean Score"))

                          // Add a dot (circle) at each data point to ensure visibility for single points
                          if meanScoreData().count == 1 {
                              PointMark(
                                x: .value("Date", dataPoint.date),
                                y: .value("Mean Score", dataPoint.value)
                              )
                              .symbol(Circle())
                              .foregroundStyle(Color.appValue)
                          }
                      }
                      // Dotted Line for Median Score
                      ForEach(medianScoreData(), id: \.date) { dataPoint in
                          LineMark(
                              x: .value("Date", dataPoint.date),
                              y: .value("Median Score", dataPoint.value)
                          )
                          .foregroundStyle(.black)
                          .lineStyle(StrokeStyle(lineWidth: 2, dash: [8, 4]))
                          .foregroundStyle(by: .value("Plot", "Median Score"))
                          
                          // Add a dot (circle) at each data point to ensure visibility for single points
                          if medianScoreData().count == 1 {
                              PointMark(
                                x: .value("Date", dataPoint.date),
                                y: .value("Mean Score", dataPoint.value)
                              )
                              .symbol(Circle())
                              .foregroundStyle(Color.appValue)
                          }
                      }
                      
                      // Vertical line, circle, and annotation at selected mean score
                      if let selectedDate, let selectedPrice {
                          RuleMark(x: .value("Selected Date", selectedDate))
                              .foregroundStyle(Color.black)
                              .lineStyle(StrokeStyle(lineWidth: 2, dash: [4, 2]))

                          PointMark(
                              x: .value("Selected Date", selectedDate),
                              y: .value("Selected Price", selectedPrice)
                          )
                          .foregroundStyle(Color.appGreen)
                          .annotation(position: .top, alignment: .center) {
                              Text("\(selectedPrice, specifier: "%.1f") | \(formattedDate(selectedDate))")
                                  .font(.caption)
                                  .padding(4)
                                  .background(Color.white)
                                  .cornerRadius(5)
                                  .shadow(radius: 2)
                                  .offset(y: 0)
                          }
                      }
                  }
                  .chartLegend(.hidden)
                  .frame(height: height)
                  .padding() // Adjust the value for desired padding
                  .padding(.top, 20) // Adjust the value for desired padding
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
                  .chartYScale(domain: 0...100)
                  .chartOverlay { proxy in
                      GeometryReader { geo in
                          Rectangle().fill(.clear).contentShape(Rectangle())
                              .gesture(
                                  SpatialTapGesture()
                                      .onChanged({ value in
                                      })
                                      .onEnded { value in
//                                          state = value.location
                                      }
                                      .exclusively(before: LongPressGesture(minimumDuration: 0.5)
                                          .onEnded({ _ in
                                              let generator = UIImpactFeedbackGenerator(style: .medium)
                                              generator.impactOccurred()
                                              
                                              if let closestDataPoint = getClosestMeanDataPoint(to: dragLocation.x) {
                                                  selectedDate = closestDataPoint.date
                                                  selectedPrice = closestDataPoint.value
                                              }
                                          })
                                              .simultaneously(with:
                                                                  DragGesture(minimumDistance: 0)
                                                .updating($dragLocation) { value, state, _ in
                                                    state = value.location
                                                }
                                                  .onChanged({ value in
                                                      if let closestDataPoint = getClosestMeanDataPoint(to: dragLocation.x) {
                                                          selectedDate = closestDataPoint.date
                                                          selectedPrice = closestDataPoint.value
                                                      }

                                                  })
                                                      .onEnded { _ in
                                                          selectedDate = nil
                                                          selectedPrice = nil
                                                      }
                                                )
                                      )
                              )
                      }
                  }
              }
          }
      }
    
    // Function to get mean score data points
    private func meanScoreData() -> [DataPoint] {
        return viewModel.data.compactMap { datum in
            guard let timestamp = datum.driverScoreTs, let meanScore = datum.meanScore else { return nil }
            let date = Date(timeIntervalSince1970: timestamp / 1000)
            return DataPoint(date: date, value: meanScore)
        }
    }
    
    // Function to get median score data points
    private func medianScoreData() -> [DataPoint] {
        return viewModel.data.compactMap { datum in
            guard let timestamp = datum.driverScoreTs, let medianScore = datum.medianScore else { return nil }
            let date = Date(timeIntervalSince1970: timestamp / 1000)
            return DataPoint(date: date, value: medianScore)
        }
    }

    // Function to find the closest mean score data point based on the drag location
    private func getClosestMeanDataPoint(to x: CGFloat) -> DataPoint? {
        let meanData = meanScoreData()
        let chartWidth = UIScreen.main.bounds.width - 40

        // Flip the mapping of x if dragging behavior is reversed
        let correctedX = chartWidth - x
        
        // Map drag location to data points
        let index = Int((correctedX / chartWidth) * CGFloat(meanData.count))
        return meanData[safe: min(max(index, 0), meanData.count - 1)]
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

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
