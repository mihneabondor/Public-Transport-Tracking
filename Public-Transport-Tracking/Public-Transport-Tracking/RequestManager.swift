import SwiftUI
import Alamofire
import MapKit
import FeedKit

class RSSParser: NSObject, XMLParserDelegate {
    var currentElement: String = ""
    var currentTitle: String = ""
    var currentDescription: String = ""
    var currentPubDate: String = ""
    
    func parseXML(data: Data) {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
    }
    
    // XMLParserDelegate methods
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case "title":
            currentTitle += string
        case "description":
            currentDescription += string
        case "pubDate":
            currentPubDate += string
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            print("Title: \(currentTitle)")
            print("Description: \(currentDescription)")
            print("Pub Date: \(currentPubDate)")
            
            currentTitle = ""
            currentDescription = ""
            currentPubDate = ""
        }
    }
}


class RequestManager {
    func getVehicles() async throws -> [Vehicle]{
        let randomKey = Constants.keys.randomElement()
        let _headers : HTTPHeaders = ["Content-Type" : "application/json",
                                      "X-Agency-Id" : "2",
                                      "X-API-KEY" : randomKey ?? "aSVGUmECaW8VbAPYnzJFM21KeFiz1suP2z55ZZhL"]
        let getRequest = AF.request("https://api.tranzy.dev/v1/opendata/vehicles", method: .get, parameters: [:], encoding: URLEncoding.default, headers: _headers)
        var responseJson : String!
        do {
            responseJson = try await getRequest.serializingString().value
        } catch let err{
            print(err)
        }
        let responseData = try? DecodingManager().decodeVehicles(jsonString: responseJson ?? "")
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
        let responseData = try? DecodingManager().decodeSchedule(jsonString: responseJson ?? "")
        return responseData ?? Schedule(name: nil, type: nil, route: nil, station: nil)
    }
    
    func getNews() async throws -> RSSFeed {
        let feedURL = URL(string: "https://www.ctpcj.ro/index.php/ro/despre-noi/stiri?format=feed&amp;type=rss")!
        let parser = FeedParser(URL: feedURL) // or FeedParser(data: data) or FeedParser(xmlStream: stream)
        let result = parser.parse()
        switch result {
        case .success(let feed):
            // Grab the parsed feed directly as an optional rss, atom or json feed object
            return feed.rssFeed!
            
        case .failure(let error):
            print(error)
        }
        return RSSFeed()
    }
    
    func getDirections(origin: String, destination: String) async throws -> Directions {
        let getRequest = AF.request("https://maps.googleapis.com/maps/api/directions/json?destination=\(destination)&mode=transit&origin=\(origin)&key=AIzaSyAW0rKcBmVtEZ12-9oUmjSHDyvdy-6fr3w&language=ro", method: .get, parameters: [:], encoding: URLEncoding.default, headers: [])
        var responseJson : String!
        do {
            responseJson = try await getRequest.serializingString().value
        } catch let err{
            print(err)
        }
        let responseData = try? DecodingManager().decodeDirections(jsonString: responseJson ?? "")
        return responseData ?? Directions(geocodedWaypoints: nil, routes: nil, status: nil)
    }
    
    func getSpecialSchedule() async throws -> SpecialSchedule {
        let getRequest = AF.request("https://busify-cluj.web.app/in-app-news", method: .get, parameters: [:], encoding: URLEncoding.default, headers: [])
        var responseJson : String!
        do {
            responseJson = try await getRequest.serializingString().value
        } catch let err{
            print(err)
        }
        
        var responseData = try? DecodingManager().decodeSpecialSchedule(jsonString: responseJson ?? "")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = dateFormatter.date(from: responseData?.to ?? "")
        responseData?.dateTo = formattedDate
        
        let formattedText = responseData?.text?.replacingOccurrences(of: "/", with: "\n")
        responseData?.text = formattedText
        return responseData ?? SpecialSchedule(motiv: nil, text: nil, to: nil, dateTo: nil)
    }
}
