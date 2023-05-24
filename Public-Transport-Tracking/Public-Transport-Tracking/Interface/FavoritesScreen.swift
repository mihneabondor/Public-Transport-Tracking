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
    @State var linii = [Linii]()
    
    @Binding var selectedTab : Int
    @Binding var orareSelection : String
    
    var vehicleTypes = ["Tramvai", "Metro", "Tren", "Autobus", "Ferry", "Cable tram", "Aerial Lift", "Funicular", "", "", "", "Troleibus", "Monorail"]
    var vehicleTypesImages = ["tram.fill", "train.side.front.car", "train.side.front.car", "bus.fill", "ferry.fill", "cablecar.fill", "helicopter.fill", "bus.fill", "", "", "", "bus.doubledecker.fill", "bus.fill"]
    
    @State var adrese = [String]()
    @State private var loadingFirstTime = true
    
    @State var pickerSelection = 1
    @State private var favorites = [String()]
    @State private var searchText = ""
    @State private var loading = false
    
    @State private var userNearestStop = ""
    
    @EnvironmentObject var userViewModel : UserViewModel
    @EnvironmentObject var transitModel : TransitViewModel
    @EnvironmentObject var locationManager : LocationManager
    var body: some View {
        NavigationView {
            VStack{
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
                        
                        if transitModel.vehicles.isEmpty && Connectivity.isConnectedToInternet{
                            ProgressView()
                                .padding()
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
                                    
                                    if item.vehicles.count > 0 {
                                        Button {
                                            withAnimation {
                                                linii[linii.firstIndex(where: {$0 == item}) ?? 0].showMenu.toggle()
                                            }
                                        } label: {
                                            Image(systemName: item.showMenu ? "chevron.down" : "chevron.left")
                                        }.padding(.trailing)
                                    }
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
                                        Image(systemName: "ticket")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .padding([.leading, .trailing])
                                    }
                                    
                                    Button {
                                        if favorites.contains(item.tripId) {
                                            favorites.removeAll(where: {$0 == item.tripId})
                                            let generator = UINotificationFeedbackGenerator()
                                            generator.notificationOccurred(.success)
                                        } else {
                                            favorites.append(item.tripId)
                                            let generator = UINotificationFeedbackGenerator()
                                            generator.notificationOccurred(.success)
                                        }
                                        createLines()
                                        UserDefaults().set(favorites, forKey: Constants.USER_DEFAULTS_FAVORITES)
                                    } label: {
                                        Image(systemName: favorites.contains(item.tripId) ? "heart.fill" : !userViewModel.isSubscriptionAcitve && favorites.count > 2 ? "heart.slash" : "heart")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .padding([.leading, .trailing])
                                    }.disabled(!favorites.contains(item.tripId) && !userViewModel.isSubscriptionAcitve && favorites.count > 2)
                                }.padding(.bottom)
                                
                                if item.showMenu {
                                    Grid {
                                        ForEach(item.vehicles, id:\.self) {vehicle in
                                            GridRow {
                                                VStack{
                                                    Text("STAȚIE CURENTĂ")
                                                        .font(.footnote)
                                                        .foregroundColor(.secondary)
                                                    HStack {
                                                        Text("\(vehicle.statie ?? "Necunoscută")")
                                                        Image(systemName: "map")
                                                            .font(.callout)
                                                    }
                                                        .padding(.bottom)
                                                        .onTapGesture {
                                                            let location = CLLocationCoordinate2D(latitude: vehicle.latitude ?? 0, longitude: vehicle.longitude ?? 0)
                                                            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                                                            locationManager.region = MKCoordinateRegion(center: location, span: span)
                                                            selectedTab = 2
                                                        }
                                                }
                                                
                                                VStack {
                                                    Text("ETA")
                                                        .font(.footnote)
                                                        .foregroundColor(.secondary)
                                                    Text("\(vehicle.eta ?? 0) min")
                                                        .padding(.bottom)
                                                }
                                            }
                                            .contextMenu {
                                                Button {
                                                    let location = CLLocationCoordinate2D(latitude: vehicle.latitude ?? 0, longitude: vehicle.longitude ?? 0)
                                                    let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                                                    locationManager.region = MKCoordinateRegion(center: location, span: span)
                                                    selectedTab = 2
                                                } label: {
                                                    Label("Vezi în hartă", systemImage: "map.fill")
                                                }
                                            }
                                            
                                            GridRow {
                                                VStack {
                                                    Text("SPRE")
                                                        .font(.footnote)
                                                        .foregroundColor(.secondary)
                                                    Text(vehicle.headsign ?? "Necunoscut")
                                                }
                                                VStack{
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
                                                }
                                            }
                                            Divider()
                                                .background(Color.purple)
                                                .transition(.move(edge: .top))
                                        }
                                    }
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
            .onAppear {
                pickerSelection = 1
                createLines()
                favorites = (UserDefaults.standard.value(forKey: Constants.USER_DEFAULTS_FAVORITES) as? [String]? ?? [String]()) ?? [String]()
                linii = linii.filter({favorites.contains($0.tripId)})
            }
            .onChange(of: pickerSelection, perform: { newVal in
                if newVal == 0 {
                    linii.removeAll()
                    createLines()
                } else {
                    let favorites = UserDefaults.standard.value(forKey: Constants.USER_DEFAULTS_FAVORITES) as? [String?] ?? [String()]
                    linii = linii.filter({favorites.contains($0.tripId)})
                }
            })
            .onDisappear {
                pickerSelection = 0
            }
            .onChange(of: transitModel.vehicles) { _ in
                createLines()
                
                if pickerSelection == 1 {
                    let favorites = UserDefaults.standard.value(forKey: Constants.USER_DEFAULTS_FAVORITES) as? [String?] ?? [String()]
                    linii = linii.filter({favorites.contains($0.tripId)})
                }
            }
            .navigationTitle("Favorite")
            .searchable(text: $searchText, prompt: "Caută o linie")
        }
    }
    
    func createLines() {
        if linii.isEmpty {
            let constantLinii = Constants.linii
            for elem in constantLinii {
                linii.append(Linii(tripId: elem, vehicles: [Vehicle](), favorite: false))
            }
            
            for i in 0..<transitModel.vehicles.count {
                let indexCoresp = linii.firstIndex(where: {$0.tripId == transitModel.vehicles[i].routeShortName})
                if let indexCoresp = indexCoresp {
                    linii[indexCoresp].vehicles.append(transitModel.vehicles[i])
                }
            }
        } else {
            for i in 0..<linii.count {
                for j in 0..<linii[i].vehicles.count {
                    let correspondingVehicle = transitModel.vehicles.first(where: {$0.id ?? 0 == linii[i].vehicles[j].id ?? 0}) ?? nil
                    if let correspondingVehicle = correspondingVehicle {
                        linii[i].vehicles[j] = correspondingVehicle
                    }
                }
            }
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
        
        let stops = transitModel.stops.sorted(by: {stop1, stop2 in
            let stopCoord1 = CLLocation(latitude: stop1.lat ?? 0, longitude: stop1.long ?? 0)
            let stopCoord2 = CLLocation(latitude: stop2.lat ?? 0, longitude: stop2.long ?? 0)
            
            let distance1 = (locationManager.lastLocation?.distance(from: stopCoord1) ?? 0) / 1000
            let distance2 = (locationManager.lastLocation?.distance(from: stopCoord2) ?? 0) / 1000
            return distance1 < distance2
        })
        
        let nearestStop = stops.first ?? nil
        
        if let nearestStop = nearestStop {
            DispatchQueue.main.async {
                for i in 0..<transitModel.vehicles.count {
                    let vehicleStopTimes = transitModel.stopTimes.filter({$0.tripId == transitModel.vehicles[i].tripId})
                    let stopSqRelativeToUser = vehicleStopTimes.first(where: {Int($0.stopId ?? "0") == nearestStop.stopId})?.sq
                    let currentStopId = stops.first(where: {$0.stopName == transitModel.vehicles[i].statie})?.stopId
                    let stopSqCurrent = vehicleStopTimes.first(where: {Int($0.stopId ?? "0") == currentStopId})?.sq
                    if vehicleStopTimes.contains(where: {Int($0.stopId ?? "0") == nearestStop.stopId}) && stopSqCurrent ?? 0 <= stopSqRelativeToUser ?? 0{
                        transitModel.vehicles[i].userBetweenVehicleAndDestination = true
                    }
                }
            }
        }
    }
    
    //    func loadView() {
    //        Task(priority: .high) {
    //            var newVehicles = [Vehicle]()
    //            do {
    //                newVehicles = try await RequestManager().getVehicles()
    //            } catch let err {
    //                print(err)
    //            }
    //
    //            if newVehicles.isEmpty {
    //                loadView()
    //            }
    //
    //            var stops = [Statie]()
    //            do {
    //                stops = try await RequestManager().getStops()
    //            } catch let err {
    //                print(err)
    //            }
    //
    //            var stopTimes = [StopTime]()
    //            do {
    //                stopTimes = try await RequestManager().getStopTimes()
    //            } catch let err {
    //                print(err)
    //            }
    //
    //            vehicles.removeAll()
    //            vehicles = newVehicles
    //
    //            vehicles = vehicles.filter({vehicle in vehicle.latitude != nil && vehicle.longitude != nil && vehicle.tripId != nil && vehicle.routeId != nil && routes.contains(where: {route in route.routeId == vehicle.routeId})})
    //
    //            linii.removeAll()
    //            let constantLinii = Constants.linii
    //            for elem in constantLinii {
    //                linii.append(Linii(tripId: elem, vehicles: [Vehicle](), favorite: false))
    //            }
    //
    //            for i in 0..<vehicles.count {
    //                var closestStopName = "", minimumDistance = 100.0
    //                let vehicleSpecificStopTime = stopTimes.filter({$0.tripId == vehicles[i].tripId})
    //                for k in 0..<vehicleSpecificStopTime.count {
    //                    let stopTime = vehicleSpecificStopTime[k]
    //                    let stop = stops.first(where: {$0.stopId == Int(stopTime.stopId!)})
    //                    let stopLocation = CLLocation(latitude: stop?.lat ?? 0, longitude: stop?.long ?? 0)
    //                    let vehicleLocation = CLLocation(latitude: vehicles[i].latitude ?? 0, longitude: vehicles[i].longitude ?? 0)
    //                    let distance = vehicleLocation.distance(from: stopLocation) / 1000
    //                    if minimumDistance > distance {
    //                        minimumDistance = distance
    //                        closestStopName = stop?.stopName ?? ""
    //                    }
    //                }
    //                vehicles[i].routeShortName = routes.first(where: {$0.routeId == vehicles[i].routeId})?.routeShortName
    //                vehicles[i].routeLongName = routes.first(where: {$0.routeId == vehicles[i].routeId})?.routeLongName
    //                vehicles[i].statie = closestStopName
    //                vehicles[i].headsign = trips.first(where: {$0.tripId == vehicles[i].tripId})?.tripHeadsign ?? "-"
    //
    //                let indexCoresp = linii.firstIndex(where: {$0.tripId == vehicles[i].routeShortName})
    //
    //                if let indexCoresp = indexCoresp {
    //                    linii[indexCoresp].vehicles.append(vehicles[i])
    //                }
    //            }
    //        }
    //    }
}
