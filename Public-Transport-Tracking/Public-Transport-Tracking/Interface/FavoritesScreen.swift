//
//  FavoritesScreen.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/3/23.
//

import SwiftUI
import MapKit

struct FavoritesScreen: View {
    @State private var availableTypes = [Int]()
    @State private var activeIndex = -1
    @State private var vehicles = [Vehicle]()
    @State private var linii = [Linii]()
    @StateObject var locationManager = LocationManager()
    private var vehicleTypes = ["Tramvai", "Metro", "Tren", "Autobus", "Ferry", "Cable tram", "Aerial Lift", "Funicular", "", "", "", "Troleibus", "Monorail"]
    private var vehicleTypesImages = ["tram.fill", "train.side.front.car", "train.side.front.car", "bus.fill", "ferry.fill", "cablecar.fill", "helicopter.fill", "bus.fill", "", "", "", "bus.doubledecker.fill", "bus.fill"]
    @State private var adrese = [String]()
    let timer = Timer.publish(every: 20, on: .main, in: .common).autoconnect()
    
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
                                    Text("Linia \(item.routeId) - \(item.vehicles.count) vehicule")
                                        .font(.title2)
                                        .foregroundColor(.purple)
                                        .bold()
                                        .padding()
                                    Spacer()
                                    Image(systemName: "\(vehicleTypesImages[item.vehicles.last?.vehicleType! ?? 0])")
                                        .padding()
                                }
                                ForEach(item.vehicles, id:\.self) {vehicle in
                                    VStack{
                                        HStack{
                                            VStack{
                                                Text("LOCAȚIE")
                                                    .font(.footnote)
                                                    .foregroundColor(.secondary)
                                                Text("\(vehicle.address ?? "Necunoscută")")
                                                    .padding(.bottom)
                                                Text("STAȚIE CURENTĂ")
                                                    .font(.footnote)
                                                    .foregroundColor(.secondary)
                                                Text("Memorandumului")
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
                withAnimation {
                    loadView()
                }
            }
            .onAppear {
                withAnimation {
                    loadView()
                }
            }
            .navigationTitle("Favorite")
        }
    }
    
    func loadView() {
        Task(priority: .high) {
            linii.removeAll()
            vehicles.removeAll()
            
            do {
                vehicles = try await RequestManager().getVehicles()
            } catch let err {
                print(err)
            }
            vehicles = vehicles.sorted(by: {$0.vehicleType! < $1.vehicleType!})
            for elem in vehicles {
                if elem.vehicleType != availableTypes.last {
                    availableTypes.append(elem.vehicleType!)
                }
            }
            vehicles = vehicles.sorted(by: {($0.routeId ?? 0) < ($1.routeId ?? 0)})
            
            for i in 0...vehicles.count-1 {
                let elem = vehicles[i]
                    if elem.speed != 0{
                        if elem.routeId != linii.last?.routeId || (linii.isEmpty && elem.routeId != nil) {
                            linii.append(Linii(routeId: elem.routeId!, vehicles: [], favorite: false))
                        }
                        if !linii.isEmpty {
                            if linii.last?.routeId ?? 0 < 10 {
                                var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
                                let lat: Double = vehicles[i].latitude ?? 0
                                let lon: Double = vehicles[i].longitude ?? 0
                                let ceo: CLGeocoder = CLGeocoder()
                                center.latitude = lat
                                center.longitude = lon
                                let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
                                let placemarks = try? await ceo.reverseGeocodeLocation(loc)
                                if let placemarks = placemarks {
                                    if let street = placemarks.first?.thoroughfare {
                                        if let number = placemarks.first?.subThoroughfare {
                                            vehicles[i].address = street + " " + number
                                        }
                                    }
                                }
                            }
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
}

struct FavoritesScreen_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesScreen()
    }
}
