//
//  HistoryTableViewCell.swift
//  myAutoBudget
//
//  Created by MacBook on 01.10.2021.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    static let id = "historyCell"

    @IBOutlet weak var historyCellImageView: UIImageView!
    @IBOutlet weak var historyCellCategoryLabel: UILabel!
    @IBOutlet weak var historyCellValueLabel: UILabel!
    @IBOutlet weak var historyCellMileageLabel: UILabel!
    @IBOutlet weak var historyCellDateLabel: UILabel!
    @IBOutlet weak var historyVolumeLabel: UILabel!
    @IBOutlet weak var historyReceiptImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    
    var tempExpenseValue: Double = 0.0 {
        didSet {
            self.historyCellValueLabel.text = String.localizedStringWithFormat("%.2f руб", tempExpenseValue)
        }
    }
    
}
