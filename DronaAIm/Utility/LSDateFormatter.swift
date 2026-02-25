//
//  LSDateFormatter.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 12/07/24.
//

import Foundation

enum LSDateFormat: String {
    case UsStandardDate = "MM/dd/yyyy"
    case MMMdHmmazzz = "MMM d, h:mm a zzz"
    case MMMdHmma = "MMM d, YYYY | h:mm a"
    case MMMdYYYHmmaComma = "MMM d, YYYY, h:mm a"
    case ddMMM = "dd MMM yy"
    case hmm = "h:mm a"

}

class LSDateFormatter {
    
    // Singleton instance for shared usage
    static let shared = LSDateFormatter()
    
    private init() {
    }
    
    func convertDateToTimeStamp(for date: Date) -> String {
        let timestampInMilliseconds = Int(date.timeIntervalSince1970 * 1000)
        return String(timestampInMilliseconds)
    }
    
    func convertDateToInt(for date: Date) -> Int {
        let timestampInMilliseconds = Int(date.timeIntervalSince1970 * 1000)
        return timestampInMilliseconds
    }
    
    func convertDateToMMMMddYYYY(from: Date) -> String {
        // Create a DateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        //dateFormatter.timeZone = TimeZone.current
        
        // Convert Date to a human-readable string
        let dateString = dateFormatter.string(from: from)
        
        return dateString
        
    }
    
    func convertDateToUsStandardDate(from: Date) -> String {
        // Create a DateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
       // dateFormatter.timeZone = TimeZone.current
        
        // Convert Date to a human-readable string
        let dateString = dateFormatter.string(from: from)
        
        return dateString
        
    }
    
    func convertToDate(from: String) -> Date? {
        // Create a DateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        //dateFormatter.timeZone = TimeZone.current
        
        // Convert Date to a human-readable string
        let dateString = dateFormatter.date(from: from)
        return dateString
        
    }
    
    func convertTimestampToDate(from: Double, format: LSDateFormat, timezone: String = "") -> String? {
        // Determine if the timestamp is in seconds or milliseconds
        let date: Date
        if from > 1_000_000_000_000 {
            // Timestamp is in milliseconds
            date = Date(timeIntervalSince1970: from / 1000)
        } else {
            // Timestamp is in seconds
            date = Date(timeIntervalSince1970: from)
        }
        
        // Create a DateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        if timezone.count > 0 {
            dateFormatter.timeZone = TimeZone(abbreviation: timezone)
        }
        // Convert Date to a human-readable string
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
    
    func convertTimestampDate(from: Double, format: LSDateFormat) -> Date? {
        // Determine if the timestamp is in seconds or milliseconds
        let date: Date
        if from > 1_000_000_000_000 {
            // Timestamp is in milliseconds
            date = Date(timeIntervalSince1970: from / 1000)
        } else {
            // Timestamp is in seconds
            date = Date(timeIntervalSince1970: from)
        }
        
        // Create a DateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        //dateFormatter.timeZone = TimeZone.current
        
        // Convert Date to a human-readable string
        let dateString = dateFormatter.string(from: date)
        let datee = dateFormatter.date(from: dateString)
        return datee
    }
    
    func getMonthStartEndInMilliseconds(selectedShortMonth: String, year: Int) -> (start: Int64, end: Int64)? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"  // short month format (e.g., Jan, Feb)
        
        // Get the index of the selected month from Calendar's shortMonthSymbols
        guard let monthIndex = Calendar.current.shortMonthSymbols.firstIndex(of: selectedShortMonth) else {
            return nil  // If the month is invalid
        }
        
        // Create a date for the first day of the selected month and year
        var components = DateComponents()
        components.year = year
        components.month = monthIndex + 1  // Calendar months are 1-indexed
        components.day = 1

        let calendar = Calendar.current
        
        guard let startDate = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: startDate) else {
            return nil
        }
        
        // Get the end date of the month
        components.day = range.count
        guard let endDate = calendar.date(from: components) else {
            return nil
        }
        
        // Convert start and end dates to milliseconds since 1970
        let startMilliseconds = Int64(startDate.timeIntervalSince1970 * 1000)
        let endMilliseconds = Int64(endDate.timeIntervalSince1970 * 1000)
        
        return (startMilliseconds, endMilliseconds)
    }

    func getYearStartEndInMilliseconds(selectedYear: String) -> (start: Int64, end: Int64)? {
        guard let year = Int(selectedYear) else {
            return nil  // If the year is invalid
        }
        
        let calendar = Calendar.current
        var components = DateComponents()
        
        // Get the start date of the selected year
        components.year = year
        components.month = 1
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        guard let startDate = calendar.date(from: components) else {
            return nil
        }
        
        // Get the end date of the selected year
        components.month = 12
        components.day = 31
        guard let endDate = calendar.date(from: components)?.addingTimeInterval(86399) else {
            return nil
        }
        
        // Convert start and end dates to milliseconds since 1970
        let startMilliseconds = Int64(startDate.timeIntervalSince1970 * 1000)
        let endMilliseconds = Int64(endDate.timeIntervalSince1970 * 1000)
        
        return (startMilliseconds, endMilliseconds)
    }
    
    func getLast7DaysStartEndInMilliseconds() -> (start: Int64, end: Int64)? {
        let calendar = Calendar.current
        let now = Date()
        
        // Get the start date of the last 7 days
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: now) else {
            return nil
        }
        
        // Get the end date of the last 7 days (the current date)
        let endDate = now
        
        // Convert start and end dates to milliseconds since 1970
        let startMilliseconds = Int64(startDate.timeIntervalSince1970 * 1000)
        let endMilliseconds = Int64(endDate.timeIntervalSince1970 * 1000)
        
        return (startMilliseconds, endMilliseconds)
    }
    
    
    func getMonthIntValue(for selectedShortMonth: String) -> Int? {
        let months = Calendar.current.shortMonthSymbols
        if let index = months.firstIndex(of: selectedShortMonth) {
            // Calendar months are 1-indexed, so add 1 to the index
            return index + 1
        }
        return nil  // Return nil if the month is not found
    }
}
