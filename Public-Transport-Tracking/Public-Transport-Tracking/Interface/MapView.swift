//
//  MapView.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/5/23.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Binding var vehicles : [Vehicle]
    @Binding var linii : [Linii]
    @Binding var routes : [Route]
    @Binding var selectedTab : Int
    @Binding var orareSelection : String
    
    @StateObject var location = LocationManager()
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: LocationManager().lastLocation?.coordinate.latitude ?? 0, longitude: LocationManager().lastLocation?.coordinate.longitude ?? 0), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    var vehicleTypes = ["Tramvai", "Metro", "Tren","Autobus", "Ferry", "Cable tram", "Aerial Lift", "Funicular", "", "", "", "Troleibus", "Monorail"]
    var vehicleTypesImages = ["tram.fill", "train.side.front.car", "train.side.front.car", "bus.fill", "ferry.fill", "cablecar.fill", "helicopter.fill", "bus.fill", "", "", "", "bus.doubledecker.fill", "bus.fill"]
    @State var searchText = ""
    @State private var searchResults = [Vehicle]()
    @FocusState var searchFieldFocus : Bool
    @State private var annotations = [Annotation]()
    @State private var focusedVehicleNearestStop = ""
    @State private var focusedVehicleTripId = ""
    
    @State var showStationDetail = false
    @State var statieStationDetail = ""
    @State var systemImgStationDetail = ""
    
    @State var showBusDetail = false
    @State var selectedVehicled : Vehicle?
    @State private var favorites = [String]()
    var body: some View {
        ZStack{
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: annotations, annotationContent: { location in
                MapAnnotation(coordinate: location.coordinates) {
                    if location.type == 0  && location.vehicle != nil{
                        Button {
                            withAnimation {
                                showBusDetail = true
                            }
                            selectedVehicled = location.vehicle
                            if focusedVehicleTripId == ""{
                                focusedVehicleNearestStop = location.vehicle?.statie ?? ""
                                focusedVehicleTripId = location.vehicle?.tripId ?? ""
                            } else {
                                focusedVehicleTripId = ""
                                focusedVehicleNearestStop = ""
                            }
                        } label: {
                            VStack {
                                Image(systemName: "\(vehicleTypesImages[location.vehicle?.vehicleType ?? 0])")
                                    .foregroundColor(.white)
                                    .font(.footnote)
                                Text(location.vehicle?.routeShortName ?? "")
                                    .bold()
                                    .font(.footnote)
                                    .foregroundColor(.white)
                            }
                            .background (
                                Rectangle()
                                    .frame(width: 35, height: 40)
                                    .foregroundColor(favorites.contains(location.vehicle?.routeShortName ?? "") ? .indigo : .purple)
                                    .cornerRadius(5)
                            )
                        }
                    } else if location.type == 1 && location.statie != nil{
                        Button {
                            statieStationDetail = location.statie?.stopName ?? ""
                            systemImgStationDetail = "bus.fill"
                            
                            withAnimation {
                                showStationDetail.toggle()
                            }
                        } label: {
                            Image(systemName: "door.garage.open")
                                .foregroundColor(.white)
                                .font(.footnote)
                                .allowsHitTesting(false)
                                .background (
                                    Rectangle()
                                        .frame(width: 25, height: 30)
                                        .foregroundColor(Color(UIColor.systemGray4))
                                        .cornerRadius(5)
                                )
                        }
                    }
                }
            }).edgesIgnoringSafeArea(.top)
            
            VStack{
                HStack{
                    TextField("Cauta o linie", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .tint(.white)
                        .foregroundColor(.white)
                        .padding()
                        .focused($searchFieldFocus)
                        .onChange(of: searchText) { text in
                            searchResults.removeAll()
                            withAnimation {
                                searchResults = vehicles.filter({$0.routeShortName?.contains(text) == true})
                            }
                        }
                    
                    if searchFieldFocus{
                        Button("Cancel"){
                            searchText = ""
                            searchFieldFocus = false
                            withAnimation {
                                searchResults.removeAll()
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.trailing)
                    }
                }
                if !searchFieldFocus {
                    HStack {
                        Spacer()
                        Button {
                            withAnimation {
                                region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.lastLocation?.coordinate.latitude ?? 0, longitude: location.lastLocation?.coordinate.longitude ?? 0), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                            }
                        } label: {
                            Image(systemName: "location.viewfinder")
                                .font(.title2)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color(UIColor.systemGray4))
                                .cornerRadius(10)
                        }
                        Text(" ")
                    }
                }
                if !searchResults.isEmpty{
                    ScrollView {
                        ForEach(searchResults) { result in
                            Text(" ")
                                .font(.footnote)
                            Button {
                                region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: result.latitude ?? 0, longitude: result.longitude ?? 0), span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
                                searchFieldFocus = false
                                searchText = ""
                                searchResults = [Vehicle]()
                            } label: {
                                HStack {
                                    Text(" ")
                                        .font(.footnote)
                                    Image(systemName: "\(vehicleTypesImages[result.vehicleType ?? 0])")
                                        .foregroundColor(.white)
                                        .font(.title3)
                                        .padding()
                                    VStack{
                                        HStack{
                                            Text("Linia \(result.routeShortName ?? "") de la \(result.statie ?? "")")
                                                .bold()
                                            Spacer()
                                        }
                                        HStack{
                                            Text(result.routeLongName ?? "")
                                            Spacer()
                                        }
                                    }
                                    Spacer()
                                }.background(
                                    Rectangle()
                                        .frame(width: UIScreen.main.bounds.width/1.05, height: 75)
                                        .foregroundColor(Color(UIColor.systemGray5))
                                        .cornerRadius(20)
                                )
                            }
                        }
                    }
                }
                Spacer()
                ZStack{
                    if showBusDetail {
                        BusDetailView(vehicle: $selectedVehicled, closeView: $showBusDetail, selectedTab: $selectedTab, orareSelection: $orareSelection)
                            .offset(y: -30)
                            .padding()
                    }
                    if showStationDetail{
                        StationView(statie: $statieStationDetail, systemImage: $systemImgStationDetail, closeView: $showStationDetail)
                            .padding()
                    }
                }
            }
        }
        .onChange(of: showStationDetail, perform: { _ in
            showBusDetail = false
            
            if showStationDetail == false {
                annotations.removeAll()
                for elem in vehicles {
                    annotations.append(Annotation(type: 0, coordinates: CLLocationCoordinate2D(latitude: elem.latitude ?? 0, longitude: elem.longitude ?? 0), vehicle: elem, statie: nil))
                }
                focusedVehicleTripId = ""
                focusedVehicleNearestStop = ""
            }
        })
        .onChange(of: showBusDetail, perform: { value in
            if value == false && showStationDetail == false{
                focusedVehicleTripId = ""
                focusedVehicleNearestStop = ""
            }
        })
        .onChange(of: focusedVehicleTripId, perform: { tripId in
            Task(priority: .high) {
                if focusedVehicleTripId == "" {
                    showStationDetail = false
                    annotations.removeAll()
                    for elem in vehicles {
                        annotations.append(Annotation(type: 0, coordinates: CLLocationCoordinate2D(latitude: elem.latitude ?? 0, longitude: elem.longitude ?? 0), vehicle: elem, statie: nil))
                    }
                } else {
                    annotations = annotations.filter({$0.vehicle?.tripId == focusedVehicleTripId && focusedVehicleNearestStop == $0.vehicle?.statie})
                    let stops = try! await RequestManager().getStops()
                    var stopTimes = try! await RequestManager().getStopTimes()
                    stopTimes = stopTimes.filter({$0.tripId == tripId})
                    
                    for i in 0..<stopTimes.count {
                        let stopTime = stopTimes[i]
                        let stop = stops.first(where: {$0.stopId == Int(stopTime.stopId!)})
                        annotations.append(Annotation(type: 1, coordinates: CLLocationCoordinate2D(latitude: stop?.lat ?? 0, longitude: stop?.long ?? 0), vehicle: nil, statie: stop))
                    }
                }
            }
        })
        .onChange(of: vehicles) {_ in
            DispatchQueue.main.async {
                if focusedVehicleTripId == "" {
                    annotations.removeAll()
                    for elem in vehicles {
                        annotations.append(Annotation(type: 0, coordinates: CLLocationCoordinate2D(latitude: elem.latitude ?? 0, longitude: elem.longitude ?? 0), vehicle: elem, statie: nil))
                    }
                } else {
                    let elem = vehicles.first(where: {$0.tripId == focusedVehicleTripId})
                    annotations.removeAll(where: {$0.type == 0})
                    annotations.append(Annotation(type: 0, coordinates: CLLocationCoordinate2D(latitude: elem?.latitude ?? 0, longitude: elem?.longitude ?? 0), vehicle: elem, statie: nil))
                }
            }
        }
        .onAppear() {
            region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.lastLocation?.coordinate.latitude ?? 0, longitude: location.lastLocation?.coordinate.longitude ?? 0), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            FavoritesScreen.init(vehicles: $vehicles, linii: $linii, routes: $routes, selectedTab: $selectedTab, orareSelection: $orareSelection, pickerSelection: 0).loadView()
            favorites = UserDefaults.standard.object(forKey: Constants.USER_DEFAULTS_FAVORITES) as? [String] ?? [String]()
            DispatchQueue.main.async {
                for elem in vehicles {
                    annotations.append(Annotation(type: 0, coordinates: CLLocationCoordinate2D(latitude: elem.latitude ?? 0, longitude: elem.longitude ?? 0), vehicle: elem, statie: nil))
                }
            }
        }
    }
}
