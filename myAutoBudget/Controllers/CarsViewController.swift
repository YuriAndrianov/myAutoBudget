//
//  CarsViewController.swift
//  myAutoBudget
//
//  Created by MacBook on 31.12.2021.
//

import UIKit
import RealmSwift

class CarsViewController: UITableViewController {
    
    static let carsCellId = "carCell"
    
    let realm = try! Realm()
    let imageManager = ImageManager()
    let emptyStackView = UIStackView()
    
    let addButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(named: "plus")
        return button
    }()
    
    var backButton = UIBarButtonItem()
    var cars: Results<Car>!
    var isFirstStart = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isFirstStart {
            backButton = UIBarButtonItem.init(title: nil, style: .plain, target: self, action: #selector(goBack(_:)))
            backButton.image = UIImage(systemName: "chevron.backward.circle.fill")
            backButton.tintColor = UIColor(named: "aqua")
            self.navigationItem.leftBarButtonItem = backButton
        }
        
        addButton.target = self
        addButton.action = #selector(addButtonTapped(_:))
        navigationItem.rightBarButtonItem = addButton
        
        tableView.register(UINib(nibName: "CarsTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: Self.carsCellId)
        tableView.delegate = self
        
        cars = realm.objects(Car.self)

        configureEmptyDataView()
    }
    
    @objc private func addButtonTapped(_ sender: UIBarButtonItem) {
        showAddCarVC(selectedCar: nil, isEditingAllowed: true)
    }
    
    @objc private func goBack(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func chooseButtonTapped(_ sender: UIButton) {
        let section = 0
        let row = sender.tag
        let indexPath = IndexPath(row: row, section: section)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let car = cars[indexPath.row]
        appDelegate.car = car
        
        UserDefaults.standard.set(car.id, forKey: "chosenCar")
        
        // Show main VC after car has been chosen
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "mainTabBarVC") as? MainTabBarController else { return }
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if cars.isEmpty {
            emptyStackView.isHidden = false
        } else {
            emptyStackView.isHidden = true
        }

        return cars.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Self.carsCellId, for: indexPath) as? CarsTableViewCell else { return UITableViewCell() }
        
        let car = cars[indexPath.row]
        
        if let carImage = car.imageName {
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async { [weak self] in
                    cell.carsCellImageView.image = self?.imageManager.loadImageFromDiskWith(fileName: carImage)
                }
            }
        }
        
        cell.brandLabel.text = car.brand
        cell.modelLabel.text = car.model
        cell.chooseButton.addTarget(self, action: #selector(chooseButtonTapped(_:)), for: .touchUpInside)
        cell.chooseButton.tag = indexPath.row
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCar = cars[indexPath.row]
        showAddCarVC(selectedCar: selectedCar, isEditingAllowed: false)
        
    }
    
    private func showAddCarVC(selectedCar: Car?, isEditingAllowed: Bool) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let addCarVC = storyboard.instantiateViewController(withIdentifier: "addCarVC") as? AddCarViewController else { return }
        addCarVC.delegate = self
        addCarVC.carToBeEdited = selectedCar == nil ? nil : selectedCar
        addCarVC.isEditingAllowed = isEditingAllowed
        
        if let presentationVC = addCarVC.presentationController as? UISheetPresentationController {
            presentationVC.detents = [.large()]
            presentationVC.preferredCornerRadius = 25
            
            present(addCarVC, animated: true, completion: nil)
        }
    }

    private func configureEmptyDataView() {
        let emptyLabel = UILabel()
        emptyLabel.text = "Нет транспортных средств\n\nНажмите \"+\" в верхней части экрана,\nчтобы добавить транспортное средство."
        emptyLabel.textColor = .darkGray
        emptyLabel.textAlignment = .center
        emptyLabel.font = UIFont.systemFont(ofSize: 16)
        emptyLabel.numberOfLines = 0

        let emptyImage = UIImageView()
        emptyImage.image = UIImage(named: "emptyCar")
        emptyImage.contentMode = .scaleAspectFit

        emptyStackView.addArrangedSubview(emptyImage)
        emptyStackView.addArrangedSubview(emptyLabel)
        emptyStackView.axis = .vertical
        emptyStackView.alignment = .center
        emptyStackView.distribution = .fillProportionally
        emptyStackView.spacing = 5
        emptyStackView.translatesAutoresizingMaskIntoConstraints = false
        tableView.addSubview(emptyStackView)

        NSLayoutConstraint.activate([
            emptyStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStackView.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 50),
            emptyStackView.widthAnchor.constraint(equalTo: view.widthAnchor),
            emptyStackView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = deleteAction(indexPath: indexPath)
        let editAction = editAction(indexPath: indexPath)
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    private func deleteAction(indexPath: IndexPath) -> UIContextualAction {
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Удалить",
                                              handler: {[weak self] _, _, complete in
            guard let self = self else { return }
            
            let carToBeDeleted = self.cars[indexPath.row]
            
            let alertMessage = "Вы действительно хотите удалить транспортное средство?"
            
            let alertVC = UIAlertController(title: "Внимание!", message: alertMessage, preferredStyle: .actionSheet)
            
            alertVC.addAction(UIAlertAction(title: "Да", style: .destructive, handler: { [weak self] _ in
                guard let self = self else { return }
                
                try! self.realm.write {
                    self.realm.delete(carToBeDeleted.reminders)
                    self.realm.delete(carToBeDeleted.expenses)
                    self.realm.delete(carToBeDeleted)
                }
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
//                self.backButton.isEnabled = false

                let carsVC = CarsViewController()
                carsVC.title = "Мой гараж"
                carsVC.isFirstStart = true

                let navVC = UINavigationController(rootViewController: carsVC)
                navVC.modalPresentationStyle = .fullScreen
                navVC.modalTransitionStyle = .crossDissolve
                navVC.navigationBar.prefersLargeTitles = true
                self.present(navVC, animated: true)
            }))
            
            alertVC.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: nil))
            
            self.present(alertVC, animated: true, completion: nil)
            complete(true)
        })
        return deleteAction
    }
    
    private func editAction(indexPath: IndexPath) -> UIContextualAction {
        let editAction = UIContextualAction(style: .normal,
                                            title: "Редактировать",
                                            handler: { [weak self] _, _, complete in
            guard let self = self else { return }
            let carToBeEdited = self.cars[indexPath.row]
            self.showAddCarVC(selectedCar: carToBeEdited, isEditingAllowed: true)
            complete(true)
        })
        
        return editAction
    }
    
}

extension CarsViewController: AddCarViewControllerDelegate {
    
    func updateMenuTableView() {
        self.tableView.reloadData()
        self.backButton.isEnabled = false
    }
    
}
