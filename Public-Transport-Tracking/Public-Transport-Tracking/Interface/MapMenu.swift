//
//  MapMenu.swift
//  Public-Transport-Tracking
//
//  Created by Mihnea on 6/12/23.
//

import SwiftUI

struct MapMenu: View {
    @State var toggle = false
    var body: some View {
        ZStack {
            if toggle {
                Color(UIColor.systemGray6)
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.4)))
                    .zIndex(0)
                    .opacity(0.7)
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation {
                            toggle = false
                        }
                    }
            }
            VStack {
                Spacer()
                
                if toggle {
                    Grid(alignment: .leading) {
                        HStack {
                            Image(systemName: "location")
                                .foregroundColor(.indigo)
                                .font(.title)
                            Text("Recentrare")
                                .font(.title3)
                        }
                        .padding()
                        .onTapGesture {
                            withAnimation {
                                toggle = false
                            }
                        }
                        
                        HStack {
                            Image(systemName: "signpost.right.and.left")
                                .foregroundColor(.indigo)
                                .font(.title)
                            Text("Direcții")
                                .font(.title3)
                        }
                        .padding()
                        .onTapGesture {
                            withAnimation {
                                toggle = false
                            }
                        }
                        
                        HStack {
                            Image(systemName: "bus.fill")
                                .foregroundColor(.indigo)
                                .font(.title)
                            Text("Vizualizare stații")
                                .font(.title3)
                        }
                        .padding()
                        .onTapGesture {
                            withAnimation {
                                toggle = false
                            }
                        }
                        
                        HStack {
                            Image(systemName: "arkit")
                                .foregroundColor(.indigo)
                                .font(.title)
                            Text("Mod AR")
                                .font(.title3)
                        }
                        .padding()
                        .onTapGesture {
                            withAnimation {
                                toggle = false
                            }
                        }
                    }
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.4)))
                        .zIndex(1)
                }
                
                HStack{
                    Spacer()
                    Image(systemName: "plus")
                        .rotationEffect(toggle ? Angle(degrees: -45) : Angle(degrees: 0))
                        .padding()
                        .font(.title)
                        .contentShape(Circle())
                        .background(Circle().fill(.shadow(.inner(radius: 10, x: -10, y: 15))).foregroundStyle(.indigo))
                        .onTapGesture {
                            withAnimation {
                                toggle.toggle()
                            }
                        }
                    Text(" ")
                        .font(.title2)
                }.padding()
                Text(" ")
                    .font(.title)
            }
        }
        .preferredColorScheme(.dark)
        .edgesIgnoringSafeArea(.all)
    }
}

struct MapMenu_Previews: PreviewProvider {
    static var previews: some View {
        MapMenu()
    }
}
