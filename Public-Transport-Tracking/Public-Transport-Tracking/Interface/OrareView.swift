//
//  OrareView.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/10/23.
//

import SwiftUI

struct OrareView: View {
    @State var pickerSelection : String
    @State private var pageSelection = "LV"
    @State private var schedule = Schedule(name: "", type: "", route: "")
    @State private var statii = [[String]]()
    var body: some View {
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
                        Text("L-V")
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
                        Text("S")
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
                        Text("D")
                            .foregroundColor(.white)
                            .bold()
                            .underline(pageSelection == "D")
                    }
                    Spacer()
                    Button {
                        withAnimation {
                            pageSelection = "Statii"
                        }
                    } label: {
                        Text("Stații")
                            .foregroundColor(.white)
                            .bold()
                            .underline(pageSelection == "Statii")
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
                    ScheduleTable(schedule: $schedule, pageFilter: $pageSelection, filter: "LV")
                        .tag("LV")
                    ScheduleTable(schedule: $schedule, pageFilter: $pageSelection, filter: "S")
                        .tag("S")
                    ScheduleTable(schedule: $schedule, pageFilter: $pageSelection, filter: "D")
                        .tag("D")
                    StatiiView(statii: statii)
                        .tag("Statii")
                }.tabViewStyle(.page)
                Spacer()
            }
            .preferredColorScheme(.dark)
            .onChange(of: pickerSelection, perform: { _ in
                Task {
                    do {
                        schedule = try await RequestManager().getSchedule(line: pickerSelection)
                    } catch let err {
                        print(err)
                    }
                }
            })
            .onAppear{
                let weekday = Calendar.current.component(.weekday, from: Date())
                if weekday == 1 {
                    pageSelection = "D"
                } else if weekday == 7 {
                    pageSelection = "S"
                }
                Task {
                    do {
                        schedule = try await RequestManager().getSchedule(line: pickerSelection)
                    } catch let err {
                        print(err)
                    }
                    
                    var routes = [Route]()
                    do {
                        routes = try await RequestManager().getRoutes()
                    } catch let err {
                        print(err)
                    }
                    
                    let routeId = routes.first(where: {$0.routeShortName == pickerSelection})?.routeId!
                    let idTur : String = "\(routeId ?? 0)_0", idRetur = "\(routeId ?? 0)_1"
                    
                    var stops = [Statie]()
                    do {
                        stops = try await RequestManager().getStops()
                    } catch let err {
                        print(err)
                    }
                    
                    var stopTimes = [StopTime]()
                    do {
                        stopTimes = try await RequestManager().getStopTimes()
                    } catch let err {
                        print(err)
                    }
                    
                    let stopTimesTur = stopTimes.filter({$0.tripId == idTur}), stopTimesRetur = stopTimes.filter({$0.tripId == idRetur})
                    
                    for stopTimeTur in stopTimesTur {
                        let stopId = stopTimeTur.stopId
                        let statie = stops.first(where: {$0.stopId == Int(stopId!)})?.stopName
                        var array = [String]()
                        array.append(statie!)
                        statii.append(array)
                    }
                    
                    var index = 0
                    for stopTimeRetur in stopTimesRetur {
                        let stopId = stopTimeRetur.stopId
                        let statie = stops.first(where: {$0.stopId == Int(stopId!)})?.stopName
                        if statii.count > index {
                            var array = [String]()
                            array.append("SPATIU2")
                            statii.append(array)
                        } else if statii[index].count == 0 {
                            statii[index].append("SPATIU2")
                        }
                        statii[index].append(statie!)
                        index += 1
                            
                    }
                    
                    for i in 0..<statii.count {
                        if statii[i].count == 1 {
                            statii[i].insert("SPATIU1", at: 0)
                        }
                    }
                }
            }
    }
}

struct ScheduleTable : View {
    @Binding var schedule : Schedule
    @Binding var pageFilter : String
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
            .onChange(of: pageFilter) {_ in
                if filter == "LV" {
                    matrix = schedule.station?.lv?.lines ?? [[String()]]
                }
                if filter == "S" {
                    matrix = schedule.station?.s?.lines ?? [[String()]]
                }
                if filter == "D" {
                    matrix = schedule.station?.d?.lines ?? [[String()]]
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
            }
            if filter == "S" {
                matrix = schedule.station?.s?.lines ?? [[String()]]
            }
            if filter == "D" {
                matrix = schedule.station?.d?.lines ?? [[String()]]
            }
        }
    }
}

struct StatiiView : View {
    @State var statii : [[String]]
    var body : some View {
        ScrollView {
            ForEach(statii, id: \.self) {row in
                HStack{
                    ForEach(Array(row.enumerated()), id: \.element) { index, statie in
                        if statie != "SPATIU1" && statie != "SPATIU2" {
                            Text(statie)
                                .frame(maxWidth: .infinity, alignment: index == 0 ? .leading : .trailing)
                                .padding()
                        }
                    }
                }
                .background((statii.firstIndex(where: {$0 == row}) ?? 0)%2 == 0 ? Color(UIColor.systemGray6) : .clear)
            }
        }
    }
}

struct OrareView_Previews: PreviewProvider {
    static var previews: some View {
        OrareView(pickerSelection: "1")
    }
}
