//
//  TransitViewModel.swift
//  Public-Transport-Tracking
//
//  Created by Mihnea on 5/15/23.
//

import Foundation
import CoreLocation


@MainActor
class TransitViewModel : ObservableObject {
    @Published var vehicles = [Vehicle]()
    @Published var trips = [Trip]()
    @Published var routes = [Route]()
    @Published var stops = [Statie]()
    @Published var stopTimes = [StopTime]()
    @Published var annotations = [Annotation]()
    
    var timer : Timer?
    init() {
        if Connectivity.isConnectedToInternet {
            Task.detached {
                await self.setup()
                await self.createAnnotations()
            }
            timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true, block: { _ in
                Task.detached {
                    await self.setup()
                    while await self.vehicles.isEmpty {
                        await self.setup()
                    }
                    await self.createAnnotations()
                }
            })
        }
    }
    
    public func setup() async {
        if self.stopTimes.isEmpty {
            do {
                self.stopTimes = try await RequestManager().getStopTimes()
            } catch let err {
                print(err)
            }
        }
        
        if self.stops.isEmpty {
            do {
                self.stops = try await RequestManager().getStops()
            } catch let err {
                print(err)
            }
        }
        
        if self.trips.isEmpty {
            do {
                self.trips = try await RequestManager().getTrips()
            } catch let err{
                print(err)
            }
        }
        
        if self.routes.isEmpty {
            do {
                self.routes = try await RequestManager().getRoutes()
            } catch let err {
                print(err)
            }
        }
        
        var bufferVehicles = [Vehicle]()
        do {
            bufferVehicles = try await RequestManager().getVehicles()
        } catch let err {
            print(err)
        }
        
        bufferVehicles = bufferVehicles.filter({vehicle in vehicle.latitude != nil && vehicle.longitude != nil && vehicle.tripId != nil && vehicle.routeId != nil && self.routes.contains(where: {route in route.routeId == vehicle.routeId})})
        
        for i in 0..<bufferVehicles.count {
            var closestStopName = "", minimumDistance = 100.0
            let vehicleSpecificStopTime = self.stopTimes.filter({$0.tripId == bufferVehicles[i].tripId})
            for k in 0..<vehicleSpecificStopTime.count {
                let stopTime = vehicleSpecificStopTime[k]
                let stop = self.stops.first(where: {$0.stopId == Int(stopTime.stopId!)})
                let stopLocation = CLLocation(latitude: stop?.lat ?? 0, longitude: stop?.long ?? 0)
                let vehicleLocation = CLLocation(latitude: bufferVehicles[i].latitude ?? 0, longitude: bufferVehicles[i].longitude ?? 0)
                let distance = vehicleLocation.distance(from: stopLocation) / 1000
                if minimumDistance > distance {
                    minimumDistance = distance
                    closestStopName = stop?.stopName ?? ""
                }
            }
            bufferVehicles[i].routeShortName = self.routes.first(where: {$0.routeId == bufferVehicles[i].routeId})?.routeShortName
            bufferVehicles[i].routeLongName = self.routes.first(where: {$0.routeId == bufferVehicles[i].routeId})?.routeLongName
            bufferVehicles[i].statie = closestStopName
            bufferVehicles[i].headsign = self.trips.first(where: {$0.tripId == bufferVehicles[i].tripId})?.tripHeadsign ?? "-"
        }
        self.vehicles = bufferVehicles
    }
    
    public func createAnnotations() {
        self.annotations.removeAll()
        for elem in self.vehicles {
            self.annotations.append(Annotation(type: 0, coordinates: CLLocationCoordinate2D(latitude: elem.latitude ?? 0, longitude: elem.longitude ?? 0), vehicle: elem, statie: nil))
        }
    }
}
