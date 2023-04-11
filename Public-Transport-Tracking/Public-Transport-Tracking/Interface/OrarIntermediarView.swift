//
//  OrarIntermediarView.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/11/23.
//

import SwiftUI

struct OrarIntermediarView: View {
    @State var routes = Constants.linii
    @State var outsideNavigationLinkActive = false
    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]

    var body: some View {
        NavigationStack{
            VStack{
                Text(" ")
                    .padding()
                ScrollView{
                    LazyVGrid(columns: columns) {
                        ForEach(routes, id: \.self) { route in
                            NavigationLink(route, value: route)
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
                    .navigationDestination(for: String.self, destination: { route in
                        OrareView(pickerSelection: route)
                    })
                    .padding()
                }
            }.navigationTitle("Orare")
        }
        .preferredColorScheme(.dark)
        .onAppear {
            routes = routes.sorted(by: {$1 > $0})
            let favorites = UserDefaults.standard.object(forKey: Constants.USER_DEFAULTS_FAVORITES) as? [String?] ?? [String()]
            routes = routes.sorted(by: {favorites.contains($0) && favorites.contains($1)})
        }
    }
}

struct OrarIntermediarView_Previews: PreviewProvider {
    static var previews: some View {
        OrarIntermediarView()
    }
}
