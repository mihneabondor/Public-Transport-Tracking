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
        presentationDetents: Set<PresentationDetent>, isPresented: Binding<Bool>,
        dragIndicator: Visibility = .visible,
        sheetCornerRadius: CGFloat?,
        largestUndimmedIdentifier: UISheetPresentationController.Detent.Identifier = .large,
        isTransparentBG: Bool = false,
        interactiveDisabled: Bool = true,
        @ViewBuilder content: @escaping () ->Content, onDismiss: @escaping ()-> ()
    ) -> some View { self
        .sheet (isPresented: isPresented) {
            onDismiss ()
        } content: {
            content()
                .presentationDetents (presentationDetents)
                .presentationDragIndicator(dragIndicator)
                .interactiveDismissDisabled(interactiveDisabled)
                .onAppear {
                    guard let windows = UIApplication.shared.connectedScenes.first as? UIWindowScene else{return}
                    if let controller = windows.windows.first?.rootViewController?.presentedViewController, let sheet = controller.presentationController as? UISheetPresentationController{
                        controller.presentingViewController?.view.tintAdjustmentMode = .normal
                        sheet.largestUndimmedDetentIdentifier = largestUndimmedIdentifier
                        sheet.preferredCornerRadius = sheetCornerRadius
                        
                    }
                }
        }
    }
}