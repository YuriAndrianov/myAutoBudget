//
//  DateViewController.swift
//  myAutoBudget
//
//  Created by MacBook on 06.10.2021.
//

import UIKit

class DateViewController: UIViewController {
    
    weak var delegate: DateViewControllerDelegate?
    
    let dateProvider = DateProvider()
    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    
    var startDate = Date()
    var endDate = Date()
    
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        createDatePicker()
        configureSaveButton()
    }

    private func configureView() {
        view.backgroundColor = .systemBackground
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(doneButtonPressed)))

        let closeButton = StyleSheet().createCloseButton(on: view)
        closeButton.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)

        startDateTextField.text = dateProvider.getStringFrom(date: startDate, format: .ddMMyyyy)
        endDateTextField.text = dateProvider.getStringFrom(date: endDate, format: .ddMMyyyy)

        startDatePicker.date = startDate
        endDatePicker.date = endDate
    }
    
    @objc func closeButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        dismiss(animated: true)
    }
    
    private func configureSaveButton() {
        let saveButton = UIButton()
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.setTitleColor(.darkGray, for: .normal)
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        saveButton.backgroundColor = UIColor(named: "aqua")
        saveButton.layer.cornerRadius = 8
        saveButton.addTarget(self, action: #selector(saveButtonTapped(_:)), for: .touchUpInside)
        
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            saveButton.leadingAnchor.constraint(equalTo: startDateTextField.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: endDateTextField.trailingAnchor),
            saveButton.topAnchor.constraint(equalTo: startDateTextField.bottomAnchor, constant: 60),
            saveButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc func saveButtonTapped(_ sender: UIButton) {
        
        if startDatePicker.date > endDatePicker.date {
            
            let alertVC = UIAlertController(title: "Ошибка", message: "Начальная дата не может быть больше конечной!", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { [weak self]_ in
                alertVC.dismiss(animated: true)
                self?.startDateTextField.becomeFirstResponder()
            }))
            present(alertVC, animated: true)
            
        } else {
            startDate = dateProvider.getDate(from: startDatePicker.date, component: .day, difference: 0).start
            endDate = dateProvider.getDate(from: endDatePicker.date, component: .day, difference: 0).end
            delegate?.updateDates(startDate: startDate, endDate: endDate)
            
            dismiss(animated: true)
        }
    }
    
    func createToolBar() -> UIToolbar {
        let toolBar = StyleSheet().createToolBar(selector: #selector(doneButtonPressed))
        return toolBar
    }
    
    func createDatePicker() {
        startDatePicker.preferredDatePickerStyle = .wheels
        endDatePicker.preferredDatePickerStyle = .wheels
        
        startDatePicker.datePickerMode = .date
        endDatePicker.datePickerMode = .date
        
        startDateTextField.inputView = startDatePicker
        endDateTextField.inputView = endDatePicker
        
        startDateTextField.inputAccessoryView = createToolBar()
        endDateTextField.inputAccessoryView = createToolBar()
    }
    
    @objc func doneButtonPressed() {
        startDate = startDatePicker.date
        endDate = endDatePicker.date
        
        startDateTextField.text = dateProvider.getStringFrom(date: startDate, format: .ddMMyyyy)
        endDateTextField.text = dateProvider.getStringFrom(date: endDate, format: .ddMMyyyy)
        view.endEditing(true)
    }
    
}
