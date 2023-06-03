//
//  BusifyClipApp.swift
//  BusifyClip
//
//  Created by Mihnea on 4/14/23.
//

import SwiftUI

@main
struct BusifyClipApp: App {
    @StateObject var transitViewModel = TransitViewModel()
    @StateObject var locationManager = LocationManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(transitViewModel)
                .environmentObject(locationManager)
        }
    }
}
