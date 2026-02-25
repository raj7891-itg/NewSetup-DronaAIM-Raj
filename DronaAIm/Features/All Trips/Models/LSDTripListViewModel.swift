//
//  LSDTripListViewModel.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 27/06/24.
//

import Foundation

class LSDTripListViewModel {
    private var trips: [LSDTrip] = []
    private var filteredTrips: [LSDTrip] = []

    var pageDetails: PageDetails?

    func fetchTrips(parameters: [String: String], requestbody: LSRequstTrips) async throws {
        if let userDetails = UserDefaults.standard.userDetails {
            let userId = userDetails.userId
            let endpoint = LSAPIEndpoints.tripsByDriverId(for: userId)
            print("list Parms = ", parameters)
            print("Body = ", requestbody)

            let response: LSDTripListModel = try await LSNetworkManager.shared.post(endpoint, body: requestbody, parameters: parameters)
            self.trips = response.trips
            self.pageDetails = response.pageDetails
            print("Page Details = ", pageDetails)
        }
    }
    
    func loadMoreTrips(parameters: [String : String], requestbody: LSRequstTrips) async throws {
        if let userDetails = UserDefaults.standard.userDetails {
            let userId = userDetails.userId
            let endpoint = LSAPIEndpoints.tripsByDriverId(for: userId)
            let response: LSDTripListModel = try await LSNetworkManager.shared.post(endpoint, body: requestbody  , parameters: parameters)
            self.trips += response.trips
            self.pageDetails = response.pageDetails
            print("User Id = ", userDetails.userId)
            print("Trips Count =", self.trips.count)
            print("Page Details = ", pageDetails)

        }
    }
        
    func numberOfRows() -> Int {
        let tripsCount = trips.count
        return tripsCount
    }
    
    func itemAt(indexPath: IndexPath) -> LSDTrip {
        let item = trips[indexPath.row]
        return item
    }
}
