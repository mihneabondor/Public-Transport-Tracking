//
//  MapView.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/5/23.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @Binding var vehicles : [Vehicle]
    @Binding var linii : [Linii]
    @Binding var routes : [Route]
    @Binding var selectedTab : Int
    @Binding var orareSelection : String
    
    @StateObject var userLocation = LocationManager()
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: LocationManager().lastLocation?.coordinate.latitude ?? 0, longitude: LocationManager().lastLocation?.coordinate.longitude ?? 0), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    var vehicleTypes = ["Tramvai", "Metro", "Tren","Autobus", "Ferry", "Cable tram", "Aerial Lift", "Funicular", "", "", "", "Troleibus", "Monorail"]
    var vehicleTypesImages = ["tram.fill", "train.side.front.car", "train.side.front.car", "bus.fill", "ferry.fill", "cablecar.fill", "helicopter.fill", "bus.fill", "", "", "", "bus.doubledecker.fill", "bus.fill"]
    @State var searchText = ""
    @State private var searchResults = [Vehicle]()
    @FocusState var searchFieldFocus : Bool
    @State private var annotations = [Annotation]()
    @State private var focusedVehicleNearestStop = ""
    @State private var focusedVehicleTripId = ""
    @State private var focusedVechile : Vehicle?
    
    @State var showStationDetail = false
    @State var statieStationDetail = ""
    @State var systemImgStationDetail = ""
    @State var selectedStation = Statie(stopId: 0, stopName: "", stopDesc: "", lat: 0.0, long: 0.0, locationType: 0)
    @State var stationDetails = [StationDetails]()
    
    @State var showBusDetail = false
    @State var selectedVehicle : Vehicle?
    @State private var favorites = [String]()
    var body: some View {
        ZStack{
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: annotations, annotationContent: { location in
                MapAnnotation(coordinate: location.coordinates) {
                    if location.type == 0  && location.vehicle != nil{
                        Button {
                            let midCenter = CLLocationCoordinate2D(latitude: (location.coordinates.latitude + (userLocation.lastLocation?.coordinate.latitude ?? 0))/2, longitude: (location.coordinates.longitude + (userLocation.lastLocation?.coordinate.longitude ?? 0))/2)
                            let midSpan = MKCoordinateSpan(latitudeDelta: abs((location.coordinates.latitude - (userLocation.lastLocation?.coordinate.latitude ?? 0)))*2, longitudeDelta: abs((location.coordinates.longitude - (userLocation.lastLocation?.coordinate.longitude ?? 0))*2))
                            withAnimation {
                                showBusDetail = true
                            }
                            withAnimation {
                                region = MKCoordinateRegion(center: midCenter, span: midSpan)
                            }
                            selectedVehicle = location.vehicle
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
                            selectedStation = location.statie!
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
                                region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: userLocation.lastLocation?.coordinate.latitude ?? 0, longitude: userLocation.lastLocation?.coordinate.longitude ?? 0), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
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
                                                .foregroundColor(.white)
                                                .bold()
                                            Spacer()
                                        }
                                        HStack{
                                            Text(result.routeLongName ?? "")
                                                .foregroundColor(.white)
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
                        BusDetailView(vehicle: $selectedVehicle, closeView: $showBusDetail, selectedTab: $selectedTab, orareSelection: $orareSelection)
                            .offset(y: -30)
                            .padding()
                    }
                    if showStationDetail{
                        StationView(statie: $statieStationDetail, systemImage: $systemImgStationDetail, closeView: $showStationDetail, stop: selectedStation, vehicles: vehicles, details: $stationDetails)
                            .padding()
                    }
                }
            }
        }
        .onChange(of: stationDetails, perform: { _ in
            annotations.removeAll()
            for stationDetail in stationDetails {
                let location = CLLocationCoordinate2D(latitude: stationDetail.vehicle.latitude ?? 0, longitude: stationDetail.vehicle.longitude ?? 0)
                annotations.append(Annotation(type: 0, coordinates: location, vehicle: stationDetail.vehicle, statie: nil))
            }
            let location = CLLocationCoordinate2D(latitude: selectedStation.lat ?? 0, longitude: selectedStation.long ?? 0)
            annotations.append(Annotation(type: 1, coordinates: location, vehicle: nil, statie: selectedStation))
        })
        .onChange(of: showStationDetail, perform: { _ in
            stationDetails.removeAll()
            withAnimation {
                showBusDetail = false
            }
            if showStationDetail == false {
                withAnimation {
                    showBusDetail = true
                }
            }
        })
        .onChange(of: showBusDetail, perform: { value in
            if value == false && showStationDetail == false{
                focusedVehicleTripId = ""
                focusedVehicleNearestStop = ""
            }
            
            if value {
                loadFocusedVehicle()
            }
        })
        .onChange(of: focusedVehicleTripId, perform: { _ in
            loadFocusedVehicle()
        })
        .onChange(of: vehicles) {_ in
            DispatchQueue.main.async {
                if focusedVehicleTripId == "" {
                    DispatchQueue.main.async {
                        annotations.removeAll()
                        for elem in vehicles {
                            annotations.append(Annotation(type: 0, coordinates: CLLocationCoordinate2D(latitude: elem.latitude ?? 0, longitude: elem.longitude ?? 0), vehicle: elem, statie: nil))
                        }
                    }
                } else {
                    if stationDetails.isEmpty {
                        let elem = vehicles.first(where: {$0.label == selectedVehicle?.label})
                        DispatchQueue.main.async {
                            annotations.removeAll(where: {$0.type == 0})
                            annotations.append(Annotation(type: 0, coordinates: CLLocationCoordinate2D(latitude: elem?.latitude ?? 0, longitude: elem?.longitude ?? 0), vehicle: elem, statie: nil))
                        }
                    } else {
                        annotations.removeAll()
                        for elem in vehicles {
                            if stationDetails.contains(where: {$0.vehicle == elem}) {
                                let location = CLLocationCoordinate2D(latitude: elem.latitude ?? 0, longitude: elem.longitude ?? 0)
                                annotations.append(Annotation(type: 0, coordinates: location, vehicle: elem, statie: nil))
                            }
                        }
                        let location = CLLocationCoordinate2D(latitude: selectedStation.lat ?? 0, longitude: selectedStation.long ?? 0)
                        annotations.append(Annotation(type: 1, coordinates: location, vehicle: nil, statie: selectedStation))
                    }
                }
                if !stationDetails.isEmpty {
                    annotations.removeAll()
                    for elem in vehicles {
                            if stationDetails.contains(where: {$0.vehicle.label == elem.label}) {
                            let location = CLLocationCoordinate2D(latitude: elem.latitude ?? 0, longitude: elem.longitude ?? 0)
                            annotations.append(Annotation(type: 0, coordinates: location, vehicle: elem, statie: nil))
                        }
                    }
                    let location = CLLocationCoordinate2D(latitude: selectedStation.lat ?? 0, longitude: selectedStation.long ?? 0)
                    annotations.append(Annotation(type: 1, coordinates: location, vehicle: nil, statie: selectedStation))
                }
            }
        }
        .onAppear() {
            region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: userLocation.lastLocation?.coordinate.latitude ?? 46.7712, longitude: userLocation.lastLocation?.coordinate.longitude ?? 23.6236), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            FavoritesScreen.init(vehicles: $vehicles, linii: $linii, routes: $routes, selectedTab: $selectedTab, orareSelection: $orareSelection, pickerSelection: 0).loadView()
            favorites = UserDefaults.standard.object(forKey: Constants.USER_DEFAULTS_FAVORITES) as? [String] ?? [String]()
            DispatchQueue.main.async {
                for elem in vehicles {
                    annotations.append(Annotation(type: 0, coordinates: CLLocationCoordinate2D(latitude: elem.latitude ?? 0, longitude: elem.longitude ?? 0), vehicle: elem, statie: nil))
                }
            }
        }
    }
    
    func loadFocusedVehicle() {
        Task(priority: .high) {
            if focusedVehicleTripId == "" {
                showStationDetail = false
                DispatchQueue.main.async {
                    annotations.removeAll()
                    for elem in vehicles {
                        annotations.append(Annotation(type: 0, coordinates: CLLocationCoordinate2D(latitude: elem.latitude ?? 0, longitude: elem.longitude ?? 0), vehicle: elem, statie: nil))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    annotations = annotations.filter({$0.vehicle?.tripId == focusedVehicleTripId && focusedVehicleNearestStop == $0.vehicle?.statie})
                }
                
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
                
                stopTimes = stopTimes.filter({$0.tripId == focusedVehicleTripId})
                DispatchQueue.main.async {
                    for i in 0..<stopTimes.count {
                        let stopTime = stopTimes[i]
                        let stop = stops.first(where: {$0.stopId == Int(stopTime.stopId!)})
                        annotations.append(Annotation(type: 1, coordinates: CLLocationCoordinate2D(latitude: stop?.lat ?? 0, longitude: stop?.long ?? 0), vehicle: nil, statie: stop))
                    }
                }
            }
        }
    }
}
