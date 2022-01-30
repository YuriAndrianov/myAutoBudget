//
//  MainTabBarController.swift
//  myAutoBudget
//
//  Created by MacBook on 25.09.2021.
//

import UIKit
import RealmSwift

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private let centerButton = UIButton()
    
    lazy var badgeCount: Int = 0 {
        didSet {
            if badgeCount != 0 {
                self.tabBar.items![2].badgeValue = "\(badgeCount)"
            } else {
                self.tabBar.items![2].badgeValue = nil
                self.tabBar.items![2].badgeColor = nil
            }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setupCenterButton()
    }
    
    private func setupCenterButton() {
        guard let mainTabBar = self.tabBar as? MainTabBar else { return }
        
        mainTabBar.centerButton.addTarget(self, action: #selector(self.centerButtonTapped), for: .touchUpInside)
    }
    
    @objc private func centerButtonTapped(sender: UIButton) {
        let expenseVC = storyboard?.instantiateViewController(withIdentifier: "ExpenseVC") as! ExpenseViewController
        
        if let presentationVC = expenseVC.presentationController as? UISheetPresentationController {
            presentationVC.detents = [.medium()]
            presentationVC.preferredCornerRadius = 25
            
            present(expenseVC, animated: true, completion: nil)
        }
    }
    
}
