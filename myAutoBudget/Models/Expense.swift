//
//  ExpenseModel.swift
//  myAutoBudget
//
//  Created by MacBook on 30.09.2021.
//

import RealmSwift
import Foundation

class Expense: Object {
    
    @Persisted var category: Category.RawValue = ""
    @Persisted var value: Double = 0.0
    @Persisted var mileage: Int = 0
    @Persisted var volume: Double?
    @Persisted var date = Date()
    @Persisted var note: String = ""
    @Persisted var image: String?
    @Persisted var location: String?
    @Persisted(originProperty: "expenses") var car: LinkingObjects<Car>
    
    // also names of UImages for expenses in assets 
    enum Category: String, CaseIterable {
        case fuel = "Заправка"
        case parking = "Парковка"
        case wash = "Мойка"
        case credit = "Кредит"
        case fine = "Штрафы"
        case insurance = "Страховка"
        case maintenance = "Сервис"
        case tyres = "Шиномонтаж"
        case repair = "Ремонт"
        case tax = "Налоги"
        case toll = "Проезд"
        case other = "Прочее"
    }
    
}
