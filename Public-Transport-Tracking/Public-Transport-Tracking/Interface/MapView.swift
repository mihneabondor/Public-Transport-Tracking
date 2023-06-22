//
//  MapView.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/5/23.
//

import SwiftUI
import MapKit
import CoreLocation
import Map

@available(iOS 16.0, *)
struct MapView: View {
    @Binding var selectedTab : Int
    @Binding var orareSelection : String
    @Binding var url : URL
    @State var busView : Bool = true
    @State var stops = [Statie]()
    
    var vehicleTypes = ["Tramvai", "Metro", "Tren","Autobus", "Ferry", "Cable tram", "Aerial Lift", "Funicular", "", "", "", "Troleibus", "Monorail"]
    var vehicleTypesImages = ["tram.fill", "train.side.front.car", "train.side.front.car", "bus.fill", "ferry.fill", "cablecar.fill", "helicopter.fill", "bus.fill", "", "", "", "bus.doubledecker.fill", "bus.fill"]
    @State var searchText = ""
    @State private var searchResults = [Vehicle]()
    @FocusState var searchFieldFocus : Bool
    @State private var focusedVehicleNearestStop = ""
    @State private var focusedVehicleTripId = ""
    
    @State var showStationDetail = false
    @State var statieStationDetail = ""
    @State var systemImgStationDetail = ""
    @State var selectedStation = Statie(stopId: 0, stopName: "", stopDesc: "", lat: 0.0, long: 0.0, locationType: 0)
    @State var stationDetails = [StationDetails]()
    
    @State var showBusDetail = false
    @State var selectedVehicle : Vehicle?
    @State var favorites = [String]()
    
    @State var selectedDetent : PresentationDetent = .medium
    @State var directionSteps = [DecodedSteps]()
    @State private var showDirectionsScreen = false
    @State private var showDonationsScreen = false
    @EnvironmentObject var userViewModel : UserViewModel
    
    @StateObject var motion = MotionManager()
    @EnvironmentObject var transitModel : TransitViewModel
    @EnvironmentObject var userLocation : LocationManager
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 46.7712, longitude: 23.6236), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    @State private var annotations = [Annotation]()
    
    @State var showARScreen = false
    
    @State private var expandMenu = false
    
    var body: some View {
        ZStack{
            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, annotationItems: annotations, annotationContent: { location in
                MapAnnotation(coordinate: location.coordinates) {
                    if location.type == 0  && location.vehicle != nil{
                        Button {
                            if directionSteps.isEmpty {
                                let midCenter = CLLocationCoordinate2D(latitude: (location.coordinates.latitude + (userLocation.lastLocation?.coordinate.latitude ?? 0))/2, longitude: (location.coordinates.longitude + (userLocation.lastLocation?.coordinate.longitude ?? 0))/2)
                                let midSpan = MKCoordinateSpan(latitudeDelta: abs((location.coordinates.latitude - (userLocation.lastLocation?.coordinate.latitude ?? 0)))*2, longitudeDelta: abs((location.coordinates.longitude - (userLocation.lastLocation?.coordinate.longitude ?? 0))*2))
                                withAnimation{
                                    region = MKCoordinateRegion(center: midCenter, span: midSpan)
                                }
                                withAnimation {
                                    showBusDetail = true
                                }
                                if selectedVehicle == nil{
                                    selectedVehicle = location.vehicle
                                    focusedVehicleNearestStop = location.vehicle?.statie ?? ""
                                    focusedVehicleTripId = location.vehicle?.tripId ?? ""
                                } else {
                                    selectedVehicle = nil
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
                .onAppear{
                    showBusDetail = false
                    showStationDetail = false
                    annotations = transitModel.annotations
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()+1){
                        if let stateRegion = userLocation.region {
                            region = stateRegion
                            userLocation.region = nil
                        } else {
                            let center = CLLocationCoordinate2D(latitude: userLocation.lastLocation?.coordinate.latitude ?? 0, longitude: userLocation.lastLocation?.coordinate.longitude ?? 0)
                            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            region = MKCoordinateRegion(center: center, span: span)
                        }
                    }
                }
                .onChange(of: transitModel.annotations) {annotation in
                    if busView && !showDirectionsScreen {
                        annotations.removeAll()
                        annotations = annotation
                    }
                }
            
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
                                    searchResults = transitModel.vehicles.filter({$0.routeShortName?.contains(text) == true})
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
                                    .background(Rectangle().fill(.shadow(.inner(radius: 10, x: -10, y: 10))).foregroundStyle(Color(.systemGray4)))
                                    .cornerRadius(5)
                            }
                            Button{
                                withAnimation {
                                    expandMenu.toggle()
                                }
                            } label: {
                                Image(systemName: "plus")
                                    .rotationEffect(expandMenu ? Angle(degrees: -45) : Angle(degrees: 0))
                                    .padding(10)
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .background(Rectangle().fill(.shadow(.inner(radius: 10, x: -10, y: 10))).foregroundStyle(Color(.systemGray4)))
                                    .cornerRadius(5)
                            }
                            if expandMenu {
                                Button{
                                    showDirectionsScreen.toggle()
                                } label: {
                                    Image(systemName: "signpost.right.and.left")
                                        .padding(10)
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .background(Rectangle().fill(.shadow(.inner(radius: 10, x: -10, y: 10))).foregroundStyle(Color(.systemGray4)))
                                        .cornerRadius(5)
                                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.4)))
                                        .zIndex(1)
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
                                                transitModel.annotations.append(Annotation(type: 1, coordinates: location, vehicle: nil, statie: stop))
                                            }
                                            annotations = transitModel.annotations.filter({$0.type == 1})
                                        }
                                    } else {
                                        transitModel.createAnnotations()
                                    }
                                } label: {
                                    Image(systemName: busView ? "bus.fill" : "door.garage.open")
                                        .padding(10)
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .background(Rectangle().fill(.shadow(.inner(radius: 10, x: -10, y: 10))).foregroundStyle(Color(.systemGray4)))
                                        .cornerRadius(5)
                                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.4)))
                                        .zIndex(1)
                                }
                                
                                Button{
                                    showARScreen = true
                                } label: {
                                    Image(systemName: "arkit")
                                        .padding(10)
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .background(Rectangle().fill(.shadow(.inner(radius: 10, x: -10, y: 10))).foregroundStyle(Color(.systemGray4)))
                                        .cornerRadius(5)
                                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.4)))
                                        .zIndex(1)
                                }
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
                        BusDetailView(vehicle: $selectedVehicle, closeView: $showBusDetail, selectedTab: $selectedTab, orareSelection: $orareSelection, favorites: $favorites)
                            .transition(.move(edge: .bottom))
                            .offset(x: motion.x*10, y: -30+motion.y*10)
                            .padding()
                    }
                    if showStationDetail{
                        StationView(statie: $statieStationDetail, systemImage: $systemImgStationDetail, closeView: $showStationDetail, stop: $selectedStation, details: $stationDetails)
                            .transition(.move(edge: .bottom))
                            .offset(x: motion.x*10, y: motion.y*10)
                            .padding()
                    }
                }
            }
        }
        .onChange(of: url, perform: { _ in
            let label = url["bus"]
            guard let vehicle = transitModel.vehicles.first(where: {$0.label == label}) else {return}
            let midCenter = CLLocationCoordinate2D(latitude: (vehicle.latitude! + (userLocation.lastLocation?.coordinate.latitude ?? 0))/2, longitude: (vehicle.longitude! + (userLocation.lastLocation?.coordinate.longitude ?? 0))/2)
            let midSpan = MKCoordinateSpan(latitudeDelta: abs((vehicle.latitude! - (userLocation.lastLocation?.coordinate.latitude ?? 0)))*2, longitudeDelta: abs((vehicle.longitude! - (userLocation.lastLocation?.coordinate.longitude ?? 0))*2))
            withAnimation{
                region = MKCoordinateRegion(center: midCenter, span: midSpan)
            }
            withAnimation {
                showBusDetail = true
            }
            selectedVehicle = vehicle
            focusedVehicleNearestStop = vehicle.statie ?? ""
            focusedVehicleTripId = vehicle.tripId ?? ""
        })
        .onChange(of: searchFieldFocus) {_ in
            showBusDetail = false
            showStationDetail = false
        }
        .onChange(of: stationDetails, perform: { _ in
            if busView {
                transitModel.annotations.removeAll()
                for stationDetail in stationDetails {
                    let location = CLLocationCoordinate2D(latitude: stationDetail.vehicle.latitude ?? 0, longitude: stationDetail.vehicle.longitude ?? 0)
                    transitModel.annotations.append(Annotation(type: 0, coordinates: location, vehicle: stationDetail.vehicle, statie: nil))
                }
                let location = CLLocationCoordinate2D(latitude: selectedStation.lat ?? 0, longitude: selectedStation.long ?? 0)
                transitModel.annotations.append(Annotation(type: 1, coordinates: location, vehicle: nil, statie: selectedStation))
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
                selectedVehicle = nil
                
                Task {
                    await transitModel.setup()
                    transitModel.createAnnotations()
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
            } else {
                transitModel.createAnnotations()
            }
        })
        .onChange(of: transitModel.vehicles) {_ in
            if !directionSteps.isEmpty {
                DispatchQueue.main.async { @MainActor in
                    let oldannotations = annotations
                    annotations.removeAll(where: {$0.type == 0})
                    for vehicle in transitModel.vehicles {
                        if oldannotations.contains(where: {annotation in annotation.vehicle?.tripId ?? "0" == vehicle.tripId ?? "0"}) == true {
                            let location = CLLocationCoordinate2D(latitude: vehicle.latitude ?? 0, longitude: vehicle.longitude ?? 0)
                            let annotation = Annotation(type: 0, coordinates: location, vehicle: vehicle, statie: nil)
                            annotations.append(annotation)
                        }
                    }
                }
            } else
            if busView {
                searchResults.removeAll()
                withAnimation {
                    searchResults = transitModel.vehicles.filter({$0.routeShortName?.contains(searchText) == true})
                }
                if selectedVehicle == nil {
                    DispatchQueue.main.async { @MainActor in
                        transitModel.createAnnotations()
                    }
                } else {
                    if !showStationDetail {
                        loadFocusedVehicle()
                    } else {
                        for elem in transitModel.vehicles {
                            if stationDetails.contains(where: {$0.vehicle == elem}) {
                                let location = CLLocationCoordinate2D(latitude: elem.latitude ?? 0, longitude: elem.longitude ?? 0)
                                transitModel.annotations.append(Annotation(type: 0, coordinates: location, vehicle: elem, statie: nil))
                            }
                        }
                        let location = CLLocationCoordinate2D(latitude: selectedStation.lat ?? 0, longitude: selectedStation.long ?? 0)
                        transitModel.annotations.append(Annotation(type: 1, coordinates: location, vehicle: nil, statie: selectedStation))
                    }
                }
                if !stationDetails.isEmpty {
                    transitModel.annotations.removeAll()
                    for elem in transitModel.vehicles {
                        if stationDetails.contains(where: {$0.vehicle.label == elem.label}) {
                            let location = CLLocationCoordinate2D(latitude: elem.latitude ?? 0, longitude: elem.longitude ?? 0)
                            transitModel.annotations.append(Annotation(type: 0, coordinates: location, vehicle: elem, statie: nil))
                        }
                    }
                    let location = CLLocationCoordinate2D(latitude: selectedStation.lat ?? 0, longitude: selectedStation.long ?? 0)
                    transitModel.annotations.append(Annotation(type: 1, coordinates: location, vehicle: nil, statie: selectedStation))
                }
            }
        }
        .onChange(of: showDirectionsScreen, perform: { _ in
            showBusDetail = false
            showStationDetail = false
        })
        .sheet(isPresented: $showARScreen, onDismiss: {}, content: {
            ARStationView()
                .presentationDragIndicator(.visible)
        })
        .onAppear() {
            favorites = UserDefaults.standard.object(forKey: Constants.USER_DEFAULTS_FAVORITES) as? [String] ?? [String]()
        }
        .onDisappear {
            focusedVehicleTripId = ""
            focusedVehicleNearestStop = ""
            selectedVehicle = nil
        }
        .bottomSheet(presentationDetents: userViewModel.isSubscriptionAcitve ? [.fraction(0.25), .medium, .large] : [.large], selectedDetent: $selectedDetent, isPresented: $showDirectionsScreen, dragIndicator: .visible, sheetCornerRadius: 20) {
            if userViewModel.isSubscriptionAcitve {
                MapToolbar(region: $region, selectedDetent: $selectedDetent, annotations: $annotations, steps: $directionSteps)
            } else {
                SubscriptionPaywallView()
            }
        } onDismiss: {
            selectedDetent = .medium
            directionSteps.removeAll()
            transitModel.annotations.removeAll()
            transitModel.createAnnotations()
        }
    }
    
    func loadFocusedVehicle() {
        if selectedVehicle == nil {
            showStationDetail = false
            DispatchQueue.main.async { @MainActor in
                transitModel.createAnnotations()
            }
        } else {
            DispatchQueue.main.async { @MainActor in
                transitModel.annotations = transitModel.annotations.filter({$0.vehicle?.label ?? "" == selectedVehicle?.label ?? ""})
                
                let stops = transitModel.stops
                var stopTimes = transitModel.stopTimes
                
                stopTimes = stopTimes.filter({$0.tripId == focusedVehicleTripId})
                for i in 0..<stopTimes.count {
                    let stopTime = stopTimes[i]
                    let stop = stops.first(where: {$0.stopId == Int(stopTime.stopId!)})
                    transitModel.annotations.append(Annotation(type: 1, coordinates: CLLocationCoordinate2D(latitude: stop?.lat ?? 0, longitude: stop?.long ?? 0), vehicle: nil, statie: stop))
                }
            }
        }
    }
}
