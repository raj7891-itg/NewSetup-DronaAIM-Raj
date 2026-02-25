//
//  LSMetricsEventsModel.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 9/17/24.
//

import Foundation
import SwiftUI

struct LSEventKey: Hashable {
    let date: Date
    let eventType: LSDAllEventType
}

struct LSMultilineChartModel: Identifiable {
    let title: String
    let value: Double
    let eventCount: Int
    let color: Color
    let date: Date
    var id: String {
        title
    }
}

// MARK: - LSMetricsEventsModel
struct LSMetricsEventsModel: Codable {
    let allEvents: [LSAllEventMetadata]
}

// MARK: - AllEvent
struct LSAllEventMetadata: Codable {
    let tsInMilliSeconds: Double
    let eventType: LSDAllEventType
    
}

extension LSMetricsEventsModel {
    func groupEventsForPieChart() -> [LSPieChartModel] {
        let groupedEvents = Dictionary(grouping: allEvents, by: { $0.eventType })
        let totalEvents = allEvents.count
        
        // Convert to array for PieChartView
        return groupedEvents.map { (eventType, events) in
            let percentage = (Double(events.count) / Double(totalEvents)) * 100
            let roundedPercentage = Int(ceil(percentage)) // Round up to the nearest whole number

            print("Percentage = ", roundedPercentage)
            let color = getIncidentTypeColor(eventType: eventType)
            let title = getIncidentType(eventType: eventType)
            let event = LSPieChartModel(title: title, value: percentage, eventCount: events.count, color: color, totalEvents: totalEvents)
            return event
        }
    }
    func groupedMultilineChartModels() -> [LSMultilineChartModel] {
        // Step 1: Group events by date and event type
        let groupedEvents = Dictionary(grouping: allEvents, by: { event -> LSEventKey? in
            guard let date = LSDateFormatter.shared.convertTimestampDate(from: event.tsInMilliSeconds, format: .UsStandardDate) else { return nil }
            return LSEventKey(date: date, eventType: event.eventType)
        })

        // Step 2: Convert the grouped events into LSMultilineChartModel
        var chartData: [LSMultilineChartModel] = []
        
        // Step 3: Find all unique event types that have no data (i.e., where count = 0)
        var eventTypesWithZeroAdded = Set<LSDAllEventType>() // Keep track of event types with 0 events

        // Step 4: For each grouped event, create a chart model
        for (key, events) in groupedEvents {
            if let key {
                let eventCount = events.count // Count of events of this type on this date
                let color = getIncidentTypeColor(eventType: key.eventType)
                let title = getIncidentType(eventType: key.eventType)

                // Create a chart model for the actual event data
                let chartModel = LSMultilineChartModel(
                    title: title,
                    value: Double(eventCount),
                    eventCount: eventCount,
                    color: color,
                    date: key.date
                )
                chartData.append(chartModel)
                
                // Step 5: For each event type, if it hasn't been added with 0 events, add it once
                for eventType in LSDAllEventType.allCases where !eventTypesWithZeroAdded.contains(eventType) {
                    if groupedEvents[LSEventKey(date: key.date, eventType: eventType)] == nil {
                        // Add the event type with 0 events for the first time
                        let zeroEventModel = LSMultilineChartModel(
                            title: getIncidentType(eventType: eventType),
                            value: 0.0,
                            eventCount: 0,
                            color: getIncidentTypeColor(eventType: eventType),
                            date: key.date
                        )
                        chartData.append(zeroEventModel)
                        eventTypesWithZeroAdded.insert(eventType) // Mark this eventType as having a 0 entry
                    }
                }
            }
        }

        // Step 6: Sort the chartData by date in ascending order
        let sortedChartData = chartData.sorted(by: { $0.date < $1.date })
        
        return sortedChartData
    }

}
