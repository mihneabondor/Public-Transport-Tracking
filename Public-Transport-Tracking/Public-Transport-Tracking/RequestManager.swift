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
}
