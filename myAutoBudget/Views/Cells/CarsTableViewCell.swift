//
//  MenuTableViewCell.swift
//  myAutoBudget
//
//  Created by MacBook on 25.09.2021.
//

import UIKit

class CarsTableViewCell: UITableViewCell {

    @IBOutlet weak var carsCellImageView: UIImageView!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var chooseButton: UIButton!
    
    override func layoutSubviews() {
        let width = carsCellImageView.frame.width
        carsCellImageView.layer.cornerRadius = width / 2
        carsCellImageView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        carsCellImageView.image = UIImage()
    }
}
