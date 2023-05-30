//
//  ARMarker.swift
//  Public-Transport-Tracking
//
//  Created by Mihnea on 5/30/23.
//

import SwiftUI

struct ARMarker: View {
    @State var name : String
    var body: some View {
        Text(name)
    }
}

struct ARMarker_Previews: PreviewProvider {
    static var previews: some View {
        ARMarker(name: "Memorandumului Nord")
    }
}
