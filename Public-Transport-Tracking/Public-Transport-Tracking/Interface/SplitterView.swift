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
    @State private var selectedTab = 1
    public var timer = Timer.publish(every: 20, on: .main, in: .common).autoconnect()
    var body: some View {
        TabView(selection: $selectedTab) {
            FavoritesScreen(vehicles: $vehicles, linii: $linii, routes: $routes)
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favorite")
            }
                .tag(0)
            MapView(vehicles: $vehicles, linii: $linii)
                .tabItem {
                    Image(systemName: "mappin.circle.fill")
                    Text("Hartă")
            }
                .tag(1)
            Text("Comunicate")
                .tabItem {
                    Image(systemName: "newspaper")
                    Text("Comunicate")
                }
                .tag(2)
        }
        .background(.black)
        .tint(.purple)
        .preferredColorScheme(.dark)
        .onReceive(timer) { _ in
            FavoritesScreen(vehicles: $vehicles, linii: $linii, routes: $routes).loadView()
        }
        .onAppear() {
            FavoritesScreen(vehicles: $vehicles, linii: $linii, routes: $routes).loadView()
        }
    }
}

struct SplitterView_Previews: PreviewProvider {
    static var previews: some View {
        SplitterView()
    }
}
