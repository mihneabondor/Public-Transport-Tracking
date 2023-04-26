//
//  BusCalculations.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/8/23.
//

import Foundation


class BusCalculations {
    public func laterThanCurrentTime(time1:  String) -> Bool {
        var filteredTime = time1;
        if time1.count == 6 {
            filteredTime = String(time1.dropLast())
        }
        
        guard let start = Formatter.today.date(from: filteredTime) else {return false}
        let currenDate = Date()
        return start > currenDate
    }
    
    public func timeIntervalFromCurrentTime(time: String) -> Bool {
        var filteredTime = time
        if time.count == 6 {
            filteredTime = String(filteredTime.dropLast())
        }
        
        guard let start = Formatter.today.date(from: filteredTime) else {return false}
        return Int(start.timeIntervalSinceNow) < 15*60
    }
    
    public func isPointBetweenPoints(x1: Double, y1: Double, x2: Double, y2: Double, x3: Double, y3: Double) -> Bool {
        let ABx = x2 - x1
        let ABy = y2 - y1
        let ACx = x3 - x1
        let ACy = y3 - y1

        let dotProduct = ABx * ACx + ABy * ACy

        if dotProduct >= 0 && dotProduct <= (ABx * ABx + ABy * ABy) {
            return true
        } else {
            return false
        }
    }
    
    public func earlierTime(time1: String, time2: String) -> Bool {
        var filtTime1 = time1, filtTime2 = time2
        if time1.count == 6 {
            filtTime1 = String(time1.dropLast())
        }
        if(time2.count == 6) {
            filtTime2 = String(time2.dropLast())
        }
        
        guard let start = Formatter.today.date(from: filtTime1),
              let end = Formatter.today.date(from: filtTime2) else {
            return false
        }
        let currentDate = Date()
        return currentDate > start && currentDate > end
    }
    
    public func earlierTimeOneTime(time: String) -> Bool {
        var filtTime = time
        if time.count == 6 {
            filtTime = String(time.dropLast())
        }
        guard let mutatedDate = Formatter.today.date(from: filtTime) else {return false}
        return Date() > mutatedDate
    }
    
    public func getGoodSchedules(schedule : Schedule) -> [[String]] {
        let date = Date().dayNumberOfWeek()
        var lines = [[String()]]
        if date == 1 {
            lines = schedule.station?.d?.lines ?? [[String()]]
        } else if date == 7 {
            lines = schedule.station?.s?.lines ?? [[String()]]
        } else {
            lines = schedule.station?.lv?.lines ?? [[String()]]
        }
        
        var goodSchedules = [[String()]]
        for elem in lines {
            if elem.count == 2 && elem[0] != "" && elem[1] != "" && elem[1] != elem[0]{
                if checkIfCurrentTimeIsBetween(startTime: elem[0], endTime: elem[1]){
                    goodSchedules.append([elem[0], elem[1]])
                }
            }
        }
        goodSchedules.removeFirst()
        return goodSchedules
    }
    
    func checkIfCurrentTimeIsBetween(startTime: String, endTime: String) -> Bool {
        guard var start = Formatter.today.date(from: startTime),
              var end = Formatter.today.date(from: endTime) else {
            return false
        }
        if start > end {
            swap(&start, &end)
        }
        return DateInterval(start: start, end: end).contains(Date())
    }
}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}

extension Formatter {
    static let today: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.defaultDate = Calendar.current.startOfDay(for: Date())
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
        
    }()
    
    static let todayForNews: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.defaultDate = Calendar.current.startOfDay(for: Date())
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss Z"
        return dateFormatter
    }()
}
