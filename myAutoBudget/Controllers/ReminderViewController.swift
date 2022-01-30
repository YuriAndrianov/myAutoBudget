//
//  ReminderViewController.swift
//  myAutoBudget
//
//  Created by MacBook on 06.12.2021.
//

import UIKit
import RealmSwift

class ReminderViewController: UIViewController {
    
    let realm = try! Realm()
    let reminderTableView = UITableView()
    let emptyStackView = UIStackView()
    
    var reminders: List<Reminder>!
    var lastMileage: Int?
    var car: Car!

    @IBOutlet weak var carNameBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fixTabBarBug()
        checkForLastExpense()
        configuretableView()
        configureEmptyDataView()
        setConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reminders = car.reminders.sorted(byKeyPath: "isViewed", ascending: false).list
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reminderTableView.reloadData()
//        ReminderChecker.shared.checkForReminders(on: self)
    }

    private func checkForLastExpense() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        if let car = appDelegate.car {
            carNameBarButton.title = car.brand + " " + car.model
            self.car = car
        }

        let expenses = self.car.expenses
        if let lastExpense = expenses.last {
            lastMileage = lastExpense.mileage
        }
    }

    private func fixTabBarBug() {
        // fixing bug with tabbar layer
        self.tabBarController?.tabBar.backgroundImage = UIImage()
        self.tabBarController?.tabBar.shadowImage = UIImage()
    }
    
    private func configureEmptyDataView() {
        let emptyLabel = UILabel()
        emptyLabel.text = "Нет напоминаний\n\nНажмите \"+\" в верхней части экрана,\nчтобы добавить напоминание."
        emptyLabel.textColor = .darkGray
        emptyLabel.textAlignment = .center
        emptyLabel.font = UIFont.systemFont(ofSize: 16)
        emptyLabel.numberOfLines = 0
        
        let emptyImage = UIImageView()
        emptyImage.image = UIImage(named: "emptyReminder")
        emptyImage.contentMode = .scaleAspectFit
        
        emptyStackView.addArrangedSubview(emptyImage)
        emptyStackView.addArrangedSubview(emptyLabel)
        emptyStackView.axis = .vertical
        emptyStackView.alignment = .center
        emptyStackView.distribution = .fillProportionally
        emptyStackView.spacing = 5
        emptyStackView.translatesAutoresizingMaskIntoConstraints = false
        reminderTableView.addSubview(emptyStackView)
    }

    private func configuretableView() {
        reminderTableView.delegate = self
        reminderTableView.dataSource = self
        reminderTableView.backgroundView = emptyStackView
        reminderTableView.register(UINib(nibName: "ReminderTableViewCell", bundle: .main), forCellReuseIdentifier: ReminderTableViewCell.id)
        reminderTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(reminderTableView)
    }
    
    private func showChosenReminderVC(selectedReminder: Reminder?, isEditingAllowed: Bool) {
        
        guard let chosenReminderVC = storyboard?.instantiateViewController(withIdentifier: "addReminder") as? AddReminderViewController else { return }

        chosenReminderVC.delegate = self
        chosenReminderVC.reminderToBeEdited = selectedReminder == nil ? nil : selectedReminder
        chosenReminderVC.isEditingAllowed = isEditingAllowed
        
        if let presentationVC = chosenReminderVC.presentationController as? UISheetPresentationController {
            presentationVC.detents = [.large()]
            presentationVC.preferredCornerRadius = 25
            
            present(chosenReminderVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        showChosenReminderVC(selectedReminder: nil, isEditingAllowed: true)
    }

    @IBAction func carNameBarButtonTapped(_ sender: UIBarButtonItem) {
        let carsVC = CarsViewController()
        carsVC.title = "Мой гараж"
        navigationController?.pushViewController(carsVC, animated: true)
    }

    private func setConstraints() {
        NSLayoutConstraint.activate([
            emptyStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStackView.topAnchor.constraint(equalTo: reminderTableView.topAnchor, constant: 50),
            emptyStackView.widthAnchor.constraint(equalTo: view.widthAnchor),
            emptyStackView.heightAnchor.constraint(equalToConstant: 300)
        ])

        NSLayoutConstraint.activate([
            reminderTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            reminderTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            reminderTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            reminderTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

}

// MARK: - Delegates

extension ReminderViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if reminders.isEmpty {
            emptyStackView.isHidden = false
        } else {
            emptyStackView.isHidden = true
        }
        
        return reminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = reminderTableView.dequeueReusableCell(withIdentifier: ReminderTableViewCell.id, for: indexPath) as? ReminderTableViewCell else { return UITableViewCell() }
        
        let reminder = reminders[indexPath.row]
        
        cell.titleLabel.text = reminder.title
        cell.leftLabel.textColor = .label
        
        if reminder.isViewed {
            cell.contentView.backgroundColor = UIColor(named: "Заправка") // yellow
        }
        
        if reminder.isWasted {
            cell.contentView.backgroundColor =  UIColor(named: "Ремонт") // red
        }
        
        if let mileage = reminder.mileage {
            cell.mileageLabel.text = "Пробег: \(mileage) км"
            
            if let lastMileage = self.lastMileage {
                let mileageDiff = mileage - lastMileage
                
                cell.leftLabel.text = mileageDiff < 0 ? "\(abs(mileageDiff)) км назад" : "Через \(mileageDiff) км"
            }
            
        } else { cell.mileageLabel.isHidden = true }
        
        if let date = reminder.date {
            let dateString = DateProvider().getStringFrom(date: date, format: .ddMMyyyyHHmm)
            cell.dateLabel.text = "Дата: " + dateString
            
            let currentDayStart = Date().getCurrentDayStart()
            
            let dateDiff = currentDayStart.distance(to: date) / 86400// distance to reminder's date in days

            switch dateDiff {
            case -1..<0: cell.leftLabel.text = "Вчера"
            case 0..<1: cell.leftLabel.text = "Сегодня"
            case 1..<2: cell.leftLabel.text = "Завтра"
            default: cell.leftLabel.text = dateDiff < 0 ?
                "\(abs(Int(dateDiff)) + 1) дн. назад" : "Через \(abs(Int(dateDiff))) дн."
            }
            
        } else { cell.dateLabel.isHidden = true }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = deleteAction(indexPath: indexPath)
        let editAction = editAction(indexPath: indexPath)
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    private func deleteAction(indexPath: IndexPath) -> UIContextualAction {
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Удалить",
                                              handler: {[weak self] _, _, complete in
            guard let self = self else { return }
            
            let reminderToBeDeleted = self.reminders[indexPath.row]
            
            let alertMessage = "Вы действительно хотите удалить напоминание?"
            
            let alertVC = UIAlertController(title: "Внимание!", message: alertMessage, preferredStyle: .actionSheet)
            
            alertVC.addAction(UIAlertAction(title: "Да", style: .destructive, handler: { _ in
                
                guard let tabBarController = self.tabBarController as? MainTabBarController else { return }
                
                if reminderToBeDeleted.isViewed && tabBarController.badgeCount != 0 {
                    tabBarController.badgeCount -= 1
                }
               
                try! self.realm.write { self.realm.delete(reminderToBeDeleted) }
                
                self.reminders.remove(at: indexPath.row)
                self.reminderTableView.deleteRows(at: [indexPath], with: .automatic)

                ReminderChecker.shared.checkForReminders(on: self)
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
            let reminderToBeEdited = self.reminders[indexPath.row]
            self.showChosenReminderVC(selectedReminder: reminderToBeEdited, isEditingAllowed: true)
            complete(true)
        })
        
        return editAction
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedReminder = reminders[indexPath.row]
        showChosenReminderVC(selectedReminder: selectedReminder, isEditingAllowed: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
}

extension ReminderViewController: AddReminderViewControllerDelegate {

    func updateTableView() {
        reminders = car.reminders.sorted(byKeyPath: "isViewed", ascending: false).list
        reminderTableView.reloadData()
    }

}
