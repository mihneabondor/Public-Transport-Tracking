//
//  SubscriptionPaywallView.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 5/1/23.
//

import SwiftUI
import RevenueCat

struct SubscriptionPaywallView: View {
    @State var currentOffering : Offering?
    var body: some View {
        VStack {
            Text("Premium")
                .font(.title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            Spacer()
            
            HStack{
                Image(systemName: "signpost.right.and.left")
                    .font(.title)
                    .padding()
                    .foregroundColor(.purple)
                VStack{
                    Text("Deblochează sistemul de direcții")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Găsește cu ușurință cea mai rapidă rută spre destinația aleasă.")
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                }
            }.padding()
            
            HStack{
                Image(systemName: "heart.fill")
                    .font(.title)
                    .foregroundColor(.purple)
                    .padding()
                VStack{
                    Text("Susține proiectul Busify")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Alege să contribui la continuarea dezvoltării aplicației! <3")
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }.padding()
            
            Spacer()
            
            if currentOffering != nil {
                ForEach(currentOffering!.availablePackages) {pkg in
                    Button("\(pkg.storeProduct.subscriptionPeriod!.periodTitle) \(pkg.storeProduct.localizedPriceString)") {
                        Purchases.shared.purchase(package: pkg) { transaction, customerInfo, err, userCancelled in
                            if customerInfo?.entitlements.all["premium"]?.isActive == true {
                                
                            }
                        }
                    }.buttonStyle(.borderedProminent)
                }
            }
            
            Spacer()
        }
        .onAppear {
            Purchases.shared.getOfferings { offerings, err in
                if let offer = offerings?.current, err == nil {
                    currentOffering = offer
                    print(offer)
                }
            }
        }
    }
}

struct SubscriptionPaywallView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionPaywallView()
    }
}
