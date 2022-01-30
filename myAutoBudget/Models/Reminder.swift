//
//  Reminder.swift
//  myAutoBudget
//
//  Created by MacBook on 22.11.2021.
//

import RealmSwift
import Foundation

class Reminder: Object {
    
    @Persisted var title: String = ""
    @Persisted var body: String = ""
    @Persisted var mileage: Int?
    @Persisted var repeatingMileage: Int?
    @Persisted var date: Date? = Date()
    @Persisted var isViewed: Bool = false
    @Persisted var isWasted: Bool = false
    @Persisted(originProperty: "reminders") var car: LinkingObjects<Car>
    
}
