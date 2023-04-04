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
        if let responseData = responseData {
        for i in 0...responseData.count-1 {
            var elem = responseData[i]
            if elem.routeId ?? 0 < 5 {
            var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
            let lat: Double = elem.latitude ?? 0
            let lon: Double = elem.longitude ?? 0
            let ceo: CLGeocoder = CLGeocoder()
            center.latitude = lat
            center.longitude = lon
                let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
                let placemarks = try? await ceo.reverseGeocodeLocation(loc)
                if let placemarks = placemarks {
                    if let street = placemarks.first?.thoroughfare {
                        if let number = placemarks.first?.subThoroughfare {
                            elem.address = street + " " + number
                        }
                    }
                }
            }
        }
    }
        return responseData ?? [Vehicle]()
    }
}
