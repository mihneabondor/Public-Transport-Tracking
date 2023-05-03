//
//  DonationsView.swift
//  Public-Transport-Tracking
//
//  Created by Mihnea on 5/3/23.
//

import SwiftUI

struct DonationsView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Susține Busify!")
                .font(.title)
                .bold()
                .padding()
            Text("Alege tu cât să contribui la costurile de întreținere ale serverelor pe care rulează Busify.")
                .padding()
            Button("Donează") {
                if let url = URL(string: "https://buymeacoffee.com/mihneabondor") {
                    UIApplication.shared.open(url)
                }
            }.buttonStyle(.borderedProminent)
            Spacer()
            Text("Abonamentele și donațiile sunt supuse [termenilor și condițiilor Busify](https://busify-cluj.web.app/termeni).")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}

struct DonationsView_Previews: PreviewProvider {
    static var previews: some View {
        DonationsView()
    }
}
