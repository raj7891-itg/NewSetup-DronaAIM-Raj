//
//  LSDEventViewModel.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 29/06/24.
//

import Foundation

class LSDEventViewModel {
    private var events: [LSDAllEvents] = []
    private var filteredEvents: [LSDAllEvents] = []
    var pageDetails: PageDetails?

    func fetchAllEvents(parameters: [String : String], requestbody: LSRequstEvents) async throws {
        self.events.removeAll()
        if let userDetails = UserDefaults.standard.userDetails {
            let userId = userDetails.userId
            let endpoint = LSAPIEndpoints.allEventsByUserId(for: userId)
            do {
                let response: LSDAllEventsModel = try await LSNetworkManager.shared.post(endpoint, body: requestbody  , parameters: parameters)
                if let allEvents = response.allEvents {
                    self.events = allEvents
                    self.pageDetails = response.pageDetails
                    print("User Id = ", userDetails.userId)
                    print("Events Count =", self.events.count)
                }
            } catch {
                print(error)
                throw error // Rethrow the error so the caller can handle it
            }
        }
    }
    
    func loadMoreEvents(parameters: [String : String], requestbody: LSRequstEvents) async throws {
        if let userDetails = UserDefaults.standard.userDetails {
            let userId = userDetails.userId
            let endpoint = LSAPIEndpoints.allEventsByUserId(for: userId)
            do {
                let response: LSDAllEventsModel = try await LSNetworkManager.shared.post(endpoint, body: requestbody  , parameters: parameters)
                if let allEvents = response.allEvents {
                    self.events += allEvents
                    self.pageDetails = response.pageDetails
                    print("User Id = ", userDetails.userId)
                    print("Events Count =", self.events.count)
                }
            } catch {
                throw error // Rethrow the error so the caller can handle it
            }
        }
    }
    
    func numberOfRows() -> Int {
        let tripsCount = events.count
        return tripsCount
    }
    
    func itemAt(indexPath: IndexPath) -> LSDAllEvents {
        let item =  events[indexPath.row]
        return item
    }
    

}
