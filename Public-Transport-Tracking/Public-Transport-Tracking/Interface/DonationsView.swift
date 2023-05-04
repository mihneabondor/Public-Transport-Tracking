//
//  DonationsView.swift
//  Public-Transport-Tracking
//
//  Created by Mihnea on 5/3/23.
//

import SwiftUI
import RevenueCat

struct DonationsView: View {
    @State var currentOffering : Offering?
    @State var selectedOffering : Package?
    var body: some View {
        VStack {
            Spacer()
            Text("Susține Busify!")
                .font(.title)
                .bold()
                .padding()
            Text("Alege tu cât să contribui la costurile de întreținere ale serverelor pe care rulează Busify.")
                .padding()

            if currentOffering != nil {
                HStack{
                    ForEach(currentOffering!.availablePackages) {pkg in
                        Button(pkg.localizedPriceString) {
                            Purchases.shared.purchase(package: pkg) { transaction, customerInfo, err, userCancelled in
                                if customerInfo?.entitlements.all["donations"]?.isActive == true {}
                            }
                        }.buttonStyle(.bordered).padding(5)
                    }
                }
            }
            Spacer()
            Text("Abonamentele și donațiile sunt supuse [termenilor și condițiilor Busify](https://busify-cluj.web.app/termeni).")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .onAppear {
            Purchases.shared.getOfferings { offerings, err in
                if let offer = offerings?.all , err == nil {
                    if offer.keys.contains("donations") {
                        currentOffering = Array(offer.values).first!
                        print(currentOffering!.id)
//                        selectedOffering = currentOffering!.availablePackages.first!
                    }
                }
            }
        }
    }
}

struct DonationsView_Previews: PreviewProvider {
    static var previews: some View {
        DonationsView()
    }
}
