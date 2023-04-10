//
//  Structs.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/3/23.
//

import Foundation
import CoreLocation


struct Vehicle: Codable, Hashable, Identifiable {
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
    var eta : Int?
    var statie : String?
    var routeShortName : String?
    var routeLongName : String?
    var currentSchedule = [[String()]]
    
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
    let tripId : String
    var vehicles : [Vehicle]
    let favorite : Bool
}

struct Statie : Codable, Hashable {
    let stopId : Int?
    let stopName : String?
    let stopDesc : String?
    let lat : Double?
    let long : Double?
    let locationType : Int?
    
    enum CodingKeys: String, CodingKey {
        case stopId = "stop_id"
        case stopName = "stop_name"
        case stopDesc = "stop_desc"
        case lat = "stop_lat"
        case long = "stop_lon"
        case locationType = "location_type"
    }
}

struct Route : Codable, Hashable {
    let routeId : Int?
    let agencyId : Int?
    let routeShortName : String?
    let routeLongName : String?
    let routeColor : String?
    let routeType : Int?
    
    enum CodingKeys: String, CodingKey {
        case routeId = "route_id"
        case agencyId = "agency_id"
        case routeShortName = "route_short_name"
        case routeLongName = "route_long_name"
        case routeColor = "route_color"
        case routeType = "route_type"
    }
}

struct Shape : Codable, Hashable {
    let shapeId : String?
    let latitude : Double?
    let longitude : Double?
    let pointSq : Int?
    
    enum CodingKeys : String, CodingKey {
        case shapeId = "shape_id"
        case latitude = "shape_pt_lat"
        case longitude = "shape_pt_lon"
        case pointSq = "shape_pt_sequence"
    }
}

struct Trip : Codable, Hashable {
    let routeId : Int?
    let tripId : String?
    let tripHeadsign : String?
    let directionId : Int?
    let blockId : Int?
    let shapeId : String?
    
    enum CodingKeys : String, CodingKey {
        case routeId = "route_id"
        case tripId = "trip_id"
        case tripHeadsign = "trip_headsign"
        case directionId = "direction_id"
        case blockId = "block_id"
        case shapeId = "shape_id"
    }
}

struct StopTime : Codable, Hashable{
    let tripId : String?
    let stopId : String?
    let sq : Int?
    
    enum CodingKeys: String, CodingKey {
        case tripId = "trip_id"
        case stopId = "stop_id"
        case sq = "stop_sequence"
    }
}

struct Annotation : Identifiable {
    let id = UUID()
    var type : Int?
    var coordinates : CLLocationCoordinate2D
    var vehicle : Vehicle?
    var statie : Statie?
}

struct Schedule: Codable {
    let name: String?
    let type: String?
    let route: String?
    var station: Station?
    
    struct Station: Codable {
        var lv: Line?
        var s: Line?
        var d: Line?
        
        struct Line: Codable {
            let serviceStart: String
            let inStopName: String
            let outStopName: String
            var lines: [[String]]
            
            private enum CodingKeys: String, CodingKey {
                case serviceStart = "service_start"
                case inStopName = "in_stop_name"
                case outStopName = "out_stop_name"
                case lines
            }
        }
    }
}

