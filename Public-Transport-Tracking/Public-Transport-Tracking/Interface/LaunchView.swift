//
//  LaunchScreen.swift
//  Public-Transport-Tracking
//
//  Created by Mihnea on 5/16/23.
//

import SwiftUI

struct LaunchView: View {
    @State private var showLoading = false
    
    @StateObject var motion = MotionManager()
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                    .resizable()
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
                    .shadow(color: .black, radius: 3, x: -motion.x * 10, y: -motion.y * 10)
                
                if showLoading {
                    ProgressView()
                        .padding()
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                withAnimation {
                    showLoading = true
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
    }
}
