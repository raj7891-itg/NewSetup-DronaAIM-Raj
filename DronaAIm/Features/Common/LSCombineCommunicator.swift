//
//  LSCombineCommunicator.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 9/5/24.
//

import UIKit
import Combine

enum LSActionType {
    case assignVehicle(AssignVehicle)
    case datePicker(DatePickerAction)
//    case filter(FilterAction, type: LSChartFilterType)
    case download(DownloadAction)
    case preview(PreviewAction)
    case chartFilterAction(ChartFilterAction)
    case updateProfileImage(url: URL?)
    
    enum AssignVehicle {
        case success(vehicle: LSVehicle)
    }
    enum DatePickerAction {
        case done(date: Date)
    }
    
    enum ChartFilterAction {
        case startAndEndDates(start: Int64, end: Int64, timeRange: TimeRange, chartType: LSChartType)
    }

    enum FilterAction {
        case presentsFilter
        case remoDropdown(title: String, button: UIButton)
        case applyFilter(params: [String: String], start: Date, end: Date)
        case removeFilter
    }
    
    enum DownloadAction {
        case startDownload
        case pauseDownload
        case cancelDownload
    }
    
    enum PreviewAction {
        case startPreview
        case stopPreview
    }
}

class LSCombineCommunicator {
    // Single subject for all action types
    private let subject = PassthroughSubject<LSActionType, Never>()
    
    // Singleton instance
    static let shared = LSCombineCommunicator()
    
    // Publisher to allow subscribers to listen to all events
    var publisher: AnyPublisher<LSActionType, Never> {
        subject.eraseToAnyPublisher()
    }
    
    // Methods to send values for each action type
    func send(_ action: LSActionType) {
        subject.send(action)
    }
}

