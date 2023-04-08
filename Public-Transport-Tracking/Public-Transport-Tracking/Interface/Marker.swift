//
//  MapMarker.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/6/23.
//

import SwiftUI

struct Marker: View {
    @State var vehicle : Vehicle
    var vehicleTypes = ["Tramvai", "Metro", "Tren","Autobus", "Ferry", "Cable tram", "Aerial Lift", "Funicular", "", "", "", "Troleibus", "Monorail"]
    var vehicleTypesImages = ["tram.fill", "train.side.front.car", "train.side.front.car", "bus.fill", "ferry.fill", "cablecar.fill", "helicopter.fill", "bus.fill", "", "", "", "bus.doubledecker.fill", "bus.fill"]
    var body: some View {
        VStack {
            HStack{
                Image(systemName: "\(vehicleTypesImages[vehicle.vehicleType ?? 0])")
                    .foregroundColor(.white)
                Image(systemName: vehicle.tripId?.last == "1" ? "arrow.down" : "arrow.up")
            }
            Text("\(vehicle.routeShortName ?? "")")
                .bold()
                .foregroundColor(.white)
        }
        .background (
            Rectangle()
                .frame(width: 55, height: 50)
                .foregroundColor(.purple)
                .cornerRadius(5)
        )
    }
}

struct MapMarker_Previews: PreviewProvider {
    static var previews: some View {
        Marker(vehicle: Vehicle(xProvider: 0, xRand: 0, id: 0, label: "0", latitude: 0, longitude: 0, timestamp: "0", speed: 0, routeId: 33, tripId: "0", vehicleType: 3, bikeAccessible: "0", wheelchairAccessible: "0"))
    }
}
