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
    @Binding var selectedTab : Int
    @Binding var orareSelection : String
    
    @StateObject var locationManager = LocationManager()
    @State var trips = [Trip]()
    
    var vehicleTypes = ["Tramvai", "Metro", "Tren", "Autobus", "Ferry", "Cable tram", "Aerial Lift", "Funicular", "", "", "", "Troleibus", "Monorail"]
    var vehicleTypesImages = ["tram.fill", "train.side.front.car", "train.side.front.car", "bus.fill", "ferry.fill", "cablecar.fill", "helicopter.fill", "bus.fill", "", "", "", "bus.doubledecker.fill", "bus.fill"]
    
    @State var adrese = [String]()
    public var timer = Timer.publish(every: 20, on: .main, in: .common).autoconnect()
    @State private var loadingFirstTime = true
//    let route = Constants.routes
    
    @State var pickerSelection = 1
    @State private var favorites = [String()]
    @State private var searchText = ""
    @State private var loading = false
    var body: some View {
        NavigationView {
            VStack{
                //                ScrollView(.vertical) {
                //                    ScrollViewReader {reader in
                //                    ScrollView(.horizontal, showsIndicators: false) {
                //                        HStack{
                //                            ForEach(Array(availableTypes.enumerated()), id: \.offset) {index, type in
                //                                Label("\(vehicleTypes[type])", systemImage: "\(vehicleTypesImages[type])")
                //                                    .padding()
                //                                    .background(activeIndex == -1 || activeIndex == type ? Color("Gray") : Color(.placeholderText))
                //                                    .cornerRadius(20)
                //                                    .onTapGesture {
                //                                        if activeIndex == type {
                //                                            activeIndex = -1
                //                                            loadView()
                //                                        } else {
                //                                            activeIndex = type
                //                                            linii = linii.filter({$0.vehicles.last?.vehicleType == type})
                //                                        }
                //                                    }
                //                            }
                //                        }
                //                    }
                //                    .padding()
                ScrollViewReader {proxy in
                    ScrollView {
                        Picker("", selection: $pickerSelection) {
                            Text("Toate Liniile")
                                .tag(0)
                            Text("Favorite")
                                .tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding([.bottom, .leading, .trailing])
                        
                        if Connectivity.isConnectedToInternet == false  {
                            Spacer()
                            Text("Fără conexiune la internet")
                                .bold()
                            Text("Verifică conexiunea și reîncearcă.")
                        }
                        
                        if linii.isEmpty && pickerSelection == 1 && Connectivity.isConnectedToInternet{
                            Spacer()
                            Text("Nu sunt vehicule favorite active la această oră.")
                                .bold()
                                .multilineTextAlignment(.center)
                            Text("Poți adauga noi favorite din ecranul Toate Liniile")
                                .multilineTextAlignment(.center)
                        }
                        
                        if vehicles.isEmpty && Connectivity.isConnectedToInternet{
                            ProgressView()
                        }
                        
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
                                HStack{
                                    Button {
                                        orareSelection = item.tripId
                                        selectedTab = 1
                                    } label: {
                                        Image(systemName: "calendar")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .padding([.leading, .trailing])
                                    }
                                    
                                    Button {
                                        UIApplication.shared.open(URL(string: "sms:open?addresses=7479&body=\(item.tripId)")!, options: [:], completionHandler: nil)
                                    } label: {
                                        Image(systemName: "ticket.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .padding([.leading, .trailing])
                                    }
                                    
                                    Button {
                                        if favorites.contains(item.tripId) {
                                            favorites.removeAll(where: {$0 == item.tripId})
                                            loadView()
                                        } else {
                                            favorites.append(item.tripId)
                                        }
                                        UserDefaults().set(favorites, forKey: Constants.USER_DEFAULTS_FAVORITES)
                                    } label: {
                                        Image(systemName: favorites.contains(item.tripId) ? "heart.fill" : "heart")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .padding([.leading, .trailing])
                                    }
                                }.padding(.bottom)
                                ForEach(item.vehicles, id:\.self) {vehicle in
                                    VStack{
                                        HStack{
                                            VStack{
                                                Text("STAȚIE CURENTĂ")
                                                    .font(.footnote)
                                                    .foregroundColor(.secondary)
                                                Text("\(vehicle.statie ?? "Necunoscută")")
                                                    .padding(.bottom)
                                                Text("SPRE")
                                                    .font(.footnote)
                                                    .foregroundColor(.secondary)
                                                if vehicle.tripId?.components(separatedBy: "_").last ?? "" == "1" {
                                                    Text(vehicle.routeLongName?.components(separatedBy: " - ").last ?? "")
                                                } else {
                                                    Text(vehicle.routeLongName?.components(separatedBy: " - ").first ?? "")
                                                }
                                            }.padding([.trailing, .leading, .bottom])
                                            Spacer()
                                            VStack{
                                                Text("ETA")
                                                    .font(.footnote)
                                                    .foregroundColor(.secondary)
                                                Text("\(vehicle.eta ?? 0) min")
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
                            }.id(item)
                            Text(" ")
                                .font(.footnote)
                        }
                        .onChange(of: searchText) { _ in
                            if linii.isEmpty {
                                pickerSelection = 0
                            }
                            let firstResult = linii.first(where: {$0.tripId.contains(searchText) == true})
                            if firstResult == nil {
                                proxy.scrollTo(linii.first, anchor: .top)
                            } else {
                                proxy.scrollTo(firstResult, anchor: .top)
                            }
                        }
                    }
                }
            }
            .onAppear() {
                pickerSelection = 1
                favorites = UserDefaults.standard.value(forKey: Constants.USER_DEFAULTS_FAVORITES) as? [String] ?? [String()]
                for i in 0..<vehicles.count {
                    if !availableTypes.contains(vehicles[i].vehicleType ?? 0) {
                        availableTypes.append(vehicles[i].vehicleType!)
                    }
                }
                linii = linii.filter({favorites.contains($0.tripId)})
            }
            .onChange(of: pickerSelection, perform: { newVal in
                if newVal == 0 {
                    loadView()
                } else {
                    let favorites = UserDefaults.standard.value(forKey: Constants.USER_DEFAULTS_FAVORITES) as? [String?] ?? [String()]
                    linii = linii.filter({favorites.contains($0.tripId)})
                }
            })
            .onChange(of: linii, perform: { _ in
                if pickerSelection == 1 {
                    let favorites = UserDefaults.standard.value(forKey: Constants.USER_DEFAULTS_FAVORITES) as? [String?] ?? [String()]
                    linii = linii.filter({favorites.contains($0.tripId)})
                }
                
                for j in 0..<linii.count {
                    for i in 0..<linii[j].vehicles.count {
                        let vehicleLocation = CLLocation(latitude: linii[j].vehicles[i].latitude ?? 0, longitude: linii[j].vehicles[i].longitude ?? 0)
                        let distance = (locationManager.lastLocation?.distance(from: vehicleLocation) ?? 0) / 1000
                        
                        if linii[j].vehicles[i].speed != 0 {
                            linii[j].vehicles[i].eta = Int(floor(distance/Double((linii[j].vehicles[i].speed ?? 1))*60))
                        }
                        if linii[j].vehicles[i].speed == 0 || linii[j].vehicles[i].eta ?? 0 > 100 {
                            linii[j].vehicles[i].eta = Int((distance/15)*60)
                        }
                    }
                }
            })
            .onDisappear {
                pickerSelection = 0
            }
            .navigationTitle("Favorite")
            .searchable(text: $searchText, prompt: "Caută o linie")
        }
    }
    
    func loadView() {
        Task(priority: .high) {
            var newVehicles = [Vehicle]()
            do {
                newVehicles = try await RequestManager().getVehicles()
                trips = try await RequestManager().getTrips()
                routes = try await RequestManager().getRoutes()
            } catch let err {
                print(err)
            }
            vehicles.removeAll()
            vehicles = newVehicles
            
            vehicles = vehicles.filter({vehicle in vehicle.latitude != nil && vehicle.longitude != nil && vehicle.tripId != nil && vehicle.routeId != nil && routes.contains(where: {route in route.routeId == vehicle.routeId})})
            
            var stops = [Statie]()
            do {
                stops = try await RequestManager().getStops()
            } catch let err {
                print(err)
            }
            
            var stopTimes = [StopTime]()
            do {
                stopTimes = try await RequestManager().getStopTimes()
            } catch let err {
                print(err)
            }
            
            linii.removeAll()
            let constantLinii = Constants.linii
            for elem in constantLinii {
                linii.append(Linii(tripId: elem, vehicles: [Vehicle](), favorite: false))
            }
            
            for i in 0..<vehicles.count {
                var closestStopName = "", minimumDistance = 100.0
                let vehicleSpecificStopTime = stopTimes.filter({$0.tripId == vehicles[i].tripId})
                for k in 0..<vehicleSpecificStopTime.count {
                    let stopTime = vehicleSpecificStopTime[k]
                    let stop = stops.first(where: {$0.stopId == Int(stopTime.stopId!)})
                    let stopLocation = CLLocation(latitude: stop?.lat ?? 0, longitude: stop?.long ?? 0)
                    let vehicleLocation = CLLocation(latitude: vehicles[i].latitude ?? 0, longitude: vehicles[i].longitude ?? 0)
                    let distance = vehicleLocation.distance(from: stopLocation) / 1000
                    if minimumDistance > distance {
                        minimumDistance = distance
                        closestStopName = stop?.stopName ?? ""
                    }
                }
                vehicles[i].routeShortName = routes.first(where: {$0.routeId == vehicles[i].routeId})?.routeShortName
                print("\n")
                vehicles[i].routeLongName = routes.first(where: {$0.routeId == vehicles[i].routeId})?.routeLongName
                vehicles[i].statie = closestStopName
                
                let indexCoresp = linii.firstIndex(where: {$0.tripId == vehicles[i].routeShortName})
                
                if let indexCoresp = indexCoresp {
                    linii[indexCoresp].vehicles.append(vehicles[i])
                }
            }
        }
    }
}
