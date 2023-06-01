//
//  Extensions.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/28/23.
//

import Foundation
import SwiftUI
import RevenueCat

extension View {
    @ViewBuilder
    func bottomSheet<Content: View> (
        presentationDetents: Set<PresentationDetent>, selectedDetent : Binding<PresentationDetent>, isPresented: Binding<Bool>,
        dragIndicator: Visibility = .visible,
        sheetCornerRadius: CGFloat?,
        largestUndimmedIdentifier: UISheetPresentationController.Detent.Identifier = .medium,
        isTransparentBG: Bool = false,
        interactiveDisabled: Bool = false,
        @ViewBuilder content: @escaping () ->Content, onDismiss: @escaping ()-> ()
    ) -> some View { self
        .sheet (isPresented: isPresented) {
            onDismiss ()
        } content: {
            if #available(iOS 16.4, *){
                content()
                    .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.25)))
                    .presentationDetents (presentationDetents, selection: selectedDetent)
                    .presentationDragIndicator(dragIndicator)
                    .onAppear {
                        guard let windows = UIApplication.shared.connectedScenes.first as? UIWindowScene else{return}
                        if let controller = windows.windows.first?.rootViewController?.presentedViewController, let sheet = controller.presentationController as? UISheetPresentationController{
                            controller.presentingViewController?.view.tintAdjustmentMode = .normal
                            sheet.largestUndimmedDetentIdentifier = .medium
                            sheet.preferredCornerRadius = sheetCornerRadius
                        }
                    }
            } else {
                content()
                    .presentationDetents (presentationDetents, selection: selectedDetent)
                    .presentationDragIndicator(dragIndicator)
                    .onAppear {
                        guard let windows = UIApplication.shared.connectedScenes.first as? UIWindowScene else{return}
                        if let controller = windows.windows.first?.rootViewController?.presentedViewController, let sheet = controller.presentationController as? UISheetPresentationController{
                            controller.presentingViewController?.view.tintAdjustmentMode = .normal
                            sheet.largestUndimmedDetentIdentifier = .medium
                            sheet.preferredCornerRadius = sheetCornerRadius
                        }
                    }
            }
        }
    }
}

extension SubscriptionPeriod {
    var durationTitle: String {
        switch self.unit {
        case .day: return "day"
        case .week: return "week"
        case .month: return "month"
        case .year: return "year"
        @unknown default: return "Unknown"
        }
    }
    
    var periodTitle: String {
        let periodString = "\(self.value) \(self.durationTitle)"
        let pluralized = self.value > 1 ? periodString + "s" : periodString
        return pluralized
    }
}

extension URL {
    subscript(queryParam:String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParam })?.value
    }
}
