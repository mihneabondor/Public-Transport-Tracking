//
//  WhatsNewScreen.swift
//  Public-Transport-Tracking
//
//  Created by Mihnea on 6/1/23.
//

import SwiftUI

struct WhatsNewScreen: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            Text("Ce e nou în Busify")
                .bold()
                .font(.title)
                .padding()
            
            Text(" ")
                .font(.system(size: 70))
            
            GridCell(systemImage: "hand.tap", title: "Scurtături", text: "Ține apăsat textul din celula unui vehicul din pagina Favorite pentru acțiuni rapide")
            GridCell(systemImage: "ladybug", title: "Mai puține erori", text: "Au fost reparate o serie de probleme cunoscute. Acum Busify se va mișca mai bine :)")
            
            Spacer()
                .preferredColorScheme(.dark)
            
            Button("Continuă") {
                dismiss()
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.purple
                .frame(width: UIScreen.main.bounds.width/1.2)
                .cornerRadius(20)
            )
            Text(" ")
        }
    }
}

struct GridCell : View {
    @State var systemImage : String
    @State var title : String
    @State var text : String
    var body : some View {
        HStack {
            Image(systemName: systemImage)
                .font(.title)
                .foregroundColor(.purple)
                .padding([.leading, .top, .trailing])
            VStack {
                Text(title)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing)
            }
            Spacer()
        }.padding(.bottom)
    }
}

struct WhatsNewScreen_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewScreen()
    }
}
