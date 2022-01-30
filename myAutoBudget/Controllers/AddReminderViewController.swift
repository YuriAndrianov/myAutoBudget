//
//  AddReminderViewController.swift
//  myAutoBudget
//
//  Created by MacBook on 12.12.2021.
//

import UIKit
import RealmSwift

class AddReminderViewController: UIViewController {

    weak var delegate: AddReminderViewControllerDelegate?

    let realm = try! Realm()
    
    var reminderTitle = ""
    var reminderBody = ""
    var reminderMileage: Int?
    var reminderDate: Date?
    var reminderIsShown = false
    var reminderIsWasted = false
    var isEditingAllowed = true
    var reminderToBeEdited: Reminder?
    
    var allowEdit = true {
        didSet {
            if allowEdit == true {
                setupViewIfEditingAllowed()
            } else {
                setupViewIfEditingDidNotAllowed()
            }
        }
    }
    
    lazy var isMileageReminder = true {
        didSet {
            if isMileageReminder {
                mileageStackView.isHidden = false
                dateStackView.isHidden = true
            } else {
                mileageStackView.isHidden = true
                dateStackView.isHidden = false
            }
        }
    }
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextField: UITextField!
    @IBOutlet weak var mileageTextField: UITextField!
    @IBOutlet weak var mileageStackView: UIStackView!
    @IBOutlet weak var dateStackView: UIStackView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var switchStackView: UIStackView!
    @IBOutlet weak var switchReminder: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextFields()
        checkIfReminderToBeEdited()
        completeButton.isHidden = true
        allowEdit = isEditingAllowed
        switchReminder.isOn = false
    }
    
    private func configureTextFields() {
        titleTextField.becomeFirstResponder()
        titleTextField.delegate = self
        bodyTextField.delegate = self
        mileageTextField.delegate = self
        [titleTextField, bodyTextField, mileageTextField].forEach { createToolBar(textField: $0) }
    }
    
    private func checkIfReminderToBeEdited() {
        guard let reminderToBeEdited = self.reminderToBeEdited else {
            isMileageReminder = true
            return
        }
        
        titleTextField.text = reminderToBeEdited.title
        reminderTitle = reminderToBeEdited.title
        
        bodyTextField.text = reminderToBeEdited.body
        reminderBody = reminderToBeEdited.body
        
        reminderIsShown = reminderToBeEdited.isViewed
        reminderIsWasted = reminderToBeEdited.isWasted
        
        if let mileage = reminderToBeEdited.mileage {
            mileageTextField.text = "\(mileage)"
            reminderMileage = mileage
            isMileageReminder = true
            switchReminder.isOn = false
        }
        
        if let date = reminderToBeEdited.date {
            datePicker.date = date
            reminderDate = date
            isMileageReminder = false
            switchReminder.isOn = true
        }
    }
    
    private func createToolBar(textField: UITextField) {
        let doneToolbar = StyleSheet().createToolBar(selector: #selector(doneButtonAction))
        textField.inputAccessoryView = doneToolbar
    }
    
    private func setupViewIfEditingAllowed() {
        UIView.animate(withDuration: 0.3) {
            self.titleTextField.isEnabled = true
            self.bodyTextField.isEnabled = true
            self.mileageTextField.isEnabled = true
            self.saveButton.isHidden = false
            self.editButton.isHidden = true
            self.datePicker.isEnabled = true
            self.switchStackView.isHidden = false
            self.switchReminder.isOn = self.isMileageReminder ? false : true
        }
    }
    
    private func setupViewIfEditingDidNotAllowed() {
        UIView.animate(withDuration: 0.3) {
            self.titleTextField.isEnabled = false
            self.bodyTextField.isEnabled = false
            self.mileageTextField.isEnabled = false
            self.saveButton.isHidden = true
            self.editButton.isHidden = false
            self.datePicker.isEnabled = false
            self.switchStackView.isHidden = true
        }
    }
    
    private func addUserNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] success, error in
            guard let self = self else { return }
            if success, error == nil {
                let content = UNMutableNotificationContent()
                content.title = self.reminderTitle
                content.body = self.reminderBody
                content.sound = .default
                
                let triggerDate = self.reminderDate
                let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate!)
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                
                let request = UNNotificationRequest(identifier: "id\(content.title)", content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
        }
    }
    
    private func saveReminder() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        if let car = appDelegate.car {

            // Check if reminder to be edited exists, if true - update the previous record
            if let reminderToBeEdited = reminderToBeEdited {
                try! self.realm.write {
                    reminderToBeEdited.title = reminderTitle
                    reminderToBeEdited.body = reminderBody
                    reminderToBeEdited.mileage = reminderMileage
                    reminderToBeEdited.repeatingMileage = nil
                    reminderToBeEdited.date = reminderDate
                    reminderToBeEdited.isViewed = false
                    reminderToBeEdited.isWasted = false
                }
            } else {
                let reminder = Reminder(value: [reminderTitle, reminderBody, reminderMileage as Any, nil, reminderDate as Any, reminderIsShown, reminderIsWasted])

                try! realm.write {
                    car.reminders.append(reminder)
                    realm.add(reminder)
                }

                reminderToBeEdited = reminder
            }
        }

//        delegate?.updateTableView()

        allowEdit = false

        UIView.animate(withDuration: 0.3) {
            self.switchReminder.alpha = 0
            self.completeButton.isHidden = false
        }
        
        if switchReminder.isOn { addUserNotification() }
    }

    @objc private func doneButtonAction() {
        // Switching textfield when done button tapped
        if titleTextField.isFirstResponder {
            bodyTextField.becomeFirstResponder()
        } else if bodyTextField.isFirstResponder {
            mileageTextField.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        allowEdit = true
        UIView.animate(withDuration: 0.3) {
            self.completeButton.isHidden = true
            self.switchReminder.alpha = 1
        }
        titleTextField.becomeFirstResponder()
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        if sender.isOn {
            view.endEditing(true)
            reminderMileage = nil
            reminderDate = datePicker.date
            isMileageReminder = false
        } else {
            mileageTextField.becomeFirstResponder()
            reminderMileage = Int(mileageTextField.text ?? "0") ?? 0
            reminderDate = nil
            isMileageReminder = true
        }
    }
    
    @IBAction func titleEntered(_ sender: UITextField) {
        reminderTitle = sender.text ?? ""
    }
    
    @IBAction func bodyEntered(_ sender: UITextField) {
        reminderBody = sender.text ?? ""
    }
    
    @IBAction func mileageEntered(_ sender: UITextField) {
        reminderMileage = Int(sender.text ?? "0") ?? 0
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        reminderDate = sender.date
    }
    
    @IBAction func completeButtonTapped(_ sender: UIButton) {
        // Show main VC after reminder has been saved
        let vc = storyboard?.instantiateViewController(withIdentifier: "mainTabBarVC") as! MainTabBarController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
//        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        if reminderTitle == "" {
            // show alert with empty title
            showEmptyTitleAlert()
        } else if reminderBody == "" {
            // show alert with empty body
            showEmptyBodyAlert()
        } else if isMileageReminder && (reminderMileage == 0 || reminderMileage == nil) {
            // show alert with empty mileage
            showEmptyMileageAlert()
        } else if !isMileageReminder && reminderDate == nil {
            // show alert with empty date
            showEmptyMileageAlert()
        } else { saveReminder() }
    }
    
    // MARK: - Show alerts methods
    
    func showEmptyTitleAlert() {
        let alertVC = UIAlertController(title: "Ошибка", message: "Введите заголовок", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { [weak self]_ in
            alertVC.dismiss(animated: true)
            self?.titleTextField.becomeFirstResponder()
        }))
        present(alertVC, animated: true)
    }
    
    func showEmptyBodyAlert() {
        let alertVC = UIAlertController(title: "Ошибка", message: "Введите описание", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { [weak self]_ in
            alertVC.dismiss(animated: true)
            self?.bodyTextField.becomeFirstResponder()
        }))
        present(alertVC, animated: true)
    }
    
    func showEmptyMileageAlert() {
        let alertVC = UIAlertController(title: "Ошибка", message: "Введите пробег", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { [weak self]_ in
            alertVC.dismiss(animated: true)
            self?.mileageTextField.becomeFirstResponder()
        }))
        present(alertVC, animated: true)
    }
    
    func showEmptyDateAlert() {
        let alertVC = UIAlertController(title: "Ошибка", message: "Введите дату", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { [weak self]_ in
            alertVC.dismiss(animated: true)
            self?.datePicker.becomeFirstResponder()
        }))
        present(alertVC, animated: true)
    }
    
}

extension AddReminderViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == mileageTextField {
    
            // Not allow start typing with zero and separator
            if textField.text?.count == 0 && string == "0" { return false }
            
            // Only allow numbers. No Copy-Paste text values.
            let allowedCharacterSet = CharacterSet.init(charactersIn: "0123456789")
            let textCharacterSet = CharacterSet.init(charactersIn: textField.text! + string)
            if !allowedCharacterSet.isSuperset(of: textCharacterSet) { return false }
            
            // Limit count of entered values
            let currentText = textField.text ?? ""
            
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
     
            return updatedText.count <= 8
            
        } else { return true }
    }
    
}
