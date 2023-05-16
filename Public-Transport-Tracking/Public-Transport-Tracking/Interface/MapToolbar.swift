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
    @Binding var selectedDetent : PresentationDetent
    @Binding var annotations : [Annotation]
    @Binding var steps : [DecodedSteps]
    
    @State private var startText = ""
    @State private var startCoords = CLLocation(latitude: 0, longitude: 0)
    @State private var destText = ""
    @State private var destCoords = CLLocation(latitude: 0, longitude: 0)
    
    @State private var loadingStart = false
    @State private var loadingDest = false
    @State private var searchResults = [MKMapItem]()
    @State private var doNotLoadSugestions = false
    @State private var directions = Directions(geocodedWaypoints: nil, routes: nil, status: nil)
    
    @FocusState private var startFieldFocused : Bool
    @FocusState private var destFieldFocused : Bool
    
    @EnvironmentObject var transitModel : TransitViewModel
    var body: some View {
        VStack {
            Text(" ")
            if selectedDetent != .fraction(0.25) {
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
                }.padding().transition(.slide)
                
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
                }.padding([.bottom, .leading, .trailing]).transition(.slide)
            }
            
            if selectedDetent == .fraction(0.25) && steps.isEmpty {
                Text("Caută cum să ajungi dintr-o locație în alta în cel mai scurt timp.")
                    .padding()
                    .multilineTextAlignment(.center)
            }
            
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
                                startText = startText.trimmingCharacters(in: .whitespacesAndNewlines)
                                if startText == "" {
                                    startText = result.placemark.postalCode ?? ""
                                }
                                startText = startText.trimmingCharacters(in: .whitespacesAndNewlines)
                                if startText == "" {
                                    startText = result.placemark.name ?? "" + "Cluj"
                                }
                                startText = startText.trimmingCharacters(in: .whitespacesAndNewlines)
                            } else if destFieldFocused {
                                destText = "\(result.placemark.thoroughfare ?? "") \(result.placemark.subThoroughfare ?? "")"
                                destText = destText.trimmingCharacters(in: .whitespacesAndNewlines)
                                if destText == "" {
                                    destText = result.placemark.postalCode ?? ""
                                }
                                destText = destText.trimmingCharacters(in: .whitespacesAndNewlines)
                                if startText == "" {
                                    startText = result.placemark.name ?? "" + "Cluj"
                                }
                                destText = destText.trimmingCharacters(in: .whitespacesAndNewlines)
                            }
                            searchResults.removeAll()
                            doNotLoadSugestions = true
                        }
                        Divider()
                    }
                }
            }
            
            if selectedDetent != .fraction(0.25) {
                Button("Începe") {
                    startFieldFocused = false
                    destFieldFocused = false
                }.buttonStyle(.bordered)
                    .foregroundColor(.white)
            }
            
            if generateDirections() {
                if selectedDetent != .fraction(0.25) {
                    HStack{
                        Text("Direcții")
                            .font(.title3)
                            .padding([.leading, .bottom])
                            .bold()
                        Spacer()
                    }
                }
                
                if !steps.isEmpty && selectedDetent != .fraction(0.25) {
                    ScrollView {
                        ForEach(steps) {step in
                            StepCell(step: step)
                            Divider()
                        }
                    }
                }
                
                if !steps.isEmpty && selectedDetent == .fraction(0.25) {
                    TabView {
                        ForEach(steps) { step in
                            StepCell(step: step)
                        }
                    }.tabViewStyle(.page)
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
                            let customSteps = directions.routes?.first?.legs?.first?.steps
                            for customStep in customSteps ?? [] {
                                let decodedStep = DecodedSteps(distance: CustomDistance(text: customStep.distance?.text ?? "", value: customStep.distance?.value ?? 0), duration: CustomDistance(text: customStep.duration?.text ?? "", value: customStep.duration?.value ?? 0), endLocation: CustomLocation(lat: customStep.endLocation?.lat ?? 0, lng: customStep.endLocation?.lng ?? 0), htmlInstructions: customStep.htmlInstructions ?? "", polyline: CustomPolyline(points: customStep.polyline?.points ?? ""), startLocation: customStep.startLocation ?? CustomLocation(lat: 0, lng: 0), travel: customStep.travel ?? CustomTravelMode.walking, transitDetails: customStep.transitDetails ?? CustomTransitDetails(arrivalStop: CustomStop(location: CustomLocation(lat: 0, lng: 0), name: ""), arrivalTime: CustomTime(text: "", timeZone: "", value: 0), departureStop: CustomStop(location: CustomLocation(lat: 0, lng: 0), name: ""), departureTime: CustomTime(text: "", timeZone: "", value: 0), headsign: "", line: CustomLine(agencies: [], name: "", shortName: "", vehicle: CustomVehicle(icon: "", name: "", type: "")), numStops: 0), maneuver: customStep.maneuver ?? "")
                                steps.append(decodedStep)
                            }
                            withAnimation{
                                selectedDetent = .fraction(0.25)
                            }
                            setAnnotations(steps: steps)
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
        print(step)
        
        var index = 0
        while step[0].steps == nil && index < step.count-1 {
            index += 1
        }
        
        for step in step {
            let newStep = DecodedSteps(distance: step.distance ?? CustomDistance(text: "", value: 0), duration: step.duration ?? CustomDistance(text: "", value: 0), endLocation: step.endLocation, htmlInstructions: step.htmlInstructions?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil) ?? "", polyline: step.polyline ?? CustomPolyline(points: ""), startLocation: step.startLocation, travel: step.travel ?? CustomTravelMode(rawValue: ""), transitDetails: step.transitDetails ?? CustomTransitDetails(arrivalStop: CustomStop(location: CustomLocation(lat: 0, lng: 0), name: ""), arrivalTime: CustomTime(text: "", timeZone: "", value: 0), departureStop: CustomStop(location: CustomLocation(lat: 0, lng: 0), name: ""), departureTime: CustomTime(text: "", timeZone: "", value: 0), headsign: "", line: CustomLine(agencies: [], name: "", shortName: "", vehicle: CustomVehicle(icon: "", name: "", type: "")), numStops: 0), maneuver: step.maneuver ?? "")
            if index-1 > steps.count || index-1 < 0 {
                steps.append(newStep)
            } else {
                steps.insert(newStep, at: index-1)
            }
        }

        traverseSteps(step: step[index].steps)
    }
    
    private func setAnnotations(steps : [DecodedSteps]) {
        annotations.removeAll()
        let filteredVehicles = transitModel.vehicles.filter({vehicle in steps.contains(where: {step in step.transitDetails?.line?.shortName?.contains(vehicle.routeShortName ?? "") == true})})
        let filteredStops = transitModel.stops.filter({stop in steps.contains(where: {step in step.htmlInstructions?.contains(stop.stopName ?? "") == true || step.transitDetails?.arrivalStop?.name?.contains(stop.stopName ?? "") == true})})
        
        for filteredVehicle in filteredVehicles {
            let location = CLLocationCoordinate2D(latitude: filteredVehicle.latitude ?? 0, longitude: filteredVehicle.longitude ?? 0)
            let annotation = Annotation(type: 0, coordinates: location, vehicle: filteredVehicle, statie: nil)
            annotations.append(annotation)
        }
        
        for filteredStop in filteredStops {
            let location = CLLocationCoordinate2D(latitude: filteredStop.lat ?? 0, longitude: filteredStop.long ?? 0)
            let annotation = Annotation(type: 1, coordinates: location, vehicle: nil, statie: filteredStop)
            annotations.append(annotation)
        }
        
        let leg = directions.routes?.first?.legs?.first
        let startLocation = CLLocationCoordinate2D(latitude: leg?.startLocation?.lat ?? 0, longitude: leg?.startLocation?.lng ?? 0)
        let endLocation = CLLocationCoordinate2D(latitude: leg?.endLocation?.lat ?? 0, longitude: leg?.endLocation?.lng ?? 0)
        print(startLocation)
        print(endLocation)
        let midCenter = CLLocationCoordinate2D(latitude: (startLocation.latitude+endLocation.latitude)/2, longitude: (startLocation.longitude+endLocation.longitude)/2)
        print(midCenter)
        let midSpan = MKCoordinateSpan(latitudeDelta: abs((startLocation.latitude-endLocation.latitude))*2, longitudeDelta: abs((startLocation.longitude-endLocation.longitude))*2)
        withAnimation{
            region = MKCoordinateRegion(center: midCenter, span: midSpan)
        }
        
        annotations.append(Annotation(type: 2, coordinates: startLocation))
        annotations.append(Annotation(type: 3, coordinates: endLocation))
    }
}

struct StepCell : View {
    @State var step : DecodedSteps
    var body: some View {
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
    }
}
