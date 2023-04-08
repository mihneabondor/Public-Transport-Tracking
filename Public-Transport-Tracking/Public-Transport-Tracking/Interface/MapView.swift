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
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 46.7712, longitude: 23.6236), span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4))
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
    
    var timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack{
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: annotations, annotationContent: { location in
                MapAnnotation(coordinate: location.coordinates) {
                    if location.type == 0 {
                        Button {
                            if focusedVehicleTripId == ""{
                                focusedVehicleNearestStop = location.statie
                                focusedVehicleTripId = location.tripId
                            } else {
                                focusedVehicleTripId = ""
                                focusedVehicleNearestStop = ""
                            }
                        } label: {
                            VStack {
                                Image(systemName: "\(vehicleTypesImages[location.vehicleType])")
                                    .foregroundColor(.white)
                                    .font(.footnote)
                                Text(location.shortName)
                                    .bold()
                                    .font(.footnote)
                                    .foregroundColor(.white)
                            }
                            .background (
                                Rectangle()
                                    .frame(width: 35, height: 40)
                                    .foregroundColor(.purple)
                                    .cornerRadius(5)
                            )
                        }
                    } else {
                        Button {
                            statieStationDetail = location.shortName
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
            })
            
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
                if !searchResults.isEmpty{
                    ScrollView {
                        ForEach(searchResults) { result in
                            Text(" ")
                                .font(.footnote)
                            Button {
                                region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: result.latitude ?? 0, longitude: result.longitude ?? 0), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
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
                StationView(statie: $statieStationDetail, systemImage: $systemImgStationDetail, closeView: $showStationDetail)
                    .offset(y: showStationDetail ? 0 : 500)
                    .padding()
            }
        }
        .onChange(of: showStationDetail, perform: { _ in
            if showStationDetail == false {
                annotations.removeAll()
                for elem in vehicles {
                    annotations.append(Annotation(coordinates: CLLocationCoordinate2D(latitude: elem.latitude ?? 0, longitude: elem.longitude ?? 0), type: 0, shortName: elem.routeShortName ?? "", vehicleType: elem.vehicleType ?? 0, longName: elem.routeLongName ?? "", tripId: elem.tripId ?? "", statie: elem.statie ?? ""))
                }
            }
        })
        .onChange(of: focusedVehicleTripId, perform: { tripId in
            Task(priority: .high) {
                if focusedVehicleTripId == "" {
                    showStationDetail = false
                    annotations.removeAll()
                    for elem in vehicles {
                        annotations.append(Annotation(coordinates: CLLocationCoordinate2D(latitude: elem.latitude ?? 0, longitude: elem.longitude ?? 0), type: 0, shortName: elem.routeShortName ?? "", vehicleType: elem.vehicleType ?? 0, longName: elem.routeLongName ?? "", tripId: elem.tripId ?? "", statie: elem.statie ?? ""))
                    }
                } else {
                    annotations = annotations.filter({$0.tripId == focusedVehicleTripId && focusedVehicleNearestStop == $0.statie})
                    let stops = try! await RequestManager().getStops()
                    var stopTimes = try! await RequestManager().getStopTimes()
                    stopTimes = stopTimes.filter({$0.tripId == tripId})
                    
                    for i in 0..<stopTimes.count {
                        let stopTime = stopTimes[i]
                        let stop = stops.first(where: {$0.stopId == Int(stopTime.stopId!)})
                        annotations.append(Annotation(coordinates: CLLocationCoordinate2D(latitude: stop?.lat ?? 0 , longitude: stop?.long ?? 0), type: 1, shortName: stop?.stopName ?? "", vehicleType: 0, longName: stop?.stopDesc ?? "", tripId: "", statie: stop?.stopName ?? ""))
                    }
                }
            }
        })
        .onChange(of: vehicles) {_ in
            DispatchQueue.main.async {
                if focusedVehicleTripId == "" {
                    annotations.removeAll()
                    for elem in vehicles {
                        annotations.append(Annotation(coordinates: CLLocationCoordinate2D(latitude: elem.latitude ?? 0, longitude: elem.longitude ?? 0), type: 0, shortName: elem.routeShortName ?? "", vehicleType: elem.vehicleType ?? 0, longName: elem.routeLongName ?? "", tripId: elem.tripId ?? "", statie: elem.statie ?? ""))
                    }
                } else {
                    let elem = vehicles.first(where: {$0.tripId == focusedVehicleTripId})
                    annotations.removeAll(where: {$0.type == 0})
                    annotations.append(Annotation(coordinates: CLLocationCoordinate2D(latitude: elem?.latitude ?? 0, longitude: elem?.longitude ?? 0), type: 0, shortName: elem?.routeShortName ?? "", vehicleType: elem?.vehicleType ?? 0, longName: elem?.routeLongName ?? "", tripId: elem?.tripId ?? "", statie: elem?.statie ?? ""))
                }
            }
        }
        .onAppear() {
            DispatchQueue.main.async {
                for elem in vehicles {
                    annotations.append(Annotation(coordinates: CLLocationCoordinate2D(latitude: elem.latitude ?? 0, longitude: elem.longitude ?? 0), type: 0, shortName: elem.routeShortName ?? "", vehicleType: elem.vehicleType ?? 0, longName: elem.routeLongName ?? "", tripId: elem.tripId ?? "", statie: elem.statie ?? ""))
                }
            }
        }
    }
}