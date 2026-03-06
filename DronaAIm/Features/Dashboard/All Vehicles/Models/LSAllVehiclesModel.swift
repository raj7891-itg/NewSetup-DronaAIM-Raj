// MARK: - Root Response
struct LSVehicleListResponse: Codable {
    let pageDetails: LSPageDetails
    let vehicles: [LSVehicleModel]
}

// MARK: - Page Details
struct LSPageDetails: Codable {
    let totalRecords: Int
    let pageSize: Int
    let currentPage: Int
}

// MARK: - Vehicle
struct LSVehicleModel: Codable {
    let id: Int
    let createdAt: String?
    let createdBy: String?
    let createdByUser: String?
    let lonestarId: String?
    let make: String?
    let model: String?
    let tagLicencePlateNumber: String?
    let vehicleId: String?
    let vin: String?
    let year: String?
    let updatedAt: String?
    let updatedBy: String?
    let updatedByUser: String?
    let deviceId: String?
    let customVehicleId: String?
    let meanScore: String?
    let totalDistance: String?
    let totalDistanceInKms: String?
    let totalDistanceInMiles: String?
    let totalDuration: String?
    let totalHardAccelerationCount: String?
    let totalHarshBrakingCount: String?
    let totalHarshCorneringCount: String?
    let totalIncidentCount: String?
    let totalOverSpeedingCount: String?
    let totalSevereShockCount: String?
    let totalShockCount: String?
    let totalSosCount: String?
    let tripCount: String?
    let imei: String?
    let driverId: String?
    let lookupDevices: [LSLookupDevice]
    let lookupUsers: [LSLookupUser]

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt                  = "created_at"
        case createdBy                  = "created_by"
        case createdByUser              = "created_by_user"
        case lonestarId                 = "lonestar_id"
        case make
        case model
        case tagLicencePlateNumber      = "tag_licence_plate_number"
        case vehicleId                  = "vehicle_id"
        case vin
        case year
        case updatedAt                  = "updated_at"
        case updatedBy                  = "updated_by"
        case updatedByUser              = "updated_by_user"
        case deviceId                   = "device_id"
        case customVehicleId            = "custom_vehicle_id"
        case meanScore                  = "mean_score"
        case totalDistance              = "total_distance"
        case totalDistanceInKms         = "total_distance_in_kms"
        case totalDistanceInMiles       = "total_distance_in_miles"
        case totalDuration              = "total_duration"
        case totalHardAccelerationCount = "total_hard_acceleration_count"
        case totalHarshBrakingCount     = "total_harsh_braking_count"
        case totalHarshCorneringCount   = "total_harsh_cornering_count"
        case totalIncidentCount         = "total_incident_count"
        case totalOverSpeedingCount     = "total_over_speeding_count"
        case totalSevereShockCount      = "total_severe_shock_count"
        case totalShockCount            = "total_shock_count"
        case totalSosCount              = "total_sos_count"
        case tripCount                  = "trip_count"
        case imei
        case driverId                   = "driver_id"
        case lookupDevices              = "lookup_devices"
        case lookupUsers                = "lookup_users"
    }
}

// MARK: - Lookup Device
struct LSLookupDevice: Codable {
    let id: Int
    let active: Bool?
    let deviceId: String?
    let imei: String?
    let installed: Bool?
    let isOrphaned: Bool?
    let createdBy: String?
    let insurerId: String?
    let deviceProvider: String?
    let createdBySystem: String?
    let lonestarId: String?
    let insuredId: String?
    let shippingProviderName: String?
    let trackingNumber: String?
    let shipmentDate: String?
    let createdAt: String?
    let status: String?
    let statusTsInMilliseconds: String?
    let snapshot: [LSSnapshot]?
    let lastLiveTrack: LSLastLiveTrack?
    let updatedAt: String?
    let updatedBy: String?

    enum CodingKeys: String, CodingKey {
        case id
        case active
        case deviceId               = "device_id"
        case imei
        case installed
        case isOrphaned             = "is_orphaned"
        case createdBy              = "created_by"
        case insurerId              = "insurer_id"
        case deviceProvider         = "device_provider"
        case createdBySystem        = "created_by_system"
        case lonestarId             = "lonestar_id"
        case insuredId              = "insured_id"
        case shippingProviderName   = "shipping_provider_name"
        case trackingNumber         = "tracking_number"
        case shipmentDate           = "shipment_date"
        case createdAt              = "created_at"
        case status
        case statusTsInMilliseconds = "status_ts_in_milliseconds"
        case snapshot
        case lastLiveTrack          = "last_live_track"
        case updatedAt              = "updated_at"
        case updatedBy              = "updated_by"
    }
}

// MARK: - Snapshot
struct LSSnapshot: Codable {
    let urls: [LSSnapshotURL]?
    let camera: Int?
}

struct LSSnapshotURL: Codable {
    let url: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case url
        case updatedAt = "updatedAt"
    }
}

// MARK: - Last Live Track
struct LSLastLiveTrack: Codable {
    let imei: String?
    let tsInStr: String?
    let gnssInfo: LSGnssInfo?
    let createdBy: String?
    let eventType: String?
    let createdAtMs: Int?
    let createdAtStr: String?
    let vendorEventId: String?
    let tsInMilliSeconds: Int?
}

// MARK: - GNSS Info
struct LSGnssInfo: Codable {
    let speed: Double?
    let heading: Double?
    let isValid: Bool?
    let latitude: Double?
    let elevation: Double?
    let longitude: Double?
}

// MARK: - Lookup User (reusing existing LSUserDetailsModel)
struct LSLookupUser: Codable {
    let id: Int
    let userId: String?
    let initials: String?
    let cognitoId: String?
    let role: String?
    let emailId: String?
    let firstName: String?
    let lastName: String?
    let primaryPhoneCtryCd: String?
    let primaryPhone: String?
    let address: String?
    let deleted: Bool?
    let userName: String?
    let activeStatus: String?
    let createdBy: String?
    let dronaaimId: String?
    let orgRoleAndScoreMapping: [LSOrgRoleAndScoreMapping]?
    let lastLoginAt: String?
    let lastLoginAtDisplay: String?
    let updatedAt: String?
    let updatedBy: String?
    let lonestarId: String?
    let createdAt: String?
    let insurerId: String?
    let licenseId: String?
    let licenseType: String?
    let licenseIssuedState: String?
    let altPhoneCtryCd: String?
    let altPhone: String?
    let notificationTokens: [String]?
    let profilePhoto: LSProfilePhoto?
    let licenseExpiryDate: String?
    let empStartDate: String?
    let dob: String?
    let tenantId: String?

    var fullName: String? {
        let parts = [firstName, lastName].compactMap { $0 }
        return parts.isEmpty ? nil : parts.joined(separator: " ")
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId                 = "user_id"
        case initials
        case cognitoId              = "cognito_id"
        case role
        case emailId                = "email_id"
        case firstName              = "first_name"
        case lastName               = "last_name"
        case primaryPhoneCtryCd     = "primary_phone_ctry_cd"
        case primaryPhone           = "primary_phone"
        case address
        case deleted
        case userName               = "user_name"
        case activeStatus           = "active_status"
        case createdBy              = "created_by"
        case dronaaimId             = "dronaaim_id"
        case orgRoleAndScoreMapping = "org_role_and_score_mapping"
        case lastLoginAt            = "last_login_at"
        case lastLoginAtDisplay     = "last_login_at_display"
        case updatedAt              = "updated_at"
        case updatedBy              = "updated_by"
        case lonestarId             = "lonestar_id"
        case createdAt              = "created_at"
        case insurerId              = "insurer_id"
        case licenseId              = "license_id"
        case licenseType            = "license_type"
        case licenseIssuedState     = "license_issued_state"
        case altPhoneCtryCd         = "alt_phone_ctry_cd"
        case altPhone               = "alt_phone"
        case notificationTokens     = "notification_tokens"
        case profilePhoto           = "profile_photo"
        case licenseExpiryDate      = "license_expiry_date"
        case empStartDate           = "emp_start_date"
        case dob
        case tenantId               = "tenant_id"
    }
}


struct LSAssignDriverResponse: Codable {
    let vehicleId: String?
    let lonestarId: String?
    let driverId: String?
    let vin: String?
    let make: String?
    let model: String?
    let driverFirstName: String?
    let driverLastName: String?
    let message: String?
    let year: String?
}
