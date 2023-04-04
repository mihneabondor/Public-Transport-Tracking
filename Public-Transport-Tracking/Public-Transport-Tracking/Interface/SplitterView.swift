//
//  SplitterView.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/3/23.
//

import SwiftUI

struct SplitterView: View {
    var body: some View {
        TabView {
            FavoritesScreen()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favorite")
            }
            Text("Nearby Screen")
                .tabItem {
                    Image(systemName: "mappin.circle.fill")
                    Text("Hartă")
            }
            Text("Comunicate")
                .tabItem {
                    Image(systemName: "newspaper")
                    Text("Comunicate")
                }
        }
        .background(.black)
        .tint(.purple)
        .preferredColorScheme(.dark)
    }
}

struct SplitterView_Previews: PreviewProvider {
    static var previews: some View {
        SplitterView()
    }
}
