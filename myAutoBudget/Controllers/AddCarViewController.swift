//
//  AddCarViewController.swift
//  myAutoBudget
//
//  Created by MacBook on 23.12.2021.
//

import UIKit
import RealmSwift

class AddCarViewController: UIViewController {
    
    weak var delegate: AddCarViewControllerDelegate?
    
    let realm = try! Realm()
    let imageManager = ImageManager()
    
    var carId = ""
    var carBrand = ""
    var carModel = ""
    var carCurrentMileage: Int?
    var imageName: String?
    var expenses = List<Expense>()
    var reminders = List<Reminder>()
    
    var isEditingAllowed = true
    var carToBeEdited: Car?
    
    var photo: UIImage? {
        didSet {
            if photo != nil {
                photoImage.image = photo
                addPhotoButton.setTitle("Удалить изображение...", for: .normal)
                addPhotoButton.setTitleColor(.systemRed, for: .normal)
                imageName = carBrand + carModel + "-\(Date())"
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
                setupViewIfEditingAllowed()
            } else {
                setupViewIfEditingDidNotAllowed()
            }
        }
    }

    @IBOutlet weak var brandTextField: UITextField!
    @IBOutlet weak var modelTextField: UITextField!
    @IBOutlet weak var currentMileageTextField: UITextField!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextFields()
        checkIfCarToBeEdited()
        completeButton.isHidden = true
        allowEdit = isEditingAllowed
    }
    
    private func configureTextFields() {
        brandTextField.becomeFirstResponder()
        modelTextField.delegate = self
        currentMileageTextField.delegate = self
        [brandTextField, modelTextField, currentMileageTextField].forEach { createToolBar(textField: $0) }
    }
    
    private func createToolBar(textField: UITextField) {
        let doneToolbar = StyleSheet().createToolBar(selector: #selector(doneButtonAction))
        textField.inputAccessoryView = doneToolbar
    }
    
    private func checkIfCarToBeEdited() {
        guard let carToBeEdited = self.carToBeEdited else { return }

        carBrand = carToBeEdited.brand
        brandTextField.text = carToBeEdited.brand
        carModel = carToBeEdited.model
        modelTextField.text = carToBeEdited.model
        
        if let initialMileage = carToBeEdited.initialMileage {
            currentMileageTextField.text = "\(initialMileage)"
            carCurrentMileage = initialMileage
        }
        
        if let imageString = carToBeEdited.imageName {
            DispatchQueue.global(qos: .utility).async {
                let photo = self.imageManager.loadImageFromDiskWith(fileName: imageString)
                DispatchQueue.main.async {
                    self.photo = photo
                }
            }
        }
        
        expenses = carToBeEdited.expenses
        reminders = carToBeEdited.reminders
    }
    
    @objc private func doneButtonAction() {
        // Switching textfield when done button tapped
        if brandTextField.isFirstResponder {
            modelTextField.becomeFirstResponder()
        } else if modelTextField.isFirstResponder {
            currentMileageTextField.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
    }
    
    @IBAction func saveButtonTapped() {
        view.endEditing(true)

        if carBrand == "" {
            showCarBrandAlert()
        } else if carModel == "" {
            showCarModelAlert()
        } else { saveCar() }
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        allowEdit = true
        UIView.animate(withDuration: 0.3) {
            self.completeButton.isHidden = true
        }
        brandTextField.becomeFirstResponder()
    }
    
    @IBAction func addPhotoButtonTapped(_ sender: UIButton) {
        if sender.titleLabel!.text == "Добавить изображение..." {
            showAddPhotoAlertVC()
        } else {
            showDeletePhotoAlertVC()
        }
    }
    
    @IBAction func brandEntered(_ sender: UITextField) {
        carBrand = sender.text ?? ""
        view.endEditing(true)
    }
    
    @IBAction func modelEntered(_ sender: UITextField) {
        carModel = sender.text ?? ""
        view.endEditing(true)
    }

    @IBAction func mileageValueEntered(_ sender: UITextField) {
        carCurrentMileage = Int(sender.text ?? "0") ?? 0
        view.endEditing(true)
    }
    
    @IBAction func completeButtonTapped(_ sender: UIButton) {
//        dismiss(animated: true, completion: nil)
        let carsVC = CarsViewController()
        carsVC.title = "Мой гараж"
        carsVC.isFirstStart = true

        let navVC = UINavigationController(rootViewController: carsVC)
        navVC.modalPresentationStyle = .fullScreen
        navVC.modalTransitionStyle = .crossDissolve
        navVC.navigationBar.prefersLargeTitles = true
        self.present(navVC, animated: true)
    }
    
    private func saveCar() {

        if let carToBeEdited = self.carToBeEdited {
            try! realm.write {
                carToBeEdited.brand = carBrand
                carToBeEdited.model = carModel
                carToBeEdited.initialMileage = carCurrentMileage ?? 0
                carToBeEdited.imageName = imageName ?? nil
                carToBeEdited.expenses = expenses
                carToBeEdited.reminders = reminders
            }
        } else {
            carId = "\(carBrand)-\(Date())"

            let car = Car(value: [carId, carBrand, carModel, carCurrentMileage as Any, imageName as Any, expenses, reminders])

            try! realm.write {
                realm.add(car)
            }

            carToBeEdited = car
        }

        if let photo = self.photo {
            imageManager.saveImage(imageName: self.imageName!, image: photo)
        }

        delegate?.updateMenuTableView()
        
        allowEdit = false
        UIView.animate(withDuration: 0.3) {
            self.completeButton.isHidden = false
        }
    }
    
    private func setupViewIfEditingAllowed() {
        UIView.animate(withDuration: 0.3) {
            self.brandTextField.isEnabled = true
            self.modelTextField.isEnabled = true
            self.currentMileageTextField.isEnabled = true
            self.saveButton.isHidden = false
            self.editButton.isHidden = true
            self.addPhotoButton.isHidden = false
        }
    }
    
    private func setupViewIfEditingDidNotAllowed() {
        UIView.animate(withDuration: 0.3) {
            self.brandTextField.isEnabled = false
            self.modelTextField.isEnabled = false
            self.currentMileageTextField.isEnabled = false
            self.saveButton.isHidden = true
            self.editButton.isHidden = false
            self.addPhotoButton.isHidden = true
        }
    }
    
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
    
    private func showCarBrandAlert() {
        let alertVC = UIAlertController(title: "Ошибка", message: "Введите марку автомобиля", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { [weak self]_ in
            alertVC.dismiss(animated: true)
            self?.brandTextField.becomeFirstResponder()
        }))
        present(alertVC, animated: true)
    }
    
    private func showCarModelAlert() {
        let alertVC = UIAlertController(title: "Ошибка", message: "Введите модель автомобиля", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { [weak self]_ in
            alertVC.dismiss(animated: true)
            self?.modelTextField.becomeFirstResponder()
        }))
        present(alertVC, animated: true)
    }
   
}

extension AddCarViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == currentMileageTextField {
    
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

extension AddCarViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
