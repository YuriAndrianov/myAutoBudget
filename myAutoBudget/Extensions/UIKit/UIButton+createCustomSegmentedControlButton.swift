//
//  UIButton+createCustomSegmentedControlButton.swift
//  myAutoBudget
//
//  Created by MacBook on 03.10.2021.
//

import UIKit

extension UIButton {
    func createCustomSegmentedControlButton(withTitle title: String) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.widthAnchor.constraint(greaterThanOrEqualToConstant: 130).isActive = true
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 8
        return button
    }
}
