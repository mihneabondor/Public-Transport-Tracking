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
    
    @State private var savedSchedule : Schedule?
    var body: some View {
            VStack{
                Text(" ")
                    .padding(UIScreen.main.bounds.height/20)
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
                    
                    Button {
                        if let encoded = try? JSONEncoder().encode(schedule) {
                            UserDefaults.standard.set(encoded, forKey: "com.Busify.schedule.\(pickerSelection)")
                        }
                        savedSchedule = schedule
                    } label: {
                        if let _ = savedSchedule {
                            Label("Descărcat", systemImage: "checkmark")
                        } else {
                            Label("Descarcă", systemImage: "square.and.arrow.down")
                                .foregroundColor(.purple)
                        }
                    }
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
            .edgesIgnoringSafeArea(.top)
            .preferredColorScheme(.dark)
            .onChange(of: pickerSelection, perform: { _ in
                Task {
                    do {
                        schedule = try await RequestManager().getSchedule(line: pickerSelection)
                        for i in 0..<(schedule.station?.lv?.lines.count ?? 0) {
                            for j in 0..<(schedule.station?.lv?.lines[i].count ?? 0){
                                if schedule.station?.lv?.lines[i][j].count == 6 {
                                    schedule.station?.lv?.lines[i][j] = String(schedule.station?.lv?.lines[i][j].dropLast() ?? "")
                                }
                            }
                        }
                        
                        for i in 0..<(schedule.station?.s?.lines.count ?? 0) {
                            for j in 0..<(schedule.station?.s?.lines[i].count ?? 0){
                                if schedule.station?.s?.lines[i][j].count == 6 {
                                    schedule.station?.s?.lines[i][j] = String(schedule.station?.s?.lines[i][j].dropLast() ?? "")
                                }
                            }
                        }
                        
                        for i in 0..<(schedule.station?.d?.lines.count ?? 0) {
                            for j in 0..<(schedule.station?.d?.lines[i].count ?? 0){
                                if schedule.station?.d?.lines[i][j].count == 6 {
                                    schedule.station?.d?.lines[i][j] = String(schedule.station?.d?.lines[i][j].dropLast() ?? "")
                                }
                            }
                        }
                    } catch let err {
                        print(err)
                    }
                }
            })
            .onAppear{
                if let data = UserDefaults.standard.object(forKey: "com.Busify.schedule.\(pickerSelection)") as? Data,
                   let category = try? JSONDecoder().decode(Schedule.self, from: data) {
                    savedSchedule = category
                    if !Connectivity.isConnectedToInternet {
                        DispatchQueue.main.async {
                            schedule = category
                        }
                    }
                }
                let weekday = Calendar.current.component(.weekday, from: Date())
                if weekday == 1 {
                    pageSelection = "D"
                } else if weekday == 7 {
                    pageSelection = "S"
                }
                
                if Connectivity.isConnectedToInternet {
                    Task {
                        do {
                            schedule = try await RequestManager().getSchedule(line: pickerSelection)
                        } catch let err {
                            print(err)
                        }
                        if let _ = savedSchedule {
                            if let encoded = try? JSONEncoder().encode(schedule) {
                                UserDefaults.standard.set(encoded, forKey: "com.Busify.schedule.\(pickerSelection)")
                            }
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
                        ForEach(row, id: \.self) {time in
                            Spacer()
                            Text(time)
                                .foregroundColor(BusCalculations().earlierTimeOneTime(time: time) ? Color(UIColor.systemGray) : .white)
                                .strikethrough(BusCalculations().earlierTimeOneTime(time: time))
                                .bold(BusCalculations().timeIntervalFromCurrentTime(time: time) && !BusCalculations().earlierTimeOneTime(time: time))
                                .contextMenu {
                                    Button {
                                        var capat = ""
                                        if time == row[0] {
                                            capat = schedule.station?.lv?.inStopName ?? ""
                                            if pageFilter == "LV" {
                                                capat = schedule.station?.lv?.inStopName ?? ""
                                            } else if pageFilter == "S" {
                                                capat = schedule.station?.s?.inStopName ?? ""
                                            } else {
                                                capat = schedule.station?.d?.inStopName ?? ""
                                            }
                                        } else {
                                            if pageFilter == "LV" {
                                                capat = schedule.station?.lv?.outStopName ?? ""
                                            } else if pageFilter == "S" {
                                                capat = schedule.station?.s?.outStopName ?? ""
                                            } else {
                                                capat = schedule.station?.d?.outStopName ?? ""
                                            }
                                        }
                                        NotificationManager().nextStartNotification(line: schedule.name ?? "", capat: capat, time: time, repeats: false)
                                    } label: {
                                        Label("Notifică", systemImage: "bell.badge.fill")
                                    }
                                }
                            Spacer()
                        }
                    }
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
