//
//  SplitterView.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/3/23.
//

import SwiftUI
import MapKit
import Alamofire
import FeedKit

struct SplitterView: View {
    @State private var vehicles = [Vehicle]()
    @State private var linii = [Linii]()
    @State private var routes = [Route]()
    @State var selectedTab = 0
    public var timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    @State var orarePicker = "1"
    
    @StateObject var locationManager = LocationManager()
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var news = RSSFeed()
    @State private var comunicateSystemImage = "newspaper"
    
    var body: some View {
        TabView(selection: $selectedTab) {
            FavoritesScreen(vehicles: $vehicles, linii: $linii, routes: $routes, selectedTab: $selectedTab, orareSelection: $orarePicker)
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favorite")
            }
                .tag(0)
            OrarIntermediarView(selectedRoute: $orarePicker)
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
                    Image(systemName: comunicateSystemImage)
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
                Task {
                    news = try! await RequestManager().getNews()
                }
            }
        }
        .onChange(of: selectedTab) { val in
            if val == 3 {
                comunicateSystemImage = "newspaper"
            }
        }
        .onChange(of: news, perform: { _ in
            guard let firstItem : Date = news.items?.first?.pubDate else {return}
            let latestDate = UserDefaults.standard.object(forKey: Constants.USER_DEFAULTS_NEWS_LAST_DATE) as? Date? ?? Date()
            if firstItem > latestDate ?? Date() {
                comunicateSystemImage = "newspaper.circle.fill"
                UserDefaults.standard.set(firstItem, forKey: Constants.USER_DEFAULTS_NEWS_LAST_DATE)
            }
        })
        .onChange(of: scenePhase) { _ in
            if scenePhase == .background {
                Alamofire.Session.default.session.getTasksWithCompletionHandler({ dataTasks, uploadTasks, downloadTasks in
                            dataTasks.forEach { $0.cancel() }
                            uploadTasks.forEach { $0.cancel() }
                            downloadTasks.forEach { $0.cancel() }
                        })
            }
        }
        .onChange(of: vehicles) { _ in
            for i in 0..<vehicles.count {
                let vehicleLocation = CLLocation(latitude: vehicles[i].latitude ?? 0, longitude: vehicles[i].longitude ?? 0)
                let distance = (locationManager.lastLocation?.distance(from: vehicleLocation) ?? 0) / 1000

                if vehicles[i].speed != 0 {
                    vehicles[i].eta = Int(floor(distance/Double((vehicles[i].speed ?? 1))*60))
                }
                if vehicles[i].speed == 0 || vehicles[i].eta ?? 0 > 100 {
                    vehicles[i].eta = Int(floor((distance/15.0)))
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
