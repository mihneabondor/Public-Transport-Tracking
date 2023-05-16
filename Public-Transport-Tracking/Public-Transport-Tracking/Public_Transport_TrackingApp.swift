//
//  Public_Transport_TrackingApp.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/3/23.
//

import SwiftUI
import OneSignal
import RevenueCat

@main
struct Public_Transport_TrackingApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var userViewModel = UserViewModel()
    @StateObject var transitViewModel = TransitViewModel()
    
    @State private var loadedFirstTime = false
    var body: some Scene {
        WindowGroup {
            if !loadedFirstTime && Connectivity.isConnectedToInternet {
                LaunchView()
                    .onChange(of: transitViewModel.vehicles) { _ in
                        withAnimation {
                            loadedFirstTime = true
                        }
                    }
            } else {
                SplitterView()
                    .environmentObject(userViewModel)
                    .environmentObject(transitViewModel)
            }
        }
    }
    
    init() {
        Purchases.configure(withAPIKey: "appl_ProbKATZoesuBOEyOqQczGWXoYp")
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
       // Remove this method to stop OneSignal Debugging
//       OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
        
       OneSignal.initWithLaunchOptions(launchOptions)
       OneSignal.setAppId("85dc58eb-db58-4bb2-80b8-4330136ead93")
        
       OneSignal.promptForPushNotifications(userResponse: { accepted in
         print("User accepted notification: \(accepted)")
       })
      
      // Set your customer userId
      // OneSignal.setExternalUserId("userId")
      
       return true
    }
}
