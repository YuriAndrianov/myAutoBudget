//
//  CustomDate.swift
//  myAutoBudget
//
//  Created by MacBook on 02.10.2021.
//

import Foundation

class DateProvider {
    let calendar = Calendar.current
    private var dateComponents = DateComponents()
    
    enum DateFormat: String {
        case ddMM = "dd.MM"
        case ddMMyyyy = "dd.MM.yyyy"
        case ddMMyyyyHHmm = "dd.MM.yyyy HH:mm"
        case dMMMM = "d MMMM"
        case dMMMMyyyy = "d MMMM yyyy"
        case MMMM = "LLLL"
        case yyyy = "yyyy"
        case dMMM = "d MMM"
        case MMM = "MMM"
        case MMMyy = "MMM yy"
    }
    
    func getStringFrom(date: Date, format: DateFormat) -> String {
        dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        let returningDate = calendar.date(from: dateComponents)
        
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.formattingContext = .standalone
        
        return formatter.string(from: returningDate!)
    }
    
    func getDate(from date: Date, component: Calendar.Component, difference: Int) -> (start: Date, end: Date) {
        dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        dateComponents.hour = 0
        dateComponents.minute = 0
        
        var tempDate = calendar.date(from: dateComponents)
        let startDate = calendar.date(byAdding: component, value: difference, to: tempDate!)!
        
        dateComponents.hour = 23
        dateComponents.minute = 59
        
        tempDate = calendar.date(from: dateComponents)
        let endDate = calendar.date(byAdding: component, value: difference, to: tempDate!)!
        
        return (startDate, endDate)
    }
}
