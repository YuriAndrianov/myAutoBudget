//
//  Car.swift
//  myAutoBudget
//
//  Created by MacBook on 22.11.2021.
//

import RealmSwift
import Foundation

class Car: Object {
    
    @Persisted(primaryKey: true) var id: String = ""
    @Persisted var brand: String = ""
    @Persisted var model: String = ""
    @Persisted var initialMileage: Int?
    @Persisted var imageName: String?
    @Persisted var expenses: List<Expense> = List<Expense>()
    @Persisted var reminders: List<Reminder> = List<Reminder>()
    
}
