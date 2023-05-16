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
    
    @State private var specialSchedule : SpecialSchedule?
    @State private var showSpecialScheduleDetail = false
    var body: some View {
        NavigationStack{
            VStack{
                Text(" ")
                ScrollView{
                    if specialSchedule?.text != nil && specialSchedule?.dateTo ?? Date() > Date() {
                        VStack {
                            Text("Orar special în efect")
                                .bold()
                            Text("Momentan vehiculele circulă pe un program diferit. Apasă pentru mai multe detalii.")
                        }
                        .padding()
                        .background(Color(UIColor.systemGray4))
                        .cornerRadius(10)
                        .onTapGesture {
                            showSpecialScheduleDetail.toggle()
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
            SpecialScheduleDetailView(specialSchedule: specialSchedule ?? SpecialSchedule(motiv: nil, text: nil, to: nil))
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
