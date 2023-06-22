//
//  StationView.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/7/23.
//

import SwiftUI
import CoreLocation

struct StationView: View {
    @Binding var statie : String
    @Binding var systemImage : String
    @Binding var closeView : Bool
    @Binding var stop : Statie
    
    @State private var filteredVehicles = [Vehicle]()
    @Binding var details : [StationDetails]
    
    @StateObject private var motion = MotionManager()
    
    @EnvironmentObject var transitModel : TransitViewModel
    var body: some View {
        VStack{
            HStack{
                VStack{
                    Image(systemName: systemImage)
                        .padding()
                        .font(.title2)
                    Text(" ")
                        .font(.title3)
                        .padding([.leading, .trailing, .top])
                }
                Text(statie)
                    .bold()
                    .padding([.trailing, .top])
                Spacer()
                
                Button {
                    withAnimation {
                        closeView.toggle()
                    }
                    details.removeAll()
                    transitModel.createAnnotations()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
                .font(.title)
                .padding([.leading, .trailing, .top])
                Text(" ")
                    .font(.title)
            }
            ScrollView{
                ForEach(Array(details.enumerated()), id: \.element) { index, detail in
                    HStack{
                        Image(systemName: Constants.vehicleTypesImages[detail.vehicle.vehicleType ?? 0])
                            .padding([.leading, .trailing])
                        Text(detail.vehicle.routeShortName ?? "-")
                        Spacer()
                        Text("\(detail.stationETA) min")
                            .padding([.leading, .trailing])
                    }
                    Divider()
                }
            }
            Text(" ")
        }.frame(height: UIScreen.main.bounds.height/3)
        .background() {
            Rectangle()
                .frame(width: UIScreen.main.bounds.width/1.1, height: UIScreen.main.bounds.height/4)
                .cornerRadius(20)
                .foregroundColor(Color(UIColor.systemGray4))
                .shadow(color: .black, radius: 3, x: -motion.x * 10, y: -motion.y * 10)
                .padding()
        }
        .preferredColorScheme(.dark)
        .onChange(of: transitModel.vehicles, perform: { _ in
            loadDetails()})
        .onAppear {loadDetails()}
    }
    
    func loadDetails() {
        details.removeAll()
        Task {
            var stopTimes = [StopTime](), unfilteredStopTimes = [StopTime]()
            do {
                stopTimes = try await RequestManager().getStopTimes()
            } catch let err {
                print(err)
            }
            unfilteredStopTimes = stopTimes
            stopTimes = stopTimes.filter({$0.stopId ?? "" == String(stop.stopId ?? 0)})
            
            var routes = [Route]()
            do {
                routes = try await RequestManager().getRoutes()
            } catch let err {
                print(err)
            }
            let filteredRoutes = routes.filter({route in stopTimes.contains(where: {stopTime in Int((stopTime.tripId?.components(separatedBy: "_").first!)!)! == route.routeId})})
            filteredVehicles = transitModel.vehicles.filter({vehicle in filteredRoutes.contains(where: {route in route.routeShortName == vehicle.routeShortName})})
            
            var stops = [Statie]()
            do {
                stops = try await RequestManager().getStops()
            } catch let err {
                print(err)
            }
            
            for filteredVehicle in filteredVehicles {
//                if filteredVehicle.speed != 0 {
                    let currentStopId = stops.first(where: {$0.stopName ?? "" ==  filteredVehicle.statie})?.stopId
                    let currentStopSq = unfilteredStopTimes.first(where: {Int($0.stopId ?? "0")! == currentStopId && $0.tripId == filteredVehicle.tripId})?.sq
                    let stationStopSq = stopTimes.first(where: {$0.tripId == filteredVehicle.tripId})?.sq
                    
                    if currentStopSq ?? 0 <= stationStopSq ?? 0 {
                        let statieCoords = CLLocation(latitude: stop.lat ?? 0, longitude: stop.long ?? 0)
                        let vehicleCoords = CLLocation(latitude: filteredVehicle.latitude ?? 0, longitude: filteredVehicle.longitude ?? 0)
                        let distance = statieCoords.distance(from: vehicleCoords)/1000
                        
                        var eta = 0
                        if filteredVehicle.speed != 0 {
                            eta = Int(Int(distance)/(filteredVehicle.speed ?? 15)*60)
                        }
                        if eta > 100 || eta == 0 {
                            eta = Int(distance/15*60)
                        }
                        
                        if eta < 30 {
                            details.append(StationDetails(vehicle: filteredVehicle, stationETA: eta))
                        }
                    }
//                }
            }
            details = details.sorted(by: {$0.stationETA < $1.stationETA})
            print(details)
        }
    }
}
