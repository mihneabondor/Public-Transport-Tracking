//
//  OrarIntermediarView.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/11/23.
//

import SwiftUI

struct OrarIntermediarView: View {
    @State var routes = Constants.linii
    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]
    @Binding var selectedRoute : String
    @State private var activeNavigationView = false
    @State private var favorites = [String]()
    var body: some View {
        NavigationStack{
            VStack{
                Text(" ")
                ScrollView{
                    LazyVGrid(columns: columns) {
                        ForEach(routes, id: \.self) { route in
                            if favorites.contains(route) {
                                NavigationLink(destination: OrareView(pickerSelection: route)) {
                                    Text(route)
                                        .foregroundColor(.white)
                                        .font(.title3)
                                        .padding()
                                        .bold()
                                        .background(Rectangle()
                                            .frame(width: 75)
                                            .foregroundColor(Color(UIColor.systemGray4))
                                            .cornerRadius(10))
                                }
                            }
                        }
                    }.padding()
                    LazyVGrid(columns: columns) {
                        ForEach(routes, id: \.self) { route in
                            NavigationLink(destination: OrareView(pickerSelection: route)) {
                                Text(route)
                                    .foregroundColor(.white)
                                    .font(.title3)
                                    .padding()
                                    .bold()
                                    .background(Rectangle()
                                        .frame(width: 75)
                                        .foregroundColor(Color(UIColor.systemGray4))
                                        .cornerRadius(10))
                            }
                        }
                    }
                    .navigationDestination(for: String.self, destination: { route in
                        OrareView(pickerSelection: route)
                    })
                    .padding()
                }
            }
            .navigationDestination(isPresented: $activeNavigationView, destination: {
                OrareView(pickerSelection: selectedRoute)
            })
            .navigationTitle("Orare")
        }
        .preferredColorScheme(.dark)
        .onChange(of: selectedRoute) {_ in
            print(selectedRoute)
        }
        .onAppear {
            favorites = UserDefaults.standard.object(forKey: Constants.USER_DEFAULTS_FAVORITES) as? [String] ?? [String()]
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                if selectedRoute != "" {
                    activeNavigationView = true
                    print("Da")
                }
            }
            routes = routes.sorted(by: {$1 > $0})
        }
    }
}

struct OrarIntermediarView_Previews: PreviewProvider {
    static var previews: some View {
        OrarIntermediarView(selectedRoute: .constant("1"))
    }
}
