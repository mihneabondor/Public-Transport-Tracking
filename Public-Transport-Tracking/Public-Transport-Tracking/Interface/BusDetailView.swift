//
//  BusDetailView.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/8/23.
//

import SwiftUI

struct BusDetailView: View {
    @Binding var vehicle : Vehicle?
    @Binding var closeView : Bool
    
    let vehicleTypesImages = ["tram.fill", "train.side.front.car", "train.side.front.car", "bus.fill", "ferry.fill", "cablecar.fill", "helicopter.fill", "bus.fill", "", "", "", "bus.doubledecker.fill", "bus.fill"]
    var body: some View {
        VStack{
            HStack{
                Text(" ")
                    .padding(.leading)
                VStack{
                    Image(systemName: "bus.fill")
                        .padding()
                        .font(.title2)
                    Text(" ")
                        .font(.title3)
                        .padding(.top)
                }
                Text("Linia \(vehicle?.routeShortName ?? "")")
                    .padding([.trailing, .top])
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
                .padding(.trailing)
                Text(" ")
                    .font(.title)
            }
                HStack{
                    Text(" ")
                        .font(.title)
                    VStack{
                        Text("STAȚIE CURENTĂ")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Text("\(vehicle?.statie ?? "Necunoscută")")
                            .padding(.bottom)
                        Text("SPRE")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Text(vehicle?.routeLongName?.components(separatedBy: "- ")[1] ?? "")
                    }.padding([.trailing, .leading, .bottom])
                    Spacer()
                    VStack{
                        Text("ETA")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Text(String(vehicle?.eta ?? 0))
                            .padding(.bottom)
                        
                        Text("SERVICII")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        HStack{
                            if vehicle?.bikeAccessible == "BIKE_ACCESSIBLE"{
                                Image(systemName: "bicycle")
                            } else {
                                Text("-")
                            }
                            if vehicle?.wheelchairAccessible == "WHEELCHAIR_ACCESSIBLE"{
                                Image(systemName: "figure.roll")
                            } else {
                                Text("-")
                            }
                        }
                    }.padding([.trailing, .leading, .bottom])
                    Text(" ")
                        .font(.title)
                }
                HStack{
                    Button {
                        
                    } label: {
                        Image(systemName: "calendar")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding([.leading, .trailing])
                    }
                    
                    Button {
                        UIApplication.shared.open(URL(string: "sms:open?addresses=7479&body=\(vehicle?.routeShortName ?? "")")!, options: [:], completionHandler: nil)
                    } label: {
                        Image(systemName: "ticket.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding([.leading, .trailing])
                    }
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "heart")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding([.leading, .trailing])
                    }
                }
                Text(" ")
                    .padding(.bottom)
        }
        .background() {
            Rectangle()
                .frame(width: UIScreen.main.bounds.width/1.1, height: UIScreen.main.bounds.height/3.7)
                .cornerRadius(20)
                .foregroundColor(Color(UIColor.systemGray4))
                .padding()
        }
        .preferredColorScheme(.dark)
    }
}
