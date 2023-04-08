//
//  SplitterView.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/3/23.
//

import SwiftUI
import MapKit

struct SplitterView: View {
    @State private var vehicles = [Vehicle]()
    @State private var linii = [Linii]()
    @State private var routes = [Route]()
    
    public var timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    var body: some View {
        TabView {
            FavoritesScreen(vehicles: $vehicles, linii: $linii, routes: $routes)
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favorite")
            }
            MapView(vehicles: $vehicles, linii: $linii)
                .tabItem {
                    Image(systemName: "mappin.circle.fill")
                    Text("Hartă")
            }
            Text("Comunicate")
                .tabItem {
                    Image(systemName: "newspaper")
                    Text("Comunicate")
                }
        }
        .background(.black)
        .tint(.purple)
        .preferredColorScheme(.dark)
        .onReceive(timer) { _ in
            FavoritesScreen(vehicles: $vehicles, linii: $linii, routes: $routes).loadView()
        }
    }
}

struct SplitterView_Previews: PreviewProvider {
    static var previews: some View {
        SplitterView()
    }
}
