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
}
