//
//  Extensions.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/28/23.
//

import Foundation
import SwiftUI

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
                    .presentationBackgroundInteraction(.enabled)
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
