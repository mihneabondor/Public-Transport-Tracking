//
//  FavoritesScreen.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/3/23.
//

import SwiftUI
import MapKit

struct FavoritesScreen: View {
    @State var availableTypes = [Int]()
    @State var activeIndex = -1
    @Binding var vehicles : [Vehicle]
    @Binding var linii : [Linii]
    @Binding var routes : [Route]
    @StateObject var locationManager = LocationManager()
    var vehicleTypes = ["Tramvai", "Metro", "Tren", "Autobus", "Ferry", "Cable tram", "Aerial Lift", "Funicular", "", "", "", "Troleibus", "Monorail"]
    var vehicleTypesImages = ["tram.fill", "train.side.front.car", "train.side.front.car", "bus.fill", "ferry.fill", "cablecar.fill", "helicopter.fill", "bus.fill", "", "", "", "bus.doubledecker.fill", "bus.fill"]
    @State var adrese = [String]()
    public var timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    let route = Constants.routes
    var body: some View {
        NavigationView {
            VStack{
                ScrollView(.vertical) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack{
                            ForEach(Array(availableTypes.enumerated()), id: \.offset) {index, type in
                                Label("\(vehicleTypes[type])", systemImage: "\(vehicleTypesImages[type])")
                                    .padding()
                                    .background(activeIndex == -1 || activeIndex == type ? Color("Gray") : Color(.placeholderText))
                                    .cornerRadius(20)
                                    .onTapGesture {
                                        if activeIndex == type {
                                            activeIndex = -1
                                            loadView()
                                        } else {
                                            activeIndex = type
                                            linii = linii.filter({$0.vehicles.last?.vehicleType == type})
                                        }
                                    }
                            }
                        }
                    }
                    .padding()
                    
                    ForEach(linii, id: \.self) {item in
                            VStack{
                                HStack{
                                    Text("Linia \(item.tripId) - \(item.vehicles.count) vehicule")
                                        .font(.title2)
                                        .foregroundColor(.purple)
                                        .bold()
                                        .padding([.leading, .trailing, .bottom])
                                    Spacer()
                                    Image(systemName: "\(vehicleTypesImages[item.vehicles.last?.vehicleType! ?? 0])")
                                        .padding([.leading, .trailing, .bottom])
                                }
                                ForEach(item.vehicles, id:\.self) {vehicle in
                                    VStack{
                                        HStack{
                                            VStack{
                                                Text("STAȚIE CURENTĂ")
                                                    .font(.footnote)
                                                    .foregroundColor(.secondary)
                                                Text("\(vehicle.statie ?? "Necunoscută") \(vehicle.routeId ?? 0)")
                                                    .padding(.bottom)
                                                Text("TUR/RETUR")
                                                    .font(.footnote)
                                                    .foregroundColor(.secondary)
                                                Text(vehicle.tripId?.last! == "0" ? "Tur" : "Retur")
                                            }.padding([.trailing, .leading, .bottom])
                                            Spacer()
                                            VStack{
                                                Text("ETA")
                                                    .font(.footnote)
                                                    .foregroundColor(.secondary)
                                                Text(String(vehicle.eta ?? 0))
                                                    .padding(.bottom)
                                                
                                                Text("SERVICII")
                                                    .font(.footnote)
                                                    .foregroundColor(.secondary)
                                                HStack{
                                                    if vehicle.bikeAccessible == "BIKE_ACCESSIBLE"{
                                                        Image(systemName: "bicycle")
                                                    } else {
                                                        Text("-")
                                                    }
                                                    if vehicle.wheelchairAccessible == "WHEELCHAIR_ACCESSIBLE"{
                                                        Image(systemName: "figure.roll")
                                                    } else {
                                                        Text("-")
                                                    }
                                                }
                                            }.padding([.trailing, .leading, .bottom])
                                        }
                                    }
                                    Divider()
                                        .background(Color.purple)
                                }
                            }
                        Text(" ")
                            .font(.footnote)
                    }
                    Spacer()
                }
            }
            .onReceive(timer) {_ in
                loadView()
            }
            .onAppear {
                loadView()
            }
            .navigationTitle("Favorite")
        }
    }
    
    func loadView() {
        Task(priority: .high) {
            var newVehicles = [Vehicle]()
            do {
                newVehicles = try await RequestManager().getVehicles()
            } catch let err {
                print(err)
            }
            vehicles.removeAll()
            vehicles = newVehicles
            
            vehicles = vehicles.filter({$0.latitude != nil && $0.longitude != nil && $0.tripId != nil && $0.routeId != nil && $0.speed != 0})
            
            for i in 0...vehicles.count-1 {
                if !availableTypes.contains(vehicles[i].vehicleType ?? 0) {
                    availableTypes.append(vehicles[i].vehicleType!)
                }
            }
            vehicles = vehicles.sorted(by: {Int(($0.tripId?.components(separatedBy: "_").first)!) ?? 0 < Int(($1.tripId?.components(separatedBy: "_").first)!) ?? 0})
            let stops = try? await RequestManager().getStops()
            linii.removeAll()
            for i in 0...vehicles.count-1 {
                if route[route.firstIndex{$0.routeId == vehicles[i].routeId} ?? 0].routeShortName ?? "" != linii.last?.tripId || linii.isEmpty {
                    linii.append(Linii(tripId: route[route.firstIndex{$0.routeId == vehicles[i].routeId} ?? 0].routeShortName ?? "", vehicles: [], favorite: false))
                    }
                    if !linii.isEmpty {
                        var closestStopName = "", minimumDistance = 100.0
                        if let stops = stops {
                            for stop in stops {
                                let vehicleLocation = CLLocation(latitude: vehicles[i].latitude ?? 0, longitude: vehicles[i].longitude ?? 0)
                                let distance = vehicleLocation.distance(from: CLLocation(latitude: stop.lat ?? 0, longitude: stop.long ?? 0)) / 1000
                                if minimumDistance > distance {
                                    minimumDistance = distance
                                    closestStopName = stop.stopName ?? ""
                                }
                            }
                        }
                        vehicles[i].routeShortName = route[route.firstIndex{$0.routeId == vehicles[i].routeId} ?? 0].routeShortName
                        vehicles[i].routeLongName = route[route.firstIndex{$0.routeId == vehicles[i].routeId} ?? 0].routeLongName
                        vehicles[i].statie = closestStopName
                        
                        let currentUserLocation = CLLocation(latitude: locationManager.lastLocation?.coordinate.latitude ?? 0, longitude: locationManager.lastLocation?.coordinate.longitude ?? 0)
                        let vehicleLocation = CLLocation(latitude: vehicles[i].latitude ?? 0, longitude: vehicles[i].longitude ?? 0)
                        let distance = currentUserLocation.distance(from: vehicleLocation) / 1000
                        vehicles[i].eta = Int(ceil(distance/Double((vehicles[i].speed ?? 1))*60))
                        linii[linii.count-1].vehicles.append(vehicles[i])
                    }
            }
        }
    }
}
