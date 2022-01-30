//
//  String+withTwoFractionDigits.swift
//  myAutoBudget
//
//  Created by MacBook on 15.12.2021.
//

import Foundation

extension String {
    func withTwoFractionDigits(from value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let number = NSNumber.init(value: value)
        return String(formatter.string(from: number) ?? "")
    }
}
