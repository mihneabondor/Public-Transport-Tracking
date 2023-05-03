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
    @Binding var trips : [Trip]
    @Binding var selectedTab : Int
    @Binding var orareSelection : String
    @State var busView : Bool = true
    @State var stops = [Statie]()
    
    @StateObject var userLocation = LocationManager()
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: LocationManager().lastLocation?.coordinate.latitude ?? 46.7712, longitude: LocationManager().lastLocation?.coordinate.longitude ?? 23.6236), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
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
    
    @State var selectedDetent : PresentationDetent = .medium
    @State var directionSteps = [DecodedSteps]()
    @State private var showDirectionsScreen = false
    @State private var showDonationsScreen = false
    @EnvironmentObject var userViewModel : UserViewModel
    
    var body: some View {
        ZStack{
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: annotations, annotationContent: { location in
                MapAnnotation(coordinate: location.coordinates) {
                    if location.type == 0  && location.vehicle != nil{
                        Button {
                            if directionSteps.isEmpty {
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
                            }.opacity(location.vehicle?.userBetweenVehicleAndDestination == true ? 1 : 0.6)
                            .background (
                                Rectangle()
                                    .frame(width: 35, height: 40)
                                    .foregroundColor(favorites.contains(location.vehicle?.routeShortName ?? "") ? .indigo : .purple)
                                    .opacity(location.vehicle?.userBetweenVehicleAndDestination == true ? 1 : 0.6)
                                    .cornerRadius(5)
                            )
                        }
                    } else if location.type == 1 && location.statie != nil{
                        Button {
                            if directionSteps.isEmpty {
                                statieStationDetail = location.statie?.stopName ?? ""
                                systemImgStationDetail = "bus.fill"
                                selectedStation = location.statie!
                                withAnimation {
                                    showStationDetail.toggle()
                                }
                                if showStationDetail == false {
                                    focusedVehicleTripId = ""
                                    focusedVehicleNearestStop = ""
                                }
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
                    } else if location.type == 2 {
                        Image(systemName: "house.fill")
                            .foregroundColor(.white)
                            .font(.footnote)
                            .background (
                                Rectangle()
                                    .frame(width: 25, height: 30)
                                    .foregroundColor(.indigo)
                                    .cornerRadius(5)
                            )
                    } else if location.type == 3 {
                        Image(systemName: "flag.checkered")
                            .foregroundColor(.white)
                            .font(.footnote)
                            .background (
                                Rectangle()
                                    .frame(width: 25, height: 30)
                                    .foregroundColor(.indigo)
                                    .cornerRadius(5)
                            )
                    }
                }
            }).edgesIgnoringSafeArea([.top, .bottom])
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
                                if busView {
                                    searchResults = vehicles.filter({$0.routeShortName?.contains(text) == true})
                                }
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
                        VStack {
                            Button{
                                withAnimation{
                                    region = MKCoordinateRegion(center: userLocation.lastLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                                }
                            } label: {
                                Image(systemName: "location")
                                    .padding(10)
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .background(Color(UIColor.systemGray4))
                                    .cornerRadius(5)
                            }
                            Button{
                                showDirectionsScreen.toggle()
                            } label: {
                                Image(systemName: "signpost.right.and.left")
                                    .padding(10)
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .background(Color(UIColor.systemGray4))
                                    .cornerRadius(5)
                            }
                            Button{
                                busView.toggle()
                                annotations.removeAll()
                                
                                if !busView {
                                    Task {
                                        var stops = [Statie]()
                                        do {
                                            stops = try await RequestManager().getStops()
                                        } catch let err {
                                            print(err)
                                        }
                                        for stop in stops {
                                            let location = CLLocationCoordinate2D(latitude: stop.lat ?? 0, longitude: stop.long ?? 0)
                                            annotations.append(Annotation(type: 1, coordinates: location, vehicle: nil, statie: stop))
                                        }
                                    }
                                } else {
                                    FavoritesScreen.init(vehicles: $vehicles, linii: $linii, routes: $routes, trips: $trips, selectedTab: $selectedTab, orareSelection: $orareSelection, pickerSelection: 0).loadView()
                                }
                            } label: {
                                Image(systemName: busView ? "bus.fill" : "door.garage.open")
                                    .padding(10)
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .background(Color(UIColor.systemGray4))
                                    .cornerRadius(5)
                            }
                            
                            Button{
                                showDonationsScreen = true
                            } label: {
                                Image(systemName: "cup.and.saucer.fill")
                                    .padding(10)
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .background(Color(UIColor.systemGray4))
                                    .cornerRadius(5)
                            }
                        }
                    }
                    .padding(.trailing, 20)
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
                                            Text("Spre: \(result.headsign ?? "")")
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
                            }.transition(.move(edge: .bottom))
                        }
                    }
                }
                Spacer()
                ZStack{
                    if showBusDetail {
                        BusDetailView(vehicle: $selectedVehicle, closeView: $showBusDetail, selectedTab: $selectedTab, orareSelection: $orareSelection)
                            .transition(.move(edge: .bottom))
                            .offset(y: -30)
                            .padding()
                    }
                    if showStationDetail{
                        StationView(statie: $statieStationDetail, systemImage: $systemImgStationDetail, closeView: $showStationDetail, stop: $selectedStation, vehicles: $vehicles, details: $stationDetails)
                            .transition(.move(edge: .bottom))
                            .padding()
                    }
                }
            }
        }
        .onChange(of: searchFieldFocus) {_ in
            showBusDetail = false
            showStationDetail = false
        }
        .onChange(of: stationDetails, perform: { _ in
            if busView {
                annotations.removeAll()
                for stationDetail in stationDetails {
                    let location = CLLocationCoordinate2D(latitude: stationDetail.vehicle.latitude ?? 0, longitude: stationDetail.vehicle.longitude ?? 0)
                    annotations.append(Annotation(type: 0, coordinates: location, vehicle: stationDetail.vehicle, statie: nil))
                }
                let location = CLLocationCoordinate2D(latitude: selectedStation.lat ?? 0, longitude: selectedStation.long ?? 0)
                annotations.append(Annotation(type: 1, coordinates: location, vehicle: nil, statie: selectedStation))
            }
        })
        .onChange(of: showStationDetail, perform: { _ in
            stationDetails.removeAll()
            withAnimation {
                showBusDetail = false
            }
            if showStationDetail == false {
                focusedVehicleTripId = ""
                focusedVehicleNearestStop = ""
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
            if !directionSteps.isEmpty {
                DispatchQueue.main.async {
                    let oldAnnotations = annotations
                    annotations.removeAll(where: {$0.type == 0})
                    for vehicle in vehicles {
                        if oldAnnotations.contains(where: {annotation in annotation.vehicle?.label ?? "0" == vehicle.label ?? "0"}) == true {
                            let location = CLLocationCoordinate2D(latitude: vehicle.latitude ?? 0, longitude: vehicle.longitude ?? 0)
                            let annotation = Annotation(type: 0, coordinates: location, vehicle: vehicle, statie: nil)
                            annotations.append(annotation)
                        }
                    }
                }
            } else
            if busView {
                DispatchQueue.main.async {
                    searchResults.removeAll()
                    withAnimation {
                        searchResults = vehicles.filter({$0.routeShortName?.contains(searchText) == true})
                    }
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
        }
        .onChange(of: showDirectionsScreen, perform: { _ in
            showBusDetail = false
            showStationDetail = false
        })
        .sheet(isPresented: $showDonationsScreen, onDismiss: {}, content: {
            DonationsView().presentationDetents([.medium])
        })
        .onAppear() {
            region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: userLocation.lastLocation?.coordinate.latitude ?? 46.7712, longitude: userLocation.lastLocation?.coordinate.longitude ?? 23.6236), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            FavoritesScreen.init(vehicles: $vehicles, linii: $linii, routes: $routes, trips: $trips, selectedTab: $selectedTab, orareSelection: $orareSelection, pickerSelection: 0).loadView()
            favorites = UserDefaults.standard.object(forKey: Constants.USER_DEFAULTS_FAVORITES) as? [String] ?? [String]()
            DispatchQueue.main.async {
                for elem in vehicles {
                    annotations.append(Annotation(type: 0, coordinates: CLLocationCoordinate2D(latitude: elem.latitude ?? 0, longitude: elem.longitude ?? 0), vehicle: elem, statie: nil))
                }
            }
            Task {
                do {
                    stops = try await RequestManager().getStops()
                } catch let err {
                    print(err)
                }
            }
        }
        .bottomSheet(presentationDetents: userViewModel.isSubscriptionAcitve ? [.fraction(0.25), .medium, .large] : [.large], selectedDetent: $selectedDetent, isPresented: $showDirectionsScreen, dragIndicator: .visible, sheetCornerRadius: 20) {
            if userViewModel.isSubscriptionAcitve {
                MapToolbar(region: $region, selectedDetent: $selectedDetent, annotations: $annotations, vehicles: $vehicles, stops: $stops, steps: $directionSteps)
            } else {
                SubscriptionPaywallView()
            }
        } onDismiss: {
            selectedDetent = .medium
            directionSteps.removeAll()
            annotations.removeAll()
            FavoritesScreen.init(vehicles: $vehicles, linii: $linii, routes: $routes, trips: $trips, selectedTab: $selectedTab, orareSelection: $orareSelection, pickerSelection: 0).loadView()
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
