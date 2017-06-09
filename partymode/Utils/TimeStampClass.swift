//
//  TimeStampClass.swift
//  partymode
//
//  Created by Nikita on 2/1/17.
//  Copyright © 2017 com. All rights reserved.
//

import Foundation
class TimeStampClass {
    func convertToTimestamp(date: Date) -> String {//returns second unit value
        // convert an NSDate object to a timestamp string
        return String(Int64(date.timeIntervalSince1970))// * 1000 for milisec
    }
    
    func convertFromTimestamp(seconds: Int) -> Date {
        // Convert the timestamp string to an NSDate object
        
        return Date(timeIntervalSince1970: TimeInterval(seconds))
    }
    func checkTimeStamp(stamp: Int, time:String) -> String {
        let fulltime = time.components(separatedBy: " ")
        //let only_date = fulltime[0]
        let only_time = fulltime[1]
        
        let convertedDate = TimeStampClass().convertFromTimestamp(seconds: stamp)
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"//"yyyy-MM-dd"
        
        let userCalendar = Calendar.current
        let tomorrow_date = userCalendar.date(byAdding: .day, value: 1, to: Date())
        let yesterday_date = userCalendar.date(byAdding: .day, value: -1, to: Date())
        
        let converted_string = dateFormatter.string(from: convertedDate)
        let today_string = dateFormatter.string(from: Date())
        let tomorrow_string = dateFormatter.string(from: tomorrow_date!)
        let yesterday_string = dateFormatter.string(from: yesterday_date!)
        
        
        if (converted_string == tomorrow_string) {
            return NSLocalizedString("tomorrow", comment: "") + " " + only_time
        } else if (converted_string == today_string) {
            return NSLocalizedString("today", comment: "") + " " + only_time
        }
        else if (converted_string == yesterday_string) {
            return NSLocalizedString("yesterday", comment: "") + " " + only_time
        }
        
        return time
    }
    func filterTimeStampForChat(stamp: Int, time:String) -> String {
        let fulltime = time.components(separatedBy: " ")
        //let only_date = fulltime[0]
        let only_time = fulltime[1]
        
        let convertedDate = TimeStampClass().convertFromTimestamp(seconds: stamp)
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"//"yyyy-MM-dd"
        
        let userCalendar = Calendar.current
        let tomorrow_date = userCalendar.date(byAdding: .day, value: 1, to: Date())
        let yesterday_date = userCalendar.date(byAdding: .day, value: -1, to: Date())
        
        let converted_string = dateFormatter.string(from: convertedDate)
        let today_string = dateFormatter.string(from: Date())
        let tomorrow_string = dateFormatter.string(from: tomorrow_date!)
        let yesterday_string = dateFormatter.string(from: yesterday_date!)
        
        
        if (converted_string == tomorrow_string) {
            return NSLocalizedString("tomorrow", comment: "") + " " + only_time
        } else if (converted_string == today_string) {
            return only_time //NSLocalizedString("today", comment: "") + " " + only_time
        }
        else if (converted_string == yesterday_string) {
            return NSLocalizedString("yesterday", comment: "") + " " + only_time
        }
        
        return time
    }
    
}
