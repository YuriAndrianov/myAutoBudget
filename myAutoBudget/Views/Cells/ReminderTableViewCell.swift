//
//  ReminderTableViewCell.swift
//  myAutoBudget
//
//  Created by MacBook on 12.12.2021.
//

import UIKit

class ReminderTableViewCell: UITableViewCell {
    
    static let id = "reminderCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mileageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var leftLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layer.cornerRadius = 8
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        mileageLabel.isHidden = false
        dateLabel.isHidden = false
        contentView.backgroundColor = .systemBackground
    }
    
}
