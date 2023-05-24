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
            Task(priority: .high) {
                await self.setup()
                self.createAnnotations()
            }
            timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true, block: { _ in
                Task(priority: .high) {
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
        
        do {
            self.vehicles = try await RequestManager().getVehicles()
        } catch let err {
            print(err)
        }
        
        self.vehicles = self.vehicles.filter({vehicle in vehicle.latitude != nil && vehicle.longitude != nil && vehicle.tripId != nil && vehicle.routeId != nil && self.routes.contains(where: {route in route.routeId == vehicle.routeId})})
        
        for i in 0..<self.vehicles.count {
            var closestStopName = "", minimumDistance = 100.0
            let vehicleSpecificStopTime = self.stopTimes.filter({$0.tripId == self.vehicles[i].tripId})
            for k in 0..<vehicleSpecificStopTime.count {
                let stopTime = vehicleSpecificStopTime[k]
                let stop = self.stops.first(where: {$0.stopId == Int(stopTime.stopId!)})
                let stopLocation = CLLocation(latitude: stop?.lat ?? 0, longitude: stop?.long ?? 0)
                let vehicleLocation = CLLocation(latitude: self.vehicles[i].latitude ?? 0, longitude: self.vehicles[i].longitude ?? 0)
                let distance = vehicleLocation.distance(from: stopLocation) / 1000
                if minimumDistance > distance {
                    minimumDistance = distance
                    closestStopName = stop?.stopName ?? ""
                }
            }
            self.vehicles[i].routeShortName = self.routes.first(where: {$0.routeId == self.vehicles[i].routeId})?.routeShortName
            self.vehicles[i].routeLongName = self.routes.first(where: {$0.routeId == self.vehicles[i].routeId})?.routeLongName
            self.vehicles[i].statie = closestStopName
            self.vehicles[i].headsign = self.trips.first(where: {$0.tripId == self.vehicles[i].tripId})?.tripHeadsign ?? "-"
        }
    }
    
    public func createAnnotations() {
        self.annotations.removeAll()
            for elem in self.vehicles {
                self.annotations.append(Annotation(type: 0, coordinates: CLLocationCoordinate2D(latitude: elem.latitude ?? 0, longitude: elem.longitude ?? 0), vehicle: elem, statie: nil))
            }
    }
}
