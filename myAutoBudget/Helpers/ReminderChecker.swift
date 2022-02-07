//
//  ReminderChecker.swift
//  myAutoBudget
//
//  Created by MacBook on 22.11.2021.
//

import Foundation
import RealmSwift
import UserNotifications
import UIKit

class ReminderChecker {
    
    static let shared = ReminderChecker()
    
    let realm = try! Realm()
    
    var lastMileage: Int?
    var car: Car!

    private init() {}
    
    func checkForReminders(on vc: UIViewController) {
        guard let tabBarController = vc.tabBarController as? MainTabBarController else { return }
        tabBarController.badgeCount = 0
        
        // check if last expense exists
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        if let car = appDelegate.car {
            self.car = car
        }
        
        let expenses = self.car.expenses
        if let lastExpense = expenses.last {
            lastMileage = lastExpense.mileage
        }
        
        var reminders: List<Reminder>!
        reminders = self.car.reminders
        
        for reminder in reminders {

            if reminder.isViewed { tabBarController.badgeCount += 1 }
            
            // check if reminder has mileage and if conditions are matched alert will be shown
            
            if let mileage = reminder.mileage,
               let mileageLast = self.lastMileage {
                
                let mileageDiff = mileage - mileageLast
                
                if mileageDiff <= 1000 && mileageDiff >= 0 {
                    if !reminder.isViewed {
                        // alert has been shown
                        try! realm.write { reminder.isViewed = true }
                        showAlertVC(on: vc, with: reminder, mileageDiff, nil)
                        tabBarController.badgeCount += 1
                        break
                    }
                } else if mileageDiff <= 1000 && mileageDiff < 0 {
                    if !reminder.isWasted {
                        if !reminder.isViewed {
                            // alert has been shown and wasted
                            try! realm.write {
                                reminder.isViewed = true
                                reminder.isWasted = true
                            }
                            tabBarController.badgeCount += 1
                        } else {
                            // alert has been wasted
                            try! realm.write { reminder.isWasted = true }
                        }
                        
                        showAlertVC(on: vc, with: reminder, mileageDiff, nil)
                        break
                    }
                }
            }
            
            // check if reminder has date and if conditions are matched alert will be shown
            
            if let date = reminder.date {
                let currentDate = Date()
                let dateDiff = currentDate.distance(to: date) / 86400 // distance to reminder's date in days
                
                if dateDiff <= 7 && dateDiff >= 0 {
                    if !reminder.isViewed {
                        // alert has been shown
                        try! realm.write { reminder.isViewed = true }
                        showAlertVC(on: vc, with: reminder, nil, dateDiff)
                        tabBarController.badgeCount += 1
                        break
                    }
                } else if dateDiff <= 7 && dateDiff < 0 {
                    if !reminder.isWasted {
                        if !reminder.isViewed {
                            // alert has been shown and wasted
                            try! realm.write {
                                reminder.isViewed = true
                                reminder.isWasted = true
                            }
                            tabBarController.badgeCount += 1
                        } else {
                            // alert has been wasted
                            try! realm.write { reminder.isWasted = true }
                        }
                        
                        showAlertVC(on: vc, with: reminder, nil, dateDiff)
                        break
                    }
                }
                
            }
        }

        UIApplication.shared.applicationIconBadgeNumber = tabBarController.badgeCount
    }
    
    func showAlertVC(on vc: UIViewController, with reminder: Reminder, _ mileageDiff: Int?, _ dateDiff: Double?) {
        
        let reminderTitle = reminder.title
        let body = reminder.body
        
        var alertTitle = ""
        
        if let mileageDiff = mileageDiff {
            if mileageDiff < 0 {
                alertTitle = "Внимание!\n\(reminderTitle)\nПробег превышен на \(abs(mileageDiff)) км"
            } else {
                alertTitle = "Осталось \(mileageDiff) км до \n\(reminderTitle)"
            }
        }
        
        if let dateDiff = dateDiff {
            if dateDiff < 0 {
                alertTitle = "Внимание!\n\(reminderTitle)\nПросрочено на \(abs(Int(dateDiff))) дн."
            } else {
                alertTitle = "Осталось \(Int(dateDiff)) дн. до \n\(reminderTitle)"
            }

        }
        
        let alertVC = UIAlertController(title: alertTitle, message: body, preferredStyle: .alert)
        
        let goToReminders = UIAlertAction(title: "Перейти к уведомлениям", style: .default, handler: { _ in
            vc.tabBarController?.selectedIndex = 2
        })
        
        let okAction = UIAlertAction(title: "Ок", style: .cancel) { [weak self] _ in
            self?.checkForReminders(on: vc)
        }
        
        alertVC.addAction(goToReminders)
        alertVC.addAction(okAction)
        
        vc.present(alertVC, animated: true, completion: nil)
    }

}
