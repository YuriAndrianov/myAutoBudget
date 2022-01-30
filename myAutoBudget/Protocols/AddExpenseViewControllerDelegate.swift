//
//  ChosenExpenseViewControllerDelegate.swift
//  myAutoBudget
//
//  Created by MacBook on 10.11.2021.
//

import Foundation

protocol AddExpenseViewControllerDelegate: AnyObject {

    func updateTableView(from startDate: Date, to endDate: Date)
    
}
