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
            Text("Ce este nou în Busify")
                .bold()
                .font(.title)
                .padding()
            
            Text(" ")
                .font(.system(size: 70))
            
            GridCell(systemImage: "arkit", title: "Modul AR", text: "Îndreaptă camera spre o stație pentru a afla mai multe detalii despre aceasta")
            GridCell(systemImage: "square.and.arrow.up", title: "Dă mai departe", text: "Distribuie vehiculul selectat din ecranul hărții")
            GridCell(systemImage: "paperplane", title: "Contact", text: "O cale nouă și sigură pentru a-mi da sugestii sau a-mi spune ce nu merge")
            
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
