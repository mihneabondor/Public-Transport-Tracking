//
//  Structs.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/3/23.
//

import Foundation


struct Vehicle: Codable, Hashable {
    let xProvider: Int?
    let xRand: Double?
    let id: Int?
    let label: String?
    let latitude: Double?
    let longitude: Double?
    let timestamp: String?
    let speed: Int?
    let routeId: Int?
    let tripId: String?
    let vehicleType: Int?
    let bikeAccessible: String?
    let wheelchairAccessible: String?
    var address : String?
    
    enum CodingKeys: String, CodingKey {
        case xProvider = "x_provider"
        case xRand = "x_rand"
        case id
        case label
        case latitude
        case longitude
        case timestamp
        case speed
        case routeId = "route_id"
        case tripId = "trip_id"
        case vehicleType = "vehicle_type"
        case bikeAccessible = "bike_accessible"
        case wheelchairAccessible = "wheelchair_accessible"
    }
}

struct Linii : Codable, Hashable {
    let routeId : Int
    var vehicles : [Vehicle]
    let favorite : Bool
}
