import SwiftUI
import Alamofire
import MapKit


class RequestManager {
    func getVehicles() async throws -> [Vehicle]{
        let _headers : HTTPHeaders = ["Content-Type" : "application/json",
                                      "X-Agency-Id" : "2",
                                      "X-API-KEY" : "ZneVtEgE4PaLRwkd0HGid36HRx1bhLVs42tTtNol"]
        let getRequest = AF.request("https://api.tranzy.dev/v1/opendata/vehicles", method: .get, parameters: [:], encoding: URLEncoding.default, headers: _headers)
        var responseJson : String!
        do {
            responseJson = try await getRequest.serializingString().value
        } catch let err{
            print(err)
        }
        let responseData = try? DecodingManager().decodeVehicles(jsonString: responseJson!)
        return responseData ?? [Vehicle]()
    }
    
    func getStops() async throws -> [Statie]{
        let path = Bundle.main.path(forResource: "Stops", ofType: "txt")
        let string = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        let responseData = try? DecodingManager().decodeStops(jsonString: string)
        return responseData ?? [Statie]()
    }
    
    func getRoutes() async throws -> [Route] {
        let path = Bundle.main.path(forResource: "Routes", ofType: "txt")
        let string = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        let responseData = try? DecodingManager().decodeRoutes(jsonString: string)
        return responseData ?? [Route]()
    }
    
    func getShapes() async throws -> [Shape] {
        let path = Bundle.main.path(forResource: "Shapes", ofType: "txt")
        let string = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        let responseData = try? DecodingManager().decodeShapes(jsonString: string)
        return responseData ?? [Shape]()
    }
    
    func getTrips() async throws -> [Trip] {
        let path = Bundle.main.path(forResource: "Trips", ofType: "txt")
        let string = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        let responseData = try? DecodingManager().decodeTrips(jsonString: string)
        return responseData ?? [Trip]()
    }
    
    func getStopTimes() async throws -> [StopTime] {
        let path = Bundle.main.path(forResource: "StopTimes", ofType: "txt")
        let string = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        let responseData = try? DecodingManager().decodeStopTimes(jsonString: string)
        return responseData ?? [StopTime]()
    }
    
    func getSchedule(line : String) async throws -> Schedule {
        let getRequest = AF.request("https://ctpcj-scraper-utwo.vercel.app/\(line).json", method: .get, parameters: [:], encoding: URLEncoding.default, headers: [])
        var responseJson : String!
        do {
            responseJson = try await getRequest.serializingString().value
        } catch let err{
            print(err)
        }
        let responseData = try? DecodingManager().decodeSchedule(jsonString: responseJson!)
        return responseData ?? Schedule(name: nil, type: nil, route: nil, station: nil)
    }
}
