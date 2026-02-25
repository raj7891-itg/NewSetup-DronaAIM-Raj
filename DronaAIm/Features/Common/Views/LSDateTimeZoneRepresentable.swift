//
//  LSDateTimezoneRepresentable.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 07/11/24.
//

protocol LSDateTimezoneRepresentable {
    var startLocalizedTsInMilliSeconds: Double? { get }
    var startTzAbbreviation: String? { get }
    var startDate: Double? { get }
    var endLocalizedTsInMilliSeconds: Double? { get }
    var endTzAbbreviation: String? { get }
    var endDate: Double? { get }
    
    func startDateAndTimeZone(format: LSDateFormat) -> String
    func endDateAndTimeZone(format: LSDateFormat) -> String
}

extension LSDateTimezoneRepresentable {
    func startDate(format: LSDateFormat) -> String {
        if let startDate = startDate {
            if let startTimeZone = startTzAbbreviation,
               let startDateTime = LSDateFormatter.shared.convertTimestampToDate(from: startDate, format: format, timezone: startTimeZone) {
                return "\(startDateTime)"
            } else if let startDateTime = LSDateFormatter.shared.convertTimestampToDate(from: startDate, format: format)  {
                return startDateTime
            }
        }
        return ""
    }
        
        func endDate(format: LSDateFormat) -> String {
            if let endDate = endDate {
                if let endTimeZone = endTzAbbreviation,
                   let startDateTime = LSDateFormatter.shared.convertTimestampToDate(from: endDate, format: format, timezone: endTimeZone) {
                    return "\(startDateTime)"
                } else if let endDateTime = LSDateFormatter.shared.convertTimestampToDate(from: endDate, format: format) {
                    return "\(String(describing: endDateTime))"
                }
            }
            return ""
        }
    func startDateAndTimeZone(format: LSDateFormat) -> String {
        if let startDate = startDate {
            if let startTimeZone = startTzAbbreviation,
               let startDateTime = LSDateFormatter.shared.convertTimestampToDate(from: startDate, format: format, timezone: startTimeZone) {
                return "\(startDateTime) \(startTimeZone)"
            } else if let startDateTime = LSDateFormatter.shared.convertTimestampToDate(from: startDate, format: format)  {
                return startDateTime
            }
        }
        return ""
    }
        
        func endDateAndTimeZone(format: LSDateFormat) -> String {
            if let endDate = endDate {
                if let endTimeZone = endTzAbbreviation,
                   let startDateTime = LSDateFormatter.shared.convertTimestampToDate(from: endDate, format: format, timezone: endTimeZone) {
                    return "\(startDateTime) \(endTimeZone)"
                } else if let endDateTime = LSDateFormatter.shared.convertTimestampToDate(from: endDate, format: format) {
                    return "\(String(describing: endDateTime))"
                }
            }
            return ""
        }
    
}
