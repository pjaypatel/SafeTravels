//
//  Constants.swift
//  SafeTravels
//
//  Created by Pranay Jay Patel on 7/14/20.
//  Copyright © 2020 Pranay Jay Patel. All rights reserved.
//

import Foundation

struct K {
    static let appName = "SafeTravels"
    struct FStore {
        struct tripsCollection {
            static let name = "trips"
            static let userSpecific = "userTrips"
        }
        struct tripDocument {
            static let originField = "originName"
            static let originLatField = "originLat"
            static let originLongField = "originLong"
            static let destField = "destinationName"
            static let destLatField = "destinationLat"
            static let destLongField = "destinationLong"
            static let hostField = "host"
            static let timeField = "time"
            static let passengers = "passengers"
        }
        struct usersCollection {
            static let name = "users"
        }
        struct userDocument {
            static let name = "name"
            static let email = "email"
            static let phone = "phone"
        }
        struct followingCollection {
            static let name = "following"
            static let userSpecific = "userFollowing"
        }

    }
}
