//
//  SettingsView.swift
//  Public-Transport-Tracking
//
//  Created by Mihnea on 5/31/23.
//

import SwiftUI
import OneSignal

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Label("Contactează-mă", systemImage: "paperplane")
                }.onTapGesture {
                    UIApplication.shared.open(URL(string: "mailto:mihnea.bondor@icloud.com")!)
                }
                
                Section {
                    DonationsView()
                }
            }
            .navigationTitle("Setări")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
