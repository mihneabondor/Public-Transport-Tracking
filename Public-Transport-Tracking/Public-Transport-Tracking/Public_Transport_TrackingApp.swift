//
//  Public_Transport_TrackingApp.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/3/23.
//

import SwiftUI

@main
struct Public_Transport_TrackingApp: App {
    var body: some Scene {
        WindowGroup {
            if(!UserDefaults.standard.bool(forKey: Constants.USER_DEFAULTS_SPLASHSCREEN)) {
                SplashScreen()
            } else {
                SplitterView()
            }
        }
    }
}
