//
//  ChartFormatter.swift
//  myAutoBudget
//
//  Created by MacBook on 04.10.2021.
//

import Charts
import Foundation

class ChartFormatter: NSObject, IValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        let total = UserDefaults.standard.double(forKey: "totalValue")
        
        var valueToUse = value / total * 100
        valueToUse = Double(round(10 * valueToUse) / 10)
        
        let minNumber = 5.0
        
        if valueToUse < minNumber {
            return ""
        } else {
            return String(valueToUse) + "%"
        }
    }
}
