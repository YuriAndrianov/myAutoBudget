//
//  CollectionViewCell.swift
//  myAutoBudget
//
//  Created by MacBook on 26.09.2021.
//

import UIKit

class ExpenseCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var expenseImageView: UIImageView!
    @IBOutlet weak var expenseLabel: UILabel!
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.systemGray2 : UIColor.systemBackground
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 10
    }

}
