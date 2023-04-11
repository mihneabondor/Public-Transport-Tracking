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
    @State var selectedTab = 0
    public var timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    
    @State var orarePicker = "1"
    var body: some View {
        TabView(selection: $selectedTab) {
            FavoritesScreen(vehicles: $vehicles, linii: $linii, routes: $routes, selectedTab: $selectedTab, orareSelection: $orarePicker)
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favorite")
            }
                .tag(0)
            OrareView(pickerSelection: $orarePicker)
                .tabItem{
                    Image(systemName: "calendar")
                    Text("Orare")
                }
                .tag(1)
            MapView(vehicles: $vehicles, linii: $linii, routes: $routes, selectedTab: $selectedTab, orareSelection: $orarePicker)
                .tabItem {
                    Image(systemName: "mappin.circle.fill")
                    Text("Hartă")
            }
                .tag(2)
            ComunicateView()
                .tabItem {
                    Image(systemName: "newspaper")
                    Text("Comunicate")
                }
                .tag(3)
        }
        .background(.black)
        .tint(.purple)
        .preferredColorScheme(.dark)
        .onReceive(timer) { _ in
            if Connectivity.isConnectedToInternet {
                DispatchQueue.main.async {
                    FavoritesScreen(vehicles: $vehicles, linii: $linii, routes: $routes, selectedTab: $selectedTab, orareSelection: $orarePicker).loadView()
                }
            }
        }
        .onChange(of: Connectivity.isConnectedToInternet, perform: { _ in
            if Connectivity.isConnectedToInternet {
                DispatchQueue.main.async {
                    FavoritesScreen(vehicles: $vehicles, linii: $linii, routes: $routes, selectedTab: $selectedTab, orareSelection: $orarePicker).loadView()
                }
            }
        })
        .onAppear() {
            if Connectivity.isConnectedToInternet {
                DispatchQueue.main.async {
                    FavoritesScreen(vehicles: $vehicles, linii: $linii, routes: $routes, selectedTab: $selectedTab, orareSelection: $orarePicker).loadView()
                }
            }
        }
    }
}

struct SplitterView_Previews: PreviewProvider {
    static var previews: some View {
        SplitterView()
    }
}
