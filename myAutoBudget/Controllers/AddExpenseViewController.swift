//
//  AddExpenseViewController.swift
//  myAutoBudget
//
//  Created by MacBook on 30.10.2021.
//

import UIKit
import RealmSwift

class AddExpenseViewController: UIViewController {
    
    weak var delegate: AddExpenseViewControllerDelegate?
    
    let realm = try! Realm()
    let imageManager = ImageManager()
    
    var isEditingAllowed = true
    var expenseToBeEdited: Expense?
    var expenseValue = 0.0
    var expenseMileage = 0
    var volume: Double?
    var date = Date()
    var note = ""
    var startDateFromHistoryVC: Date?
    var endDateFromHistoryVC: Date?
    var imageName: String?
    var expenseTitle = ""
    
    var locationString: String? {
        didSet {
            if locationString != nil {
                locationButton.setTitle(locationString, for: .normal)
            } else {
                locationButton.setTitle("Определить", for: .normal)
            }
        }
    }
    
    var photo: UIImage? {
        didSet {
            if photo != nil {
                photoImage.image = photo
                addPhotoButton.setTitle("Удалить изображение...", for: .normal)
                addPhotoButton.setTitleColor(.systemRed, for: .normal)
                imageName = expenseTitle + "-\(date)"
            } else {
                photoImage.image = photo
                addPhotoButton.setTitle("Добавить изображение...", for: .normal)
                addPhotoButton.setTitleColor(.systemBlue, for: .normal)
                imageName = nil
            }
        }
    }
    
    var allowEdit = true {
        didSet {
            if allowEdit == true {
                setupViewIfEditingIsAllowed()
            } else {
                setupViewIfEditingIsNotAllowed()
            }
        }
    }
    
    @IBOutlet weak var chosenScrollView: UIScrollView!
    @IBOutlet weak var lastMileageLabel: UILabel!
    @IBOutlet weak var expenseTitleLabel: UILabel!
    @IBOutlet weak var expenseTextField: UITextField!
    @IBOutlet weak var mileageTextField: UITextField!
    @IBOutlet weak var volumeTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var volumeStackView: UIStackView!
    @IBOutlet weak var lastMileageStackView: UIStackView!
    @IBOutlet weak var noteStackView: UIStackView!
    @IBOutlet weak var locationStackView: UIStackView!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields()
        configureLabels()
        checkIfExpenseToBeEdited()
        completeButton.isHidden = true
        allowEdit = isEditingAllowed
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setupDependences(startDateFromHistoryVC: Date, endDateFromHistoryVC: Date, isEditingAllowed: Bool, expenseToBeEdited: Expense) {
        self.startDateFromHistoryVC = startDateFromHistoryVC
        self.endDateFromHistoryVC = endDateFromHistoryVC
        self.isEditingAllowed = isEditingAllowed
        self.expenseToBeEdited = expenseToBeEdited
    }
    
    private func setupViewIfEditingIsAllowed() {
        UIView.animate(withDuration: 0.3) {
            self.expenseTextField.isEnabled = true
            self.mileageTextField.isEnabled = true
            self.volumeTextField.isEnabled = true
            self.noteTextField.isEnabled = true
            self.datePicker.isEnabled = true
            self.addPhotoButton.isHidden = false
            self.saveButton.isHidden = false
            self.lastMileageStackView.isHidden = false
            self.noteStackView.isHidden = false
            self.locationStackView.isHidden = false
            self.editButton.isHidden = true
        }
    }
    
    private func setupViewIfEditingIsNotAllowed() {
        UIView.animate(withDuration: 0.3) {
            self.expenseTextField.isEnabled = false
            self.mileageTextField.isEnabled = false
            self.volumeTextField.isEnabled = false
            self.noteTextField.isEnabled = false
            self.datePicker.isEnabled = false
            self.addPhotoButton.isHidden = true
            self.saveButton.isHidden = true
            self.lastMileageStackView.isHidden = true
            self.noteStackView.isHidden = self.noteTextField.text == "" ? true : false
            self.locationStackView.isHidden = self.locationString == nil ? true : false
            self.editButton.isHidden = false
        }
    }
    
    @objc private func keyboardWillShow(_ notification:Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            chosenScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }
    
    @objc private func keyboardWillHide(_ notification:Notification) {
        chosenScrollView.contentInset = .zero
    }
    
    @objc private func doneButtonAction() {
        // Switching textfield when done button tapped
        if volumeStackView.isHidden {
            if expenseTextField.isFirstResponder {
                mileageTextField.becomeFirstResponder()
            } else {
                view.endEditing(true)
            }
        } else {
            if expenseTextField.isFirstResponder {
                mileageTextField.becomeFirstResponder()
            } else if mileageTextField.isFirstResponder {
                volumeTextField.becomeFirstResponder()
            } else {
                view.endEditing(true)
            }
        }
    }
    
    private func registerObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func checkIfExpenseToBeEdited() {
        guard let expenseToBeEdited = expenseToBeEdited else { return }
        
        datePicker.date = expenseToBeEdited.date
        date = expenseToBeEdited.date
        expenseTitle = expenseToBeEdited.category
        expenseTitleLabel.text = expenseTitle
        expenseTextField.text = String().withTwoFractionDigits(from: expenseToBeEdited.value)
        expenseValue = expenseToBeEdited.value
        mileageTextField.text = "\(expenseToBeEdited.mileage)"
        expenseMileage = expenseToBeEdited.mileage
        noteTextField.text = expenseToBeEdited.note
        note = expenseToBeEdited.note
        
        if let volume = expenseToBeEdited.volume {
            volumeStackView.isHidden = false
            volumeTextField.text = String().withTwoFractionDigits(from: volume)
            self.volume = volume
        }
        
        if let locationString = expenseToBeEdited.location {
            let string = locationString.components(separatedBy: "\n").first
            
            self.locationString = string
            locationButton.setTitle(string, for: .normal)
        }
        
        if let imageString = expenseToBeEdited.image {
            DispatchQueue.global(qos: .utility).async {
                let photo = self.imageManager.loadImageFromDiskWith(fileName: imageString)
                DispatchQueue.main.async {
                    self.photo = photo
                }
            }
        }
    }
    
    private func configureTextFields() {
        expenseTextField.becomeFirstResponder()
        volumeStackView.isHidden = (expenseTitle == "Заправка") ? false : true
        expenseTextField.delegate = self
        mileageTextField.delegate = self
        volumeTextField.delegate = self
        [expenseTextField, mileageTextField, volumeTextField].forEach { createToolBar(textField: $0) }
    }
    
    private func createToolBar(textField: UITextField) {
        let doneToolbar = StyleSheet().createToolBar(selector: #selector(doneButtonAction))
        textField.inputAccessoryView = doneToolbar
    }
    
    private func configureLabels() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        if let car = appDelegate.car {
            let expenses = car.expenses
            if let lastExpense = expenses.sorted(byKeyPath: "date", ascending: false).first {
                lastMileageLabel.text = "\(lastExpense.mileage) км"
            } else if let initialMileage = car.initialMileage {
                lastMileageLabel.text = "\(initialMileage) км"
            } else {
                lastMileageLabel.text = "0 км"
            }
        }
        expenseTitleLabel.text = expenseTitle
    }
    
    private func saveExpense() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        if let car = appDelegate.car {

            // Check if expense to be edited exists, if true - update the previous record
            if let expenseToBeEdited = expenseToBeEdited {
                try! self.realm.write {
                    expenseToBeEdited.category = expenseTitle
                    expenseToBeEdited.value = expenseValue
                    expenseToBeEdited.mileage = expenseMileage
                    expenseToBeEdited.volume = volume
                    expenseToBeEdited.date = date
                    expenseToBeEdited.note = note
                    expenseToBeEdited.image = imageName
                    expenseToBeEdited.location = locationString
                }
            } else {
                let expense = Expense(value: [expenseTitle, expenseValue, expenseMileage, volume as Any, date, note, imageName as Any, locationString as Any])

                try! realm.write {
                    car.expenses.append(expense)
                    realm.add(expense)
                }

                expenseToBeEdited = expense
            }
        }
        
        if let photo = self.photo {
            imageManager.saveImage(imageName: self.imageName!, image: photo)
        }
        
        if let startDateFromHistoryVC = startDateFromHistoryVC,
           let endDateFromHistoryVC = endDateFromHistoryVC {
            delegate?.updateTableView(from: startDateFromHistoryVC, to: endDateFromHistoryVC)
        }
        
        allowEdit = false
        UIView.animate(withDuration: 0.3) {
            self.completeButton.isHidden = false
        }
    }
    
    // MARK: - Methods showing alert VCs
    
    private func showAddPhotoAlertVC() {
        let alertVC = UIAlertController(title: "Выбрать фото...", message: nil, preferredStyle: .actionSheet)
        let cameraButton = UIAlertAction(title: "Камера", style: .default) { [weak self] _ in
            self?.showImagePicker(selectedSource: .camera)
        }
        
        let libraryButton = UIAlertAction(title: "Галерея", style: .default) { [weak self] _ in
            self?.showImagePicker(selectedSource: .photoLibrary)
        }
        
        let cancelButton = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alertVC.addAction(cameraButton)
        alertVC.addAction(libraryButton)
        alertVC.addAction(cancelButton)
        
        view.endEditing(true)
        present(alertVC, animated: true, completion: nil)
    }
    
    private func showDeletePhotoAlertVC() {
        let alertVC = UIAlertController(title: "Внимание!", message: "Вы действительно хотите удалить изображение?", preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Да", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.imageManager.deleteImage(imageName: (self.imageName)!)
            self.photo = nil
        }
        
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
        
        alertVC.addAction(confirmAction)
        alertVC.addAction(cancelAction)
        
        view.endEditing(true)
        present(alertVC, animated: true, completion: nil)
    }
    
    private func showZeroValueAlertVC() {
        let alertVC = UIAlertController(title: "Ошибка", message: "Введите сумму", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { [weak self]_ in
            alertVC.dismiss(animated: true)
            self?.expenseTextField.becomeFirstResponder()
        }))
        present(alertVC, animated: true)
    }
    
    private func showZeroMileageAlertVC() {
        let alertVC = UIAlertController(title: "Ошибка", message: "Введите значение пробега", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { [weak self]_ in
            alertVC.dismiss(animated: true)
            self?.mileageTextField.becomeFirstResponder()
        }))
        present(alertVC, animated: true)
    }
    
    private func showZeroVolumeAlertVC() {
        let alertVC = UIAlertController(title: "Ошибка", message: "Введите объем топлива", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { [weak self]_ in
            alertVC.dismiss(animated: true)
            self?.volumeTextField.becomeFirstResponder()
        }))
        present(alertVC, animated: true)
    }
    
    private func showLastMileageAlertVC() {
        let alertMessage = "Введеное значение пробега меньше ранее зарегистрированного! Продолжить?"
        let alertVC = UIAlertController(title: "Внимание!", message: alertMessage, preferredStyle: .actionSheet)
        
        alertVC.addAction(UIAlertAction(title: "Да",
                                        style: .destructive,
                                        handler: { [weak self] _ in
            self?.saveExpense()
        })
        )
        
        alertVC.addAction(UIAlertAction(title: "Нет",
                                        style: .cancel,
                                        handler: { [weak self] _ in
            self?.mileageTextField.becomeFirstResponder()
            alertVC.dismiss(animated: true, completion: nil)
        })
        )
        
        present(alertVC, animated: true, completion: nil)
    }
    
    private func showChangeLocationAlertVC(_ locationVC: LocationViewController) {
        let alertVC = UIAlertController(title: "Выберите действие", message: nil, preferredStyle: .actionSheet)
        
        let changeAction = UIAlertAction(title: "Обновить место", style: .default) { [weak self] _ in
            guard let self = self else { return }
            locationVC.editingAllowed = true
            locationVC.label.text = self.locationString
            self.present(locationVC, animated: true)
        }
        
        let deleteAction = UIAlertAction(title: "Удалить место", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.3) {
                self.locationString = nil
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alertVC.addAction(changeAction)
        alertVC.addAction(deleteAction)
        alertVC.addAction(cancelAction)
        
        present(alertVC, animated: true)
    }
    
    // MARK: - @IBActions
    
    @IBAction func saveExpenseButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        if let car = appDelegate.car {
            let expenses = car.expenses
            
            // Check if user has not entered the value
            if expenseValue == 0 {
                showZeroValueAlertVC()
                
                // Check if user has not entered the mileage
            } else if expenseMileage == 0 {
                showZeroMileageAlertVC()
                
                // Check if expense == заправка but user has not entered the volume
            } else if volumeStackView.isHidden == false && volume == nil {
                showZeroVolumeAlertVC()
            } else {
                
                // Check if user have entered the mileage less than the last record
                if let lastExpense = expenses.sorted(byKeyPath: "date", ascending: false).first {
                    if expenseMileage < lastExpense.mileage {
                        showLastMileageAlertVC()
                    } else { saveExpense() }
                } else { saveExpense() }
            }
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        if let startDateFromHistoryVC = startDateFromHistoryVC,
           let endDateFromHistoryVC = endDateFromHistoryVC {
            delegate?.updateTableView(from: startDateFromHistoryVC, to: endDateFromHistoryVC)
        }
        
        view.endEditing(true)
        dismiss(animated: true)
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        date = sender.date
    }
    
    @IBAction func expenseValueEntered(_ sender: UITextField) {
        expenseValue = sender.text?.doubleValue ?? 0.0
        view.endEditing(true)
    }
    
    @IBAction func mileageValueEntered(_ sender: UITextField) {
        expenseMileage = Int(sender.text ?? "0") ?? 0
        view.endEditing(true)
    }
    
    @IBAction func volumeEntered(_ sender: UITextField) {
        volume = sender.text?.doubleValue ?? nil
        view.endEditing(true)
    }
    
    @IBAction func noteEntered(_ sender: UITextField) {
        note = sender.text ?? ""
        view.endEditing(true)
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        allowEdit = true
        UIView.animate(withDuration: 0.3) {
            self.completeButton.isHidden = true
        }
        expenseTextField.becomeFirstResponder()
    }
    
    @IBAction func completeButtonTapped(_ sender: UIButton) {
        // Show main VC after expense has been saved
        let vc = storyboard?.instantiateViewController(withIdentifier: "mainTabBarVC") as! MainTabBarController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func addPhotoButtonTapped(_ sender: UIButton) {
        if sender.titleLabel!.text == "Добавить изображение..." {
            showAddPhotoAlertVC()
        } else {
            showDeletePhotoAlertVC()
        }
    }
    
    @IBAction private func locationTapped(_ sender: UIButton) {
        let locationVC = LocationViewController()
        locationVC.modalPresentationStyle = .automatic
        locationVC.delegate = self
        
        if allowEdit && locationString != nil {
            
            showChangeLocationAlertVC(locationVC)
            
        } else if allowEdit && locationString == nil {
            
            locationVC.editingAllowed = false
            present(locationVC, animated: true)
            
        } else if !allowEdit && locationString != nil {
            
            locationVC.editingAllowed = true
            locationVC.mapView.isUserInteractionEnabled = false
            locationVC.label.text = locationString
            locationVC.onlyMap = true
            present(locationVC, animated: true)
            
        }
    }
}

// MARK: - Delegates

extension AddExpenseViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Not allow start typing with zero and separator
        if textField.text?.count == 0 && string == "0" { return false }
        if textField.text?.count == 0 && (string == "," || string == ".") { return false }
        if (textField.text?.contains(","))! && string == "," { return false }
        if (textField.text?.contains("."))! && string == "." { return false }
        
        // Only allow numbers. No Copy-Paste text values.
        let allowedCharacterSet = CharacterSet.init(charactersIn: "0123456789,.")
        let textCharacterSet = CharacterSet.init(charactersIn: textField.text! + string)
        if !allowedCharacterSet.isSuperset(of: textCharacterSet) { return false }
        
        // Limit count of entered values
        let currentText = textField.text ?? ""
        
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if textField == volumeTextField {
            if updatedText.contains(",") || updatedText.contains(".") {
                return updatedText.count <= 6
            } else {
                return updatedText.count <= 3
            }
        }
        
        if updatedText.contains(",") || updatedText.contains(".") {
            return updatedText.count <= 11
        } else {
            return updatedText.count <= 8
        }
    }
    
}

extension AddExpenseViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showImagePicker(selectedSource: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(selectedSource) else { return }
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = selectedSource
        imagePickerController.allowsEditing = false
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            photo = selectedImage
        }
        picker.dismiss(animated: true)
    }
    
}

extension AddExpenseViewController: LocationViewControllerDelegate {
    
    func updateLocationString(with string: String) {
        self.locationString = string
    }
    
}
