//
//  SpecialScheduleDetailView.swift
//  Public-Transport-Tracking
//
//  Created by Mihnea on 5/12/23.
//

import SwiftUI

struct SpecialScheduleDetailView: View {
    @State var specialSchedule : SpecialSchedule
    var body: some View {
        ScrollView{
            VStack {
                Text("Orar special - \(specialSchedule.motiv ?? "")")
                    .bold()
                    .padding(25)
                    .multilineTextAlignment(.center)
                    .font(.title3)
                Text(specialSchedule.text ?? "")
                    .padding()
                    .multilineTextAlignment(.leading)
                Spacer()
            }
        }
        .onAppear {
            print(specialSchedule)
        }
    }
}

struct SpecialScheduleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SpecialScheduleDetailView(specialSchedule: SpecialSchedule(motiv: nil, text: nil, from: nil, to: nil))
    }
}
