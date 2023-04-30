//
//  Structs.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/3/23.
//

import Foundation
import CoreLocation
import Alamofire


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
    var userBetweenVehicleAndDestination = false
    var headsign : String?
    
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
    var showMenu : Bool = false
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

struct News : Hashable {
    var link : String?
    var title : String?
    var description : String?
}

struct Connectivity {
  static let sharedInstance = NetworkReachabilityManager()!
  static var isConnectedToInternet:Bool {
      return self.sharedInstance.isReachable
    }
}

struct StationDetails : Hashable {
    var vehicle : Vehicle
    var stationETA : Int
}

struct Directions: Codable {
    let geocodedWaypoints: [GeocodedWaypoint]?
    let routes: [CustomRoute]?
    let status: String?
    
    enum CodingKeys: String, CodingKey {
        case geocodedWaypoints = "geocoded_waypoints"
        case routes
        case status
    }
}

struct GeocodedWaypoint: Codable {
    let geocoderStatus, placeId: String?
    let types: [String]?
    
    enum CodingKeys: String, CodingKey {
        case geocoderStatus = "geocoder_status"
        case placeId = "place_id"
        case types
    }
}

struct CustomRoute: Codable {
    let bounds: CustomBounds?
    let copyrights: String?
    let legs: [CustomLeg]?
    let overviewPolyline: CustomPolyline?
    let summary: String?
    let warnings: [String]?
    let waypointOrder: [JSONAny]?
    
    enum CodingKeys: String, CodingKey {
        case bounds
        case copyrights
        case legs
        case overviewPolyline = "overview_polyline"
        case summary
        case warnings
        case waypointOrder = "waypoint_order"
    }
}

struct CustomBounds: Codable {
    let northeast, southwest: CustomLocation?
}

struct CustomLocation: Codable {
    let lat, lng: Double?
}

struct CustomLeg: Codable {
    let arrivalTime, departureTime: CustomTime?
    let distance, duration: CustomDistance?
    let endAddress: String?
    let endLocation: CustomLocation?
    let startAddress: String?
    let startLocation: CustomLocation?
    let steps: [CustomStep]?
    let trafficSpeedEntry, viaWaypoint: [JSONAny]?
    
    enum CodingKeys: String, CodingKey {
        case arrivalTime = "arrival_time"
        case departureTime = "departure_time"
        case distance
        case duration
        case endAddress = "end_address"
        case endLocation = "end_location"
        case startAddress = "start_address"
        case startLocation = "start_location"
        case steps
        case trafficSpeedEntry = "traffic_speed_entry"
        case viaWaypoint = "via_waypoint"
    }
}

struct CustomTime: Codable {
    let text, timeZone: String?
    let value: Int?
    
    enum CodingKeys : String, CodingKey {
        case timeZone = "time_zone"
        case value, text
    }
}

struct CustomDistance: Codable {
    let text: String?
    let value: Int?
}

struct CustomStep: Codable, Identifiable {
    var id = UUID()
    let distance, duration: CustomDistance?
    let endLocation: CustomLocation?
    let htmlInstructions: String?
    let polyline: CustomPolyline?
    let startLocation: CustomLocation?
    let steps: [CustomStep]?
    let travel: CustomTravelMode?
    let transitDetails: CustomTransitDetails?
    let maneuver: String?
    
    enum CodingKeys: String, CodingKey {
        case distance, duration, endLocation = "end_location", htmlInstructions = "html_instructions", polyline, startLocation = "start_location", steps, travel = "travel_mode", transitDetails = "transit_details", maneuver
    }
}

struct DecodedSteps : Identifiable {
    var id = UUID()
    let distance, duration: CustomDistance?
    let endLocation: CustomLocation?
    let htmlInstructions: String?
    let polyline: CustomPolyline?
    let startLocation: CustomLocation?
    let travel: CustomTravelMode?
    let transitDetails: CustomTransitDetails?
    let maneuver: String?
    
    enum CodingKeys: String, CodingKey {
        case distance, duration
        case endLocation = "end_location"
        case htmlInstructions = "html_instructions"
        case polyline
        case startLocation = "start_location"
        case travel
        case transitDetails = "transit_details"
        case maneuver
    }
}

struct CustomPolyline: Codable {
    let points: String?
}

struct CustomTransitDetails: Codable {
    let arrivalStop: CustomStop?
    let arrivalTime: CustomTime?
    let departureStop: CustomStop?
    let departureTime: CustomTime?
    let headsign: String?
    let line: CustomLine?
    let numStops: Int?
    
    enum CodingKeys : String, CodingKey {
        case arrivalStop = "arrival_stop"
        case arrivalTime = "arrival_time"
        case departureStop = "departure_stop"
        case departureTime = "depature_time"
        case headsign
        case line
        case numStops = "num_stops"
    }
}

struct CustomStop: Codable {
    let location: CustomLocation?
    let name: String?
}

struct CustomLine: Codable {
    let agencies: [CustomAgency]?
    let name, shortName: String?
    let vehicle: CustomVehicle?
    
        enum CodingKeys: String, CodingKey {
        case agencies
        case name
        case shortName = "short_name"
        case vehicle
    }
}

struct CustomAgency: Codable {
    let name, phone: String?
    let url: String?
}

struct CustomVehicle: Codable {
    let icon, name, type: String?
}

enum CustomTravelMode: String, Codable {
    case transit = "TRANSIT"
    case walking = "WALKING"
}

struct JSONAny: Codable {}
