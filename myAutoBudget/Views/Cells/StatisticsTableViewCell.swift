//
//  StatisticsTableViewCell.swift
//  myAutoBudget
//
//  Created by MacBook on 16.10.2021.
//

import UIKit

class StatisticsTableViewCell: UITableViewCell {
    
    static let id = "statisticsCell"

    @IBOutlet weak var statisticsImageView: UIImageView!
    @IBOutlet weak var expenseTitle: UILabel!
    @IBOutlet weak var expenseValue: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    
    var tempExpenseValue: Double = 0.0 {
        didSet {
            self.expenseValue.text = String.localizedStringWithFormat("%.2f руб", tempExpenseValue)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.accessoryView = .none
    }
}
