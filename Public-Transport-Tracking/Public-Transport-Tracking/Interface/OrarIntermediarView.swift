//
//  OrarIntermediarView.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/11/23.
//

import SwiftUI

@available(iOS 16.0, *)
struct OrarIntermediarView: View {
    @State var routes = Constants.linii
    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]
    @Binding var selectedRoute : String
    @State private var activeNavigationView = false
    @State private var favorites = [String]()
    
    @State private var specialSchedule = [SpecialSchedule]()
    @State private var showSpecialScheduleDetail = false
    @State private var selectedSpecialSchedule = SpecialSchedule(motiv: nil, from: nil, to: nil)
    var body: some View {
        NavigationStack{
            VStack{
                Text(" ")
                ScrollView{
                    ForEach(specialSchedule, id: \.self) {schedule in
                        if schedule.text != nil && schedule.dateTo ?? Date() > Date() && schedule.dateFrom ?? Date() < Date() {
                            VStack {
                                Text("Orar special în efect - \(schedule.motiv ?? "")")
                                    .bold()
                                    .multilineTextAlignment(.leading)
                                Text("Momentan vehiculele circulă pe un program diferit. Apasă pentru mai multe detalii.")
                            }
                            .padding()
                            .background(Color(UIColor.systemGray4))
                            .cornerRadius(10)
                            .onTapGesture {
                                selectedSpecialSchedule = schedule
                                showSpecialScheduleDetail.toggle()
                            }
                        }
                    }
                    
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
        .sheet(isPresented: $showSpecialScheduleDetail, content: {
            SpecialScheduleDetailView(specialSchedule: selectedSpecialSchedule)
                .presentationDetents([.medium, .large])
        })
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
            Task {
                do {
                    specialSchedule = try await RequestManager().getSpecialSchedule()
                } catch let err {
                    print(err)
                }
            }
        }
    }
}

struct OrarIntermediarView_Previews: PreviewProvider {
    static var previews: some View {
        OrarIntermediarView(selectedRoute: .constant("1"))
    }
}
