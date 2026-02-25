//
//  LSDNotificationsViewModel.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 12/07/24.
//

import Foundation

class LSDNotificationsViewModel {
    private var notifications: [LSNotification] = []
    private var notificationModel: LSNotificationModel?
    private var filterNotifications: [LSNotification] = []

    var isLoading = false
    var page = 1
    var segmentType: LSNotificationSegmentType = .all

    var allCount: Int = 0
    var unreadCount: Int = 0
    var actionNeededCount: Int = 0

    func fetchNotifications(limit: String) async throws {
        if let userDetails = UserDefaults.standard.userDetails {
            let userId = userDetails.userId
            let endpoint = LSAPIEndpoints.notifications()
            let requestbody = LSRequstNotifications(userId: userId, messageTypes: nil, isRead: nil)

            let response: LSNotificationModel = try await LSNetworkManager.shared.post(endpoint, body: requestbody, parameters: ["page": String(page), "limit": limit])
             let currentPage = response.pageDetails.currentPage
//            if currentPage > 1 {
//                self.notifications += response.notifications
//            } else {
                self.notifications = response.notifications
//            }
            filterBy(segmentType: segmentType)
            self.page += 1
            self.notificationModel = response
        }
    }
    
    func readnotifications(for messageIds: [String]) async throws {
        if let userDetails = UserDefaults.standard.userDetails {
            let userId = userDetails.userId
            let endpoint = LSAPIEndpoints.readNotificationStatu()
            let requestbody = LSRequstReadUnread(messageIds: messageIds, readByUserId: userId)
            let response: LSSuccess = try await LSNetworkManager.shared.post(endpoint, body: requestbody)
            print("read Notification = ", response)
        }
    }
    
    func unReadnotifications(for messageIds: [String]) async throws {
        if let userDetails = UserDefaults.standard.userDetails {
            let userId = userDetails.userId
            let endpoint = LSAPIEndpoints.unReadNotificationStatu()
            let requestbody = LSRequstReadUnread(messageIds: messageIds, readByUserId: userId)
            let response: LSSuccess = try await LSNetworkManager.shared.post(endpoint, body: requestbody)
            print("Unread Notification = ", response)
        }
    }
    
    func showHiddenNotifications() {
        let hiddenIds = UserDefaults.standard.messageIds
        let hidden = notifications.filter { hiddenIds.contains($0.messageID ?? "") }
        self.filterNotifications = hidden
        
    }
    
    func markAsRead(for messageIds: [String]) {
        // Update notifications
        notifications = notifications.map { notification in
            if let messageID = notification.messageID, messageIds.contains(messageID) {
                return LSNotification(
                    message: notification.message,
                    messageID: notification.messageID,
                    messageType: notification.messageType,
                    metadata: notification.metadata,
                    lonestarID: notification.lonestarID,
                    createdTs: notification.createdTs,
                    isRead: true, // Update isRead to true
                    readByUserID: notification.readByUserID,
                    readTs: notification.readTs,
                    isPushNote: notification.isPushNote
                )
            }
            return notification
        }
        
        // Update the filtered notifications based on the current segment type
        filterBy(segmentType: segmentType)
    }
    
    func markAsUnRead(for messageIds: [String]) {
        // Update notifications
        notifications = notifications.map { notification in
            if let messageID = notification.messageID, messageIds.contains(messageID) {
                return LSNotification(
                    message: notification.message,
                    messageID: notification.messageID,
                    messageType: notification.messageType,
                    metadata: notification.metadata,
                    lonestarID: notification.lonestarID,
                    createdTs: notification.createdTs,
                    isRead: false, // Update isRead to true
                    readByUserID: notification.readByUserID,
                    readTs: notification.readTs,
                    isPushNote: notification.isPushNote
                )
            }
            return notification
        }
        
        // Update the filtered notifications based on the current segment type
        filterBy(segmentType: segmentType)
    }
    
    func filterBy(segmentType: LSNotificationSegmentType) {
        switch segmentType {
        case .unread:
            self.filterNotifications = notifications.filter({$0.isRead == false})
        case .actionNeeded:
            self.filterNotifications = notifications.filter({$0.messageType == .documentSubmissionNotification})
        default:
            self.filterNotifications = notifications
        }
        self.allCount = self.notifications.count
        self.unreadCount =  notifications.filter({$0.isRead == false}).count
        self.actionNeededCount = notifications.filter({$0.messageType == .documentSubmissionNotification}).count

        let hiddenIds = UserDefaults.standard.messageIds
        let nothidden = self.filterNotifications.filter {
            guard let messageID = $0.messageID else { return true } // If messageID is nil, include it in the result
            return !hiddenIds.contains(messageID)
        }
        self.filterNotifications = nothidden
    }
    
    func reloadList() {
        filterBy(segmentType: segmentType)
    }
    
    
    func numberOfRows() -> Int {
        return filterNotifications.count
    }
    
    func notification(at index: Int) -> LSNotification {
        return filterNotifications[index]
    }
    
    func index(for notification: LSNotification) -> Int {
        return filterNotifications.count(where: { $0.messageID == notification.messageID })
    }
    
    func allNotifications() -> [LSNotification] {
        return filterNotifications
    }
    
    func totalRecords() -> Int {
        return notifications.count
    }
    
    func canLoadMore() -> Bool {
           // Check if there are more records to load
        if let totalRecords = notificationModel?.pageDetails.totalRecords {
            return notifications.count < totalRecords
        }
        return false
       }
    
}
