//
//  File.swift
//  myAutoBudget
//
//  Created by MacBook on 10.11.2021.
//

import Foundation

protocol DateViewControllerDelegate: AnyObject {
    
    func updateDates(startDate: Date, endDate: Date)
}
