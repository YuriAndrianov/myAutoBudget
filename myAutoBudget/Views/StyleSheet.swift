//
//  StyleSheet.swift
//  myAutoBudget
//
//  Created by MacBook on 08.10.2021.
//

import UIKit
import Charts

class StyleSheet {
    
    func createCloseButton(on view: UIView) -> UIButton {
        let closeButton = UIButton(type: .close)
        closeButton.tintColor = .label
        view.addSubview(closeButton)
        closeButton.frame = CGRect(x: 9, y: 9, width: 40, height: 40)
       
        return closeButton
    }
    
    func createToolBar(selector: Selector) -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace,
                                        target: nil,
                                        action: nil)
        let done = UIBarButtonItem(title: "Далее",
                                   style: UIBarButtonItem.Style.done,
                                   target: self,
                                   action: selector)
        toolbar.items = [flexSpace, done]
        
        return toolbar
    }
    
    func createCustomSegmentedControl(on view: UIView, buttons: inout [UIButton], selector: Selector) -> UIScrollView {
        let dateRangeScrollView = UIScrollView()
        let dateRangeButtonTitles = [
            "За неделю",
            "За месяц",
            "За год",
            "Всё время",
            "Выбрать период"
        ]
        dateRangeScrollView.translatesAutoresizingMaskIntoConstraints = false
        dateRangeScrollView.contentSize = CGSize(width: .zero, height: 40)
        dateRangeScrollView.backgroundColor = .systemBackground
        dateRangeScrollView.showsHorizontalScrollIndicator = false
        dateRangeButtonTitles.forEach { item in
            let button = UIButton().createCustomSegmentedControlButton(withTitle: item)
            buttons.append(button)
        }
        buttons.forEach { $0.addTarget(self, action: selector, for: .touchUpInside)
        }
        
        let segmentedButtonsStackView = UIStackView(arrangedSubviews: buttons)
        segmentedButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        segmentedButtonsStackView.axis = .horizontal
        segmentedButtonsStackView.distribution = .fillEqually
        segmentedButtonsStackView.spacing = 3
        
        dateRangeScrollView.addSubview(segmentedButtonsStackView)
        view.addSubview(dateRangeScrollView)
        
        NSLayoutConstraint.activate([
            dateRangeScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dateRangeScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dateRangeScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            dateRangeScrollView.heightAnchor.constraint(equalToConstant: 35),
            
            segmentedButtonsStackView.leadingAnchor.constraint(equalTo: dateRangeScrollView.leadingAnchor),
            segmentedButtonsStackView.trailingAnchor.constraint(equalTo: dateRangeScrollView.trailingAnchor),
            segmentedButtonsStackView.topAnchor.constraint(equalTo: dateRangeScrollView.topAnchor, constant: 1),
            segmentedButtonsStackView.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        return dateRangeScrollView
    }
    
    func createDateRangeLabel(on view: UIView, constant: CGFloat = 55) -> UILabel {
        let dateRangeLabel = PaddingLabel()
        dateRangeLabel.textAlignment = .center
        dateRangeLabel.font = UIFont.systemFont(ofSize: 15)
        dateRangeLabel.textColor = .label
        dateRangeLabel.backgroundColor = .systemGray4
        dateRangeLabel.layer.masksToBounds = true
        dateRangeLabel.layer.cornerRadius = 8
        dateRangeLabel.layer.borderColor = UIColor.darkGray.cgColor
        dateRangeLabel.layer.borderWidth = 0.3
        dateRangeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dateRangeLabel)
        
        NSLayoutConstraint.activate([
            dateRangeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dateRangeLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: constant),
            dateRangeLabel.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        return dateRangeLabel
    }
}
