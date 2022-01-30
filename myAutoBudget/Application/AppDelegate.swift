//
//  AppDelegate.swift
//  myAutoBudget
//
//  Created by MacBook on 25.09.2021.
//

import UIKit
import Firebase
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var car: Car?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        if let chosenCarName = UserDefaults.standard.string(forKey: "chosenCar") {
            let realm = try! Realm()
            if let chosenCar = realm.object(ofType: Car.self, forPrimaryKey: chosenCarName) {
                self.car = chosenCar
            }
        }

        RealmBackUpManager().uploadDatabaseToCloudDrive()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {

        return UIInterfaceOrientationMask(rawValue: UIInterfaceOrientationMask.portrait.rawValue)
    }

}
