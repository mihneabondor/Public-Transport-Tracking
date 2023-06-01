//
//  TestView.swift
//  Mirador
//
//  Created by Andrew Hart on 21/05/2023.
//

import SwiftUI
import Mirador
import CoreLocation

struct ARStationView: View {
    @State private var wentThroughTutorial = false
    var body: some View {
        ZStack{
            ARView()
            if !wentThroughTutorial{
                Color(UIColor.systemGray6.withAlphaComponent(0.9))
                VStack {
                    Image(systemName: "arkit")
                        .font(.system(size: 50))
                    Text("Îndreaptă camera spre o stație din apropiere pentru a-i afla denumirea.")
                        .multilineTextAlignment(.center)
                        .padding()
                    Text("OK")
                        .padding()
                        .frame(width: UIScreen.main.bounds.width/2)
                        .background(Color(UIColor.systemGray3).cornerRadius(20))
                        .onTapGesture {
                            withAnimation {
                                wentThroughTutorial = true
                                UserDefaults.standard.set(true, forKey: "com.Busify.wentThroughARTutorial")
                            }
                        }
                }.foregroundColor(.white)
            }
            VStack {
                Spacer()
                Text("Modul AR funcționează cel mai bine atunci când nu te afli în mișcare continuă.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .font(.footnote)
                    .shadow(color: .white, radius: 3)
                    .padding()
            }
        }
        .onAppear {
            withAnimation {
                wentThroughTutorial = UserDefaults.standard.bool(forKey: "com.Busify.wentThroughARTutorial")
            }
        }
        .edgesIgnoringSafeArea(.all)
        .preferredColorScheme(.dark)
    }
}
