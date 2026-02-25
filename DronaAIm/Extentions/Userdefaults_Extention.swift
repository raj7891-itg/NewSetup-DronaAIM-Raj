//
//  Userdefaults_Extention.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 04/06/24.
//

import Foundation
import Foundation

extension UserDefaults {
    private enum UserDefaultsKeys: String {
        case userDetails
        case messageIds
        case selectedOrganization
    }
    
    var userDetails: LSUserDetailsModel? {
        get {
            if let data = data(forKey: UserDefaultsKeys.userDetails.rawValue) {
                return try? JSONDecoder().decode(LSUserDetailsModel.self, from: data)
            }
            return nil
        }
        set {
            if let newValue = newValue {
                let data = try? JSONEncoder().encode(newValue)
                set(data, forKey: UserDefaultsKeys.userDetails.rawValue)
            } else {
                removeObject(forKey: UserDefaultsKeys.userDetails.rawValue)
            }
        }
    }
    
    var selectedOrganization: LSOrgRoleAndScoreMapping? {
        get {
            if let data = data(forKey: UserDefaultsKeys.selectedOrganization.rawValue) {
                return try? JSONDecoder().decode(LSOrgRoleAndScoreMapping.self, from: data)
            }
            return nil
        }
        set {
            if let newValue = newValue {
                let data = try? JSONEncoder().encode(newValue)
                set(data, forKey: UserDefaultsKeys.selectedOrganization.rawValue)
            } else {
                removeObject(forKey: UserDefaultsKeys.selectedOrganization.rawValue)
            }
        }
    }
    
    
    var userType: LSUserRole? {
        get {
            return .driver
        }
    }
    
    /// Separate property for handling an array of strings
       var messageIds: [String] {
           get {
               if let data = data(forKey: UserDefaultsKeys.messageIds.rawValue),
                  let decodedArray = try? JSONDecoder().decode([String].self, from: data) {
                   return decodedArray
               }
               return []
           }
           set {
               if newValue.isEmpty {
                   removeObject(forKey: UserDefaultsKeys.messageIds.rawValue)
               } else {
                   if let encodedData = try? JSONEncoder().encode(newValue) {
                       set(encodedData, forKey: UserDefaultsKeys.messageIds.rawValue)
                   }
               }
           }
       }
}
