//
//  UserViewModel.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 5/1/23.
//

import Foundation
import RevenueCat

class UserViewModel : ObservableObject {
    @Published var isSubscriptionAcitve = false
    
    init() {
        Purchases.shared.getCustomerInfo { customerInfo, err in
            self.isSubscriptionAcitve = customerInfo?.entitlements.all["premium"]?.isActive == true
        }
    }
}
