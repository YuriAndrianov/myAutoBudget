//
//  RealmService.swift
//  myAutoBudget
//
//  Created by MacBook on 16.01.2022.
//

import Foundation
import RealmSwift
import Charts

class ChartsService {

    func getFilteredExpenses(category: Expense.Category, from startDate: Date, to endDate: Date) -> PieChartDataEntry {

        var result = PieChartDataEntry(value: 0, label: nil, icon: nil)
        var expenses = List<Expense>()

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return result }

        if let car = appDelegate.car { expenses = car.expenses }

        let predicate = NSPredicate.init(format: "self.date >= %@ && self.date <= %@ && self.category == %@", startDate as CVarArg, endDate as CVarArg, category.rawValue)

        let filteredExpenses: Double = expenses.filter(predicate).sum(ofProperty: "value")
        let icon = UIImage(named: category.rawValue)

        result = PieChartDataEntry(value: filteredExpenses, label: category.rawValue, icon: icon)

        return result
    }
}
