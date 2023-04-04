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
    private var vehicleTypes = ["Tramvai", "Metro", "Tren", "Autobus", "Ferry", "Cable tram", "Aerial Lift", "Funicular", "", "", "", "Troleibus", "Monorail"]
    private var vehicleTypesImages = ["tram.fill", "train.side.front.car", "train.side.front.car", "bus.fill", "ferry.fill", "cablecar.fill", "helicopter.fill", "bus.fill", "", "", "", "bus.doubledecker.fill", "bus.fill"]
    let timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    
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
                                    Text("Linia \(item.routeId) - \(item.vehicles.count)")
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
                                            Text("\(vehicle.address ?? "")")
                                            Text("\(vehicle.speed ?? 0)km/h")
                                                .padding([.leading])
                                            Spacer()
                                            
                                        }
                                    }
                                }
                                Divider()
                            }
                    }
                    Spacer()
                }
            }
//            .onReceive(timer) {_ in
//                loadView()
//            }
            .onAppear {
                loadView()
            }
            .navigationTitle("Favorite")
        }
    }
    
    func getAddressFromLatLon(pdblLatitude: Double, withLongitude pdblLongitude: Double) -> String {
            var addressString : String = ""
            var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
            let lat: Double = pdblLatitude
            //21.228124
            let lon: Double = pdblLongitude
            //72.833770
            let ceo: CLGeocoder = CLGeocoder()
            center.latitude = lat
            center.longitude = lon

            let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)


            ceo.reverseGeocodeLocation(loc, completionHandler:
                {(placemarks, error) in
                    if (error != nil)
                    {
                        print("reverse geodcode fail: \(error!.localizedDescription)")
                    }
                    let pm = placemarks! as [CLPlacemark]

                    if pm.count > 0 {
                        let pm = placemarks![0]
                        if pm.thoroughfare != nil {
                            addressString = addressString + pm.thoroughfare!
                        }
                        if pm.subThoroughfare != nil {
                            addressString = addressString + " " + pm.subThoroughfare!
                        }
                        print(addressString)
                  }
            })
        return addressString
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
                            linii[linii.count-1].vehicles.append(elem)
                        }
                    }
                print(elem.address)
            }
        }
    }
}

struct FavoritesScreen_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesScreen()
    }
}
