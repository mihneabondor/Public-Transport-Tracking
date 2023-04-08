//
//  DecodingManager.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/3/23.
//

import Foundation

class DecodingManager {
    static let sharedInstance = DecodingManager()
    
    public func decodeVehicles(jsonString : String) throws -> [Vehicle] {
        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        var vehicle : [Vehicle]
        
        
        do {
            vehicle = try decoder.decode([Vehicle].self, from: jsonData)
        } catch let err {
            print(err)
            throw err
        }
        
        return vehicle
    }
    
    public func decodeStops(jsonString : String) throws -> [Statie] {
        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        var statie : [Statie]
        
        
        do {
            statie = try decoder.decode([Statie].self, from: jsonData)
        } catch let err {
            print(err)
            throw err
        }
        
        return statie
    }
    
    public func decodeRoutes(jsonString : String) throws -> [Route] {
        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        var route : [Route]
        
        
        do {
            route = try decoder.decode([Route].self, from: jsonData)
        } catch let err {
            print(err)
            throw err
        }
        
        return route
    }
    
    public func decodeShapes(jsonString : String) throws -> [Shape] {
        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        var shape : [Shape]
        
        
        do {
            shape = try decoder.decode([Shape].self, from: jsonData)
        } catch let err {
            print(err)
            throw err
        }
        
        return shape
    }
    
    public func decodeTrips(jsonString : String) throws -> [Trip] {
        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        var trip : [Trip]
        
        
        do {
            trip = try decoder.decode([Trip].self, from: jsonData)
        } catch let err {
            print(err)
            throw err
        }
        
        return trip
    }
    
    public func decodeStopTimes(jsonString : String) throws -> [StopTime] {
        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        var stopTime : [StopTime]
        
        do {
            stopTime = try decoder.decode([StopTime].self, from: jsonData)
        } catch let err {
            print(err)
            throw err
        }
        
        return stopTime
    }
}
