//
//  LSMetricsPieChartView.swift
//  DronaAIm
//
//  Custom SwiftUI pie chart view for displaying metrics data.
//  Shows event distribution and statistics in a visual pie chart format.
//

import SwiftUI
import Charts

struct LSPieChartModel: Identifiable, Equatable {
    let title: String
    let value: Double
    let eventCount: Int
    let color: Color
    let totalEvents: Int
    var id: String {
        title
    }
    static func == (lhs: LSPieChartModel, rhs: LSPieChartModel) -> Bool {
           return lhs.title == rhs.title &&
                  lhs.eventCount == rhs.eventCount &&
                  lhs.totalEvents == rhs.totalEvents &&
                  lhs.color == rhs.color
       }
}

struct LSMetricsPieChartView: View {
    let data: [LSPieChartModel] // Updated to accept an array of LSPieChartModel for multiple segments.
    let height: CGFloat
    var body: some View {
        if #available(iOS 17, *) {
            PieChartViewiOS17(data: data, height: height)
        } else {
        PieChartViewiOS16(data: data, height: height)
        }
    }
}

@available(iOS 17, *)
struct PieChartViewiOS17: View {
    let data: [LSPieChartModel] // Array of LSPieChartModel to display
    let height: CGFloat
    @State private var selectedCount: Int? // Store the selected angle as Double
    @State private var selectedSlice: LSPieChartModel? // Store the selected angle as Double
    
    var body: some View {
        VStack {
            if data.isEmpty {
                Text("Data not available")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                if let totalEvents = data.first?.totalEvents {
                    HStack {
                        Text("Total Events")
                            .padding(.top, 20)
                            .font(Font.system(size: 18))

                        Spacer() // This will push the second Text to the trailing side
                        Text("\(String(describing: totalEvents)) Events")
                            .padding(.top, 20)
                            .font(Font.system(size: 18))
                    }
                    .padding(.horizontal)
                    Chart(data) { eventType in
                        SectorMark(
                            angle: .value("Events", eventType.eventCount),
                            innerRadius: .ratio(0.65),
                            outerRadius: selectedSlice?.title == eventType.title ? .ratio(1) : .ratio(0.9)
                        )
                        .foregroundStyle(by: .value("EventType", eventType.title))
                        .foregroundStyle(eventType.color)
                    }
                    .chartForegroundStyleScale(
                        domain: data.map { $0.title }, // The EventType for the legend
                        range: data.map { $0.color }   // Corresponding colors for the chart sectors
                    )
                    .padding(.leading, 5)  // Set the leading padding to 20 points
                    .padding(.trailing, 5)
                    
                    .chartAngleSelection(value: $selectedCount)
                    .chartBackground { _ in
                        if let selectedSlice {
                            VStack {
                                // Image(systemName: "wineglass.fill")
                                //                                .font(.largeTitle)
                                //                                .foregroundStyle(Color(selectedWineType.color))
                                Text(selectedSlice.title)
                                    .font(Font.system(size: 12))
                                Text("\(selectedSlice.eventCount) events")
                            }
                        } else {
                            VStack {
                                Text("Total Events")
                                    .font(Font.system(size: 12))
                                Text("\(String(describing: totalEvents))")
                            }
                        }
                    }
                    .frame(width: 350, height: height)
                    Spacer()
                        .onChange(of: selectedCount) { oldValue, newValue in
                            if let newValue {
                                withAnimation {
                                    getSelectedWineType(value: newValue)
                                }
                            }
                        }
                        .padding()
                }
            }
        }
    }

    private func getSelectedWineType(value: Int) {
        var cumulativeTotal = 0
        let foundData = data.first { wineType in
            cumulativeTotal += wineType.eventCount
            return value <= cumulativeTotal
        }
        
        if let foundData {
            if selectedSlice?.title == foundData.title {
                selectedSlice = nil // Unselect if already selected
            } else {
                selectedSlice = foundData
            }
        } else {
            selectedSlice = nil
        }
    }
}

struct PieChartViewiOS16: View {
    let data: [LSPieChartModel]
    let height: CGFloat

    @State private var selectedSlice: LSPieChartModel?
    // Define grid columns for three items per row
    let columns = [
        GridItem(.flexible(), spacing: 5), // Flexible width with spacing
        GridItem(.flexible(), spacing: 5), // Flexible width with spacing
        GridItem(.flexible(), spacing: 5)  // Flexible width with spacing
    ]

    var body: some View {
        VStack {
            if data.isEmpty {
                Text("Data not available")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                if let totalEvents = data.first?.totalEvents {
                    HStack {
                        Text("Total Events")
                            .padding(.top, 10)
                            .font(Font.system(size: 18))

                        Spacer()
                        Text("\(totalEvents) Events")
                            .padding(.top, 10)
                            .font(Font.system(size: 18))
                    }
                    .padding(.horizontal)

                    GeometryReader { geometry in
                        ZStack {
                            ForEach(0..<data.count, id: \.self) { index in
                                let startAngle = angle(for: index)
                                let endAngle = angle(for: index + 1)
                                
                                Path { path in
                                    let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                                    let radius = min(geometry.size.width, geometry.size.height) / 2

                                    // Draw the outer arc
                                    path.move(to: center)
                                    path.addArc(center: center,
                                                radius: selectedSlice == data[index] ? radius : radius * 0.9,
                                                startAngle: startAngle,
                                                endAngle: endAngle,
                                                clockwise: false)
                                    
                                    // Cut out the inner arc
                                    path.addArc(center: center,
                                                radius: selectedSlice == data[index] ? radius * 0.6 : radius * 0.9 * 0.6,
                                                startAngle: endAngle,
                                                endAngle: startAngle,
                                                clockwise: true)
                                }
                                .fill(data[index].color)
                                .onTapGesture {
                                    withAnimation {
                                        if selectedSlice == data[index] {
                                            selectedSlice = nil
                                        } else {
                                            selectedSlice = data[index]
                                        }
                                    }
                                }
                            }

                            // Display the selected slice info or total events
                            VStack {
                                if let selectedSlice {
                                    Text(selectedSlice.title)
                                        .font(Font.system(size: 14))
                                    Text("\(selectedSlice.eventCount) events")
                                        .font(Font.system(size: 14))
                                } else {
                                    Text("Total Events")
                                        .font(Font.system(size: 14))
                                    Text("\(totalEvents)")
                                }
                            }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                    .frame(width: 250, height: 250)
                    // legends
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
                        ForEach(data, id: \.id) { item in
                            HStack {
                                Circle()
                                    .fill(item.color)
                                    .frame(width: 8, height: 8)
                                
                                Text(item.title)
                                    .font(.system(size: 10))
                                    .lineLimit(1)  // Ensure the title stays on one line
                                .padding(.leading, 5)
                            }
                        }
                        .chartSymbolSizeScale()
                    }
                    Spacer()
                }
            }
        }
        .padding()
    }

    // Function to calculate the angle for a slice
    private func angle(for index: Int) -> Angle {
        let total = data.reduce(0) { $0 + $1.eventCount }
        let cumulativeCount = data.prefix(index).reduce(0) { $0 + $1.eventCount }
        let angle = (Double(cumulativeCount) / Double(total)) * 360
        return .degrees(angle - 90) // Offset by -90 to start at the top
    }
}

struct PieSlice: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var padding: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = rect.width / 2
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        
        let insetPath = path.trimmedPath(from: CGFloat(padding), to: CGFloat(1.0 - padding))
        return insetPath
    }
}
