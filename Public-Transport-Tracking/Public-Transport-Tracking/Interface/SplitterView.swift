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
import SSToastMessage

struct SplitterView: View {
    @State private var vehicles = [Vehicle]()
    @State private var linii = [Linii]()
    @State private var routes = [Route]()
    @State var selectedTab = 0
    public var timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    @State var orarePicker = ""
    
    @StateObject var locationManager = LocationManager()
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var news = RSSFeed()
    @State private var comunicateSystemImage = "newspaper"
    @State private var showNewsAlert = false
    @State private var showVinereaAlert = false
    @State private var stire = ""
    
    let currentDate = Date()
    var progressInterval: ClosedRange<Date> {
        let start = currentDate
        let end = start.addingTimeInterval(7)
        return start...end
    }
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
                    Image(systemName: "map.fill")
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
            let weekday = Calendar.current.component(.weekday, from: Date())
            if weekday == 6 {
                showVinereaAlert = true
            }
            if Connectivity.isConnectedToInternet {
                DispatchQueue.main.async {
                    FavoritesScreen(vehicles: $vehicles, linii: $linii, routes: $routes, selectedTab: $selectedTab, orareSelection: $orarePicker).loadView()
                }
                Task {
                    do {
                        news = try await RequestManager().getNews()
                    } catch let err {
                        print(err)
                    }
                }
            }
        }
        .onChange(of: selectedTab) { val in
            if val == 3 {
                comunicateSystemImage = "newspaper"
                guard let firstItem : Date = news.items?.first?.pubDate else {return}
                UserDefaults.standard.set(firstItem, forKey: Constants.USER_DEFAULTS_NEWS_LAST_DATE)
            }
        }
        .onChange(of: news, perform: { _ in
            guard let firstItem : Date = news.items?.first?.pubDate else {return}
            stire = news.items?.first?.title ?? ""
            let latestDate = UserDefaults.standard.object(forKey: Constants.USER_DEFAULTS_NEWS_LAST_DATE) as? Date
            if let latestDate = latestDate {
                if firstItem > latestDate {
                    comunicateSystemImage = "newspaper.circle.fill"
                    showNewsAlert = true
                    UserDefaults.standard.set(firstItem, forKey: Constants.USER_DEFAULTS_NEWS_LAST_DATE)
                }
            } else {
                comunicateSystemImage = "newspaper.circle.fill"
                UserDefaults.standard.set(firstItem, forKey: Constants.USER_DEFAULTS_NEWS_LAST_DATE)
            }
        })
        .present(isPresented: $showNewsAlert, type: .toast, position: .top, autohideDuration: 6.5, onTap: {selectedTab = 3}) {
            VStack{
                Spacer(minLength: 20)
                HStack {
                    Image(systemName: "newspaper")
                        .padding()
                        .font(.title2)
                    VStack{
                        HStack{
                            Text("Știre nouă")
                                .bold()
                            Spacer()
                        }
                        HStack{
                            Text(stire)
                            Spacer()
                        }
                    }
                }
                
                ProgressView(timerInterval: progressInterval) {} currentValueLabel: {}
                    .tint(.purple)
            }
            .frame(width: UIScreen.main.bounds.width, height: 140)
            .background(Color(UIColor.systemGray4))
        }
        .present(isPresented: $showVinereaAlert, type: .toast, position: .top, autohideDuration: 6.5, closeOnTap: true) {
            VStack{
                Spacer(minLength: 20)
                HStack {
                    Image(systemName: "tag.slash.fill")
                        .padding()
                        .font(.title2)
                    VStack{
                        HStack{
                            Text("Vinerea verde")
                                .bold()
                            Spacer()
                        }
                        HStack{
                            Text("Azi nu este nevoie să îți validezi abonamentul sau biletul.")
                            Spacer()
                        }
                    }
                }
                
                ProgressView(timerInterval: progressInterval) {} currentValueLabel: {}
                    .tint(.purple)
            }
            .frame(width: UIScreen.main.bounds.width, height: 140)
            .background(Color(UIColor.systemGray4))
        }
        .onChange(of: scenePhase) { _ in
            if scenePhase == .background {
                Alamofire.Session.default.session.getTasksWithCompletionHandler({ dataTasks, uploadTasks, downloadTasks in
                            dataTasks.forEach { $0.cancel() }
                            uploadTasks.forEach { $0.cancel() }
                            downloadTasks.forEach { $0.cancel() }
                        })
            }
        }
    }
}

struct SplitterView_Previews: PreviewProvider {
    static var previews: some View {
        SplitterView()
    }
}
