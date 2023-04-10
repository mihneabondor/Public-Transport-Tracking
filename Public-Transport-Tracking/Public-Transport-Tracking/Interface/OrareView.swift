//
//  OrareView.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/10/23.
//

import SwiftUI

struct OrareView: View {
    @Binding var pickerSelection : String
    @State private var pageSelection = "LV"
    @State private var schedule = Schedule(name: "", type: "", route: "")
    var body: some View {
        NavigationView {
            VStack{
                HStack{
                    Text("Orarul liniei ")
                        .font(.title2)
                        .bold()
                    Picker("", selection: $pickerSelection) {
                        ForEach(Constants.linii.sorted(), id: \.self) {item in
                            Text(item)
                                .tag(item)
                        }
                    }
                    .tint(.purple)
                    .pickerStyle(.menu)
                    Spacer()
                }.padding()
                HStack {
                    Spacer()
                    Button {
                        withAnimation{
                            pageSelection = "LV"
                        }
                    } label: {
                        Text("Luni-Vineri")
                            .foregroundColor(.white)
                            .underline(pageSelection == "LV")
                            .bold()
                    }
                    Spacer()
                    Button {
                        withAnimation{
                            pageSelection = "S"
                        }
                    } label: {
                        Text("Sambata")
                            .foregroundColor(.white)
                            .underline(pageSelection == "S")
                            .bold()
                    }
                    Spacer()
                    Button {
                        withAnimation{
                            pageSelection = "D"
                        }
                    } label: {
                        Text("Duminica")
                            .foregroundColor(.white)
                            .bold()
                            .underline(pageSelection == "D")
                    }
                    Spacer()
                }   .padding()
                    .background(Color(UIColor.systemGray5))
                HStack {
                    Text("\(schedule.route?.components(separatedBy: " - ").first ?? "")")
                        .bold()
                        .padding(.leading)
                    Spacer()
                    Text("|")
                    Spacer()
                    Text("\(schedule.route?.components(separatedBy: " - ").last ?? "")")
                        .bold()
                        .padding(.trailing)
                }
                .padding()
                .background(Color(UIColor.systemGray5))
                TabView(selection: $pageSelection) {
                    ScheduleTable(schedule: $schedule, filter: "LV")
                        .tag("LV")
                    ScheduleTable(schedule: $schedule, filter: "S")
                        .tag("S")
                    ScheduleTable(schedule: $schedule, filter: "D")
                        .tag("D")
                }.tabViewStyle(.page)
                Spacer()
            }
            .navigationTitle("Orare")
            .preferredColorScheme(.dark)
            .onChange(of: pickerSelection, perform: { _ in
                Task {
                    schedule = try! await RequestManager().getSchedule(line: pickerSelection)
                }
            })
            .onAppear{
                Task {
                    schedule = try! await RequestManager().getSchedule(line: pickerSelection)
                }
            }
        }
    }
}

struct ScheduleTable : View {
    @Binding var schedule : Schedule
    @State var filter : String
    @State var matrix = [[String()]]
    var body : some View {
        ScrollViewReader{ scrollValue in
            ScrollView{
                ForEach(matrix, id: \.self) {row in
                    HStack{
                        ForEach(row, id: \.self) {schedule in
                            Spacer()
                            Text(schedule)
                                .foregroundColor(BusCalculations().earlierTime(time1: row.first ?? "", time2: row.last ?? "") ? Color(UIColor.systemGray) : .white)
                            Spacer()
                        }
                    }
                    .bold((BusCalculations().earlierTimeOneTime(time: row.first ?? "") && BusCalculations().earlierTimeOneTime(time: row.last ?? "") == false) || (BusCalculations().earlierTimeOneTime(time: row.first ?? "") == false && BusCalculations().earlierTimeOneTime(time: row.last ?? "")))
                    .strikethrough(BusCalculations().earlierTime(time1: row.first ?? "", time2: row.last ?? ""))
                    .padding()
                    .background((matrix.firstIndex(where: {$0 == row}) ?? 0)%2 == 0 ? Color(UIColor.systemGray6) : .clear)
                }
            }
            .onChange(of: matrix) {_ in
                var currentSchedule = [String]()
                for row in matrix {
                    if currentSchedule == [String]() && BusCalculations().earlierTime(time1: row.first ?? "", time2: row.last ?? "") == false {
                        currentSchedule = row
                    }
                }
                scrollValue.scrollTo(currentSchedule, anchor: .top)
            }
        }.onChange(of: schedule.station?.lv?.lines){ _ in
            if filter == "LV" {
                matrix = schedule.station?.lv?.lines ?? [[String()]]
            } else if filter == "S" {
                matrix = schedule.station?.s?.lines ?? [[String()]]
            } else {
                matrix = schedule.station?.d?.lines ?? [[String()]]
            }
        }
    }
}

struct OrareView_Previews: PreviewProvider {
    static var previews: some View {
        OrareView(pickerSelection: .constant("1"))
    }
}
