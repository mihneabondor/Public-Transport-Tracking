//
//  StationView.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/7/23.
//

import SwiftUI

struct StationView: View {
    @Binding var statie : String
    @Binding var systemImage : String
    @Binding var closeView : Bool
    var body: some View {
        VStack{
            HStack{
                VStack{
                    Image(systemName: systemImage)
                        .padding()
                        .font(.title2)
                    Text(" ")
                        .font(.title3)
                        .padding()
                }
                Text(statie)
                    .padding([.trailing, .bottom, .top])
                    .bold()
                Spacer()
                
                Button {
                    withAnimation {
                        closeView.toggle()
                    }
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
                .font(.title)
                .padding()
                Text(" ")
                    .font(.title)
            }
        }
        .background() {
            Rectangle()
                .frame(width: UIScreen.main.bounds.width/1.1, height: UIScreen.main.bounds.height/15)
                .cornerRadius(20)
                .foregroundColor(Color(UIColor.systemGray4))
                .padding()
        }
        .preferredColorScheme(.dark)
    }
}

//struct StationView_Previews: PreviewProvider {
//    static var previews: some View {
//        StationView(statie: "Statia Campului", systemImage: "bus.fill")
//    }
//}
