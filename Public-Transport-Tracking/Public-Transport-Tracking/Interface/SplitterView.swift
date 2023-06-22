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
import AlertToast

struct SplitterView: View {
    @State private var vehicles = [Vehicle]()
    @State private var linii = [Linii]()
    @State private var trips = [Trip]()
    @State private var routes = [Route]()
    @State private var stops = [Statie]()
    @State private var stopTimes = [StopTime]()
    @State var selectedTab = 0
    @State var orarePicker = ""
    
    @StateObject var locationManager = LocationManager()
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var news = RSSFeed()
    @State private var comunicateSystemImage = "newspaper"
    @State private var showNewsAlert = false
    @State private var showVinereaAlert = false
    @State private var stire = ""
    
    @State private var url = URL(string: "google.com")!
    
    @State private var showWhatsNewScreen = false
    
    let currentDate = Date()
    var body: some View {
        TabView(selection: $selectedTab) {
            FavoritesScreen(selectedTab: $selectedTab, orareSelection: $orarePicker)
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
                .onTapGesture {
                    orarePicker = ""
                }
            MapView(selectedTab: $selectedTab, orareSelection: $orarePicker, url: $url)
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
        .onOpenURL(perform: { externalURL in
            url = externalURL
            selectedTab = 2
        })
        .sheet(isPresented: $showWhatsNewScreen, onDismiss: {
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                let UDString = "com.Mihnea.busify.\(version).whatsnew"
                UserDefaults.standard.set(true, forKey: UDString)
            }
        }, content: {
            WhatsNewScreen()
        })
        .onAppear {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                let UDString = "com.Mihnea.busify.\(version).whatsnew"
                if UserDefaults.standard.bool(forKey: UDString) == false {
                    showWhatsNewScreen = true
                }
            }
        }
        .tint(.purple)
        .preferredColorScheme(.dark)
        .onAppear() {
            let weekday = Calendar.current.component(.weekday, from: Date())
            if weekday == 6 {
                showVinereaAlert = true
            }
            if Connectivity.isConnectedToInternet {
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
        .toast(isPresenting: $showNewsAlert, duration: 5.0, tapToDismiss: true, alert: {
            AlertToast(displayMode: .hud, type: .regular, title: "Știre nouă", subTitle: "Apasă pentru mai multe detalii")
        }, onTap: {
            selectedTab = 3
        })
        .toast(isPresenting: $showVinereaAlert, duration: 3.0, tapToDismiss: true, alert: {
            AlertToast(displayMode: .hud, type: .systemImage("tag.slash", .white), title: "Vinerea Verde")
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
    }
}

struct SplitterView_Previews: PreviewProvider {
    static var previews: some View {
        SplitterView()
    }
}
