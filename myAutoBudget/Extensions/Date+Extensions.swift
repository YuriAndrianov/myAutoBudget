//
//  Date+dayAndMonth.swift
//  myAutoBudget
//
//  Created by MacBook on 11.11.2021.
//

import Foundation

extension Date {
    
    enum Period {
        case year
        case monthAndYear
        case dayMonthAndYear
    }
    
    func dayMonthAndYear() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: components)!
    }
    
    func monthAndYear() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }
    
    func year() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self)
        return calendar.date(from: components)!
    }

    func getCurrentDayStart() -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.hour = 0
        components.minute = 0
        components.second = 0
        return calendar.date(from: components)!
    }
    
    func getCurrentWeekStart() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)!
    }
    
    func getCurrentWeekEnd() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        let monday = calendar.date(from: components)!
        let nextMonday = calendar.date(byAdding: .day, value: 7, to: monday)!
        return calendar.date(byAdding: .second, value: -1, to: nextMonday)!
    }
    
    func getCurrentMonthStart() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }
    
    func getCurrentMonthEnd() -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: self)
        components.month! += 1
        components.day = 1
        let startOfNextMonth = calendar.date(from: components)!
        return calendar.date(byAdding: .second, value: -1, to: startOfNextMonth)!
    }
    
    func getCurrentYearStart() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self)
        return calendar.date(from: components)!
    }
    
//    func getCurrentYearEnd() -> Date {
//        let calendar = Calendar.current
//        var components = calendar.dateComponents([.year, .month, .day], from: self)
//        components.year! += 1
//        components.month = 1
//        components.day = 1
//        let startOfNextYear = calendar.date(from: components)!
//        return calendar.date(byAdding: .second, value: -1, to: startOfNextYear)!
//    }
    
    func getCurrentYearEnd() -> Date {
        let calendar = Calendar.current
        let interval = calendar.dateInterval(of: .year, for: self)
        return interval!.end
    }
    
}
