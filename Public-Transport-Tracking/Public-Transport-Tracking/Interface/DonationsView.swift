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
    @State private var isLoading = false
    var body: some View {
        VStack {
            Spacer()
            Text("Susține Busify!")
                .font(.title3)
                .bold()
                .padding()
            Text("Alege tu cât să contribui la costurile de întreținere ale serverelor pe care rulează Busify.")
                .padding()

            if currentOffering != nil {
                HStack{
                    ForEach(currentOffering!.availablePackages) {pkg in
                        Button(pkg.localizedPriceString) {
                            isLoading = true
                            Purchases.shared.purchase(package: pkg) { transaction, customerInfo, err, userCancelled in
                                if customerInfo?.entitlements.all["donations"]?.isActive == true {
                                    isLoading = false
                                }
                                if userCancelled {
                                    isLoading = false
                                }
                            }
                        }.buttonStyle(.bordered).padding(5)
                    }
                }
            }
            if isLoading {
                ProgressView()
            }
            Spacer()
            Text("Abonamentele și donațiile sunt supuse [termenilor, condițiilor și politicii de confidențialitate Busify](https://busify-cluj.web.app/termeni).")
                .padding()
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .onAppear {
            Purchases.shared.getOfferings { offerings, err in
                if let offer = offerings?.all , err == nil {
                    for elem in offer {
                        if elem.key.contains("donations") {
                            currentOffering = elem.value
                            print(elem)
                        }
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
