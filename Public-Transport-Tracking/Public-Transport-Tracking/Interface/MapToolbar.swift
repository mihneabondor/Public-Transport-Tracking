//
//  MapToolbar.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/28/23.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapToolbar: View {
    @Binding var region : MKCoordinateRegion
    
    @State private var startText = ""
    @State private var startCoords = CLLocation(latitude: 0, longitude: 0)
    @State private var destText = ""
    @State private var destCoords = CLLocation(latitude: 0, longitude: 0)
    
    @State private var loadingStart = false
    @State private var loadingDest = false
    @State private var searchResults = [MKMapItem]()
    @State private var doNotLoadSugestions = false
    @State private var directions = Directions(geocodedWaypoints: nil, routes: nil, status: nil)
    @State private var steps = [DecodedSteps]()
    
    @FocusState private var startFieldFocused : Bool
    @FocusState private var destFieldFocused : Bool
    
    var body: some View {
        VStack {
            HStack{
                TextField("Pornire", text: $startText)
                    .focused($startFieldFocused)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: startText) { _ in
                        searchResults.removeAll()
                        if startFieldFocused && !destFieldFocused {
                            searchSugestions(text: startText)
                        }
                        doNotLoadSugestions = false
                    }
                    .padding(5)
                Button {
                    loadingStart = true
                    let address = CLGeocoder.init()
                    address.reverseGeocodeLocation(CLLocation.init(latitude: region.center.latitude, longitude: region.center.longitude)) { (places, error) in
                        loadingStart = false
                        if error == nil{
                            if let places = places{
                                let place = places.first
                                if let name = place?.name {
                                    doNotLoadSugestions = true
                                    startText = name
                                    startCoords = place?.location ?? CLLocation(latitude: 0, longitude: 0)
                                }
                            }
                        }
                    }
                } label: {
                    if !loadingStart {
                        Image(systemName: "location")
                    } else {
                        ProgressView()
                    }
                }
                .padding(5)
                .buttonStyle(.bordered)
            }.padding()
        
            HStack{
                TextField("Destinatie", text: $destText)
                    .focused($destFieldFocused)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: destText) { _ in
                        searchResults.removeAll()
                        if !startFieldFocused && destFieldFocused {
                            searchSugestions(text: destText)
                        }
                        doNotLoadSugestions = false
                    }
                    .padding(5)
                Button {
                    doNotLoadSugestions = true
                    loadingDest = true
                    let address = CLGeocoder.init()
                    address.reverseGeocodeLocation(CLLocation.init(latitude: region.center.latitude, longitude: region.center.longitude)) { (places, error) in
                        loadingDest = false
                        if error == nil{
                            if let places = places{
                                let place = places.first
                                if let name = place?.name {
                                    destText = name
                                    destCoords = place?.location ?? CLLocation(latitude: 0, longitude: 0)
                                }
                            }
                        }
                    }
                } label: {
                    if !loadingDest {
                        Image(systemName: "location")
                    } else {
                        ProgressView()
                    }
                }
                .padding(5)
                .buttonStyle(.bordered)
            }.padding([.bottom, .leading, .trailing])
            
            if !searchResults.isEmpty{
                ScrollView{
                    ForEach(searchResults, id: \.self) { result in
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title2)
                                .foregroundColor(.purple)
                            VStack{
                                HStack{
                                    Text(result.name ?? "")
                                        .bold()
                                    Spacer()
                                }
                                if result.placemark.thoroughfare != nil || result.placemark.subThoroughfare != nil {
                                    HStack{
                                        Text("\(result.placemark.thoroughfare ?? "") \(result.placemark.subThoroughfare ?? "")")
                                        Spacer()
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        .onTapGesture {
                            if startFieldFocused {
                                startText = "\(result.placemark.thoroughfare ?? "") \(result.placemark.subThoroughfare ?? "")"
                            } else if destFieldFocused {
                                destText = "\(result.placemark.thoroughfare ?? "") \(result.placemark.subThoroughfare ?? "")"
                            }
                            searchResults.removeAll()
                            doNotLoadSugestions = true
                        }
                        Divider()
                    }
                }
            }
            
            Button("Începe") {
                startFieldFocused = false
                destFieldFocused = false
            }.buttonStyle(.bordered)
                .foregroundColor(.white)
            
            if generateDirections() {
                HStack{
                    Text("Directions")
                        .font(.title3)
                        .padding([.leading, .bottom])
                        .bold()
                    Spacer()
                }
                
                if !steps.isEmpty {
                    ScrollView {
                        ForEach(steps) {step in
                            HStack{
                                Image(systemName: step.travel == .walking ? "figure.walk" : "bus.fill")
                                    .font(.title)
                                    .foregroundColor(.purple)
                                    .padding(.leading)
                                VStack{
                                    HStack{
                                        Text(step.htmlInstructions ?? "")
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                    if step.travel == .transit {
                                        HStack{
                                            Text("Linia: ")
                                                .foregroundColor(.purple)
                                                .bold() +
                                            Text(" \(step.transitDetails?.line?.shortName ?? "-")")
                                            Spacer()
                                        }.padding(.top, 1)
                                        HStack{
                                            Text("Până la stația: ")
                                                .foregroundColor(.purple)
                                                .bold() +
                                            Text(" \(step.transitDetails?.arrivalStop?.name ?? "-")")
                                            Spacer()
                                        }
                                        HStack{
                                            Text("Număr de stații: ")
                                                .foregroundColor(.purple)
                                                .bold() +
                                            Text(" \(step.transitDetails?.numStops ?? 0)")
                                            Spacer()
                                        }
                                    }
                                    
                                    HStack{
                                        Spacer()
                                        Text("\(step.distance?.text ?? "") \(step.duration?.text ?? "")")
                                            .padding([.trailing, .top])
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                    }
                                }.padding(.leading)
                            }
                            Divider()
                        }
                    }
                }
            }
            
            Spacer()
        }
        .onChange(of: generateDirections()) { val in
            if val {
                searchResults.removeAll()
                directions = Directions(geocodedWaypoints: nil, routes: nil, status: nil)
                steps.removeAll()
                
                var origin = "", destination = ""
                    
                let geoCoder = CLGeocoder()
                geoCoder.geocodeAddressString(startText) { (placemarks, error) in
                    guard
                        let placemarks = placemarks,
                        let location = placemarks.first?.location
                    else {return}
                    origin = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
                    
                    geoCoder.geocodeAddressString(destText) { (placemarks, error) in
                        guard
                            let placemarks = placemarks,
                            let location = placemarks.first?.location
                        else {return}
                        destination = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
                        print(origin)
                        print(destination)
                        Task {
                            directions = try await RequestManager().getDirections(origin: origin, destination: destination)
                            print(directions)
                            traverseSteps(step: directions.routes?.first?.legs?.first?.steps)
                            print(steps)
                        }
                    }
                }
            }
        }
    }
    
    private func searchSugestions(text: String) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = text
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }
            searchResults = response.mapItems
        }
    }
    
    private func generateDirections() -> Bool {
        return startText != "" && destText != "" && !startFieldFocused && !destFieldFocused
    }
    
    private func traverseSteps(step : [CustomStep]?) {
        guard let step = step else {return}
        print("spofjdsofdsjifo")
        print(step)
        for step in step {
            steps.append(DecodedSteps(distance: step.distance ?? CustomDistance(text: "", value: 0), duration: step.duration ?? CustomDistance(text: "", value: 0), endLocation: step.endLocation, htmlInstructions: step.htmlInstructions?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil) ?? "", polyline: step.polyline ?? CustomPolyline(points: ""), startLocation: step.startLocation, travel: step.travel ?? CustomTravelMode(rawValue: ""), transitDetails: step.transitDetails ?? CustomTransitDetails(arrivalStop: CustomStop(location: CustomLocation(lat: 0, lng: 0), name: ""), arrivalTime: CustomTime(text: "", timeZone: "", value: 0), departureStop: CustomStop(location: CustomLocation(lat: 0, lng: 0), name: ""), departureTime: CustomTime(text: "", timeZone: "", value: 0), headsign: "", line: CustomLine(agencies: [], name: "", shortName: "", vehicle: CustomVehicle(icon: "", name: "", type: "")), numStops: 0), maneuver: step.maneuver ?? ""))
        }
        var index = 0
        while step[0].steps == nil && index < step.count-1 {
            index += 1
        }
        traverseSteps(step: step[index].steps)
    }
}
