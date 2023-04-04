//
//  SplashScreen.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/3/23.
//

import SwiftUI

struct SplashScreen: View {
    @State private var selectedTab = 1
    var body: some View {
        NavigationStack {
            VStack {
                AmbienceVid()
                    .ignoresSafeArea()
                Spacer()
                TabView(selection: $selectedTab) {
                    FirstPage(selectedTab: $selectedTab)
                        .tag(1)
                    SecondPage(selectedTab: $selectedTab)
                        .tag(2)
                    ThirdPage(selectedTab: $selectedTab)
                        .tag(3)
                }
                .tabViewStyle(.page)
                .padding()
                
                NavigationLink(destination: SplitterView().navigationBarBackButtonHidden(true)){
                    Text(selectedTab != 3 ? "Continuă" : "Începe")
                        .frame(width: UIScreen.main.bounds.width/1.3)
                        .padding()
                        .background(.purple)
                        .foregroundColor(.white)
                        .bold()
                        .font(.headline)
                        .cornerRadius(20)
                        .allowsHitTesting(selectedTab != 3)
                        .onTapGesture {
                            withAnimation{
                                selectedTab += 1
                            }
                        }
                }
                Spacer()
            }
            .onAppear() {
                UserDefaults.standard.set(true, forKey: Constants.USER_DEFAULTS_SPLASHSCREEN)
            }
            .background(.black)
        }
    }
}

struct FirstPage : View {
    @Binding var selectedTab : Int
    var body: some View {
        VStack {
            HStack{
                Text("La îndemână")
                    .font(.title)
                    .bold()
                    .padding()
                    .foregroundColor(.white)
                Spacer()
            }
            Text(" ")
            
            HStack{
                Text("Cu RouteEase mereu alături, poți verifica oricând locația live liniei de transport în comun dorite.")
                    .font(.title2)
                    .padding([.bottom, .trailing, .leading])
                    .foregroundColor(.white)
                Spacer()
            }
            Spacer()
        }
    }
}

struct SecondPage : View {
    @Binding var selectedTab : Int
    var body : some View {
        VStack {
            HStack{
                Text("Comunicate")
                    .font(.title)
                    .bold()
                    .padding()
                    .foregroundColor(.white)
                Spacer()
            }
            Text(" ")
            
            HStack{
                Text("Fii mereu la zi cu schimbările efectuate precizate chiar din aplicație")
                    .font(.title2)
                    .padding([.bottom, .trailing, .leading])
                    .foregroundColor(.white)
                Spacer()
            }
            Spacer()
        }
    }
}

struct ThirdPage : View {
    @Binding var selectedTab : Int
    var body : some View {
        VStack {
            HStack{
                Text("Ușor de folosit")
                    .font(.title)
                    .bold()
                    .padding()
                    .foregroundColor(.white)
                Spacer()
            }
            Text(" ")
            
            HStack{
                Text("Interfața prietenoasă permite navigarea rapidă în cel mai scurt timp.")
                    .font(.title2)
                    .padding([.bottom, .trailing, .leading])
                    .foregroundColor(.white)
                Spacer()
            }
            Spacer()
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
