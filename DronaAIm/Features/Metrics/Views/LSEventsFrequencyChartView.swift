//
//  LSEventsFrequencyChartView.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 9/10/24.
//

import Foundation
import SwiftUI
import Charts

struct LSEventsFrequencyChartView: View {
    @State private var selectedDate: Date? = nil
    @State private var selectedPrice: Double? = nil
    @GestureState private var dragLocation: CGPoint = .zero
    let height: CGFloat // Add a height parameter

    // Sample data for the last 31 days
    let sampleData: [DataPoint] = (0..<31).map { day in
        let date = Calendar.current.date(byAdding: .day, value: -day, to: Date())!
        return DataPoint(date: date, value: Double.random(in: 5...20))
    }.reversed() // Reverse to make sure the most recent date is last
    

    var body: some View {
        Chart {
            // Solid Line
            ForEach(sampleData) { dataPoint in
                LineMark(
                    x: .value("Date", dataPoint.date),
                    y: .value("Value", dataPoint.value)
                )
                .foregroundStyle(.blue)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .foregroundStyle(by: .value("Plot", "Driver Score"))
            }

            // Vertical line, circle, and annotation at selected date
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
                        .offset(y: -20)
                }
            }
        }
        .chartLegend(.hidden)  // This hides the default legend
        .frame(height: height)
        .padding()
        .chartYAxis {
            AxisMarks(position: .leading) {
                AxisValueLabel()
                AxisGridLine()
            }
        }
        .chartXAxis {
            AxisMarks(values: xAxisLabels()) {
                AxisValueLabel(format: .dateTime.day().month())
                AxisGridLine()
            }
        }
        .chartYScale(domain: 0...20) // Update this based on your data's range
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($dragLocation) { value, state, _ in
                    state = value.location
                }
                .onChanged { value in
                    if let closestDataPoint = getClosestDataPoint(to: value.location.x) {
                        selectedDate = closestDataPoint.date
                        selectedPrice = closestDataPoint.value
                    }
                }
                .onEnded { _ in
                    selectedDate = nil
                    selectedPrice = nil
                }
        )
    }
    
    // Function to find the closest data point based on the drag location
    private func getClosestDataPoint(to x: CGFloat) -> DataPoint? {
        let chartWidth = UIScreen.main.bounds.width - 40 // Adjust for padding
        let index = Int((x / chartWidth) * CGFloat(sampleData.count))
        return sampleData[safe: min(max(index, 0), sampleData.count - 1)]
    }
    
    // Function to format date as "21 Jun"
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: date)
    }
    
    // Function to calculate labels for X-Axis
    private func xAxisLabels() -> [Date] {
        let totalDates = sampleData.count
        let step = max(1, totalDates / 4)
        return stride(from: 0, to: totalDates, by: step).map { sampleData[$0].date }
    }
}
