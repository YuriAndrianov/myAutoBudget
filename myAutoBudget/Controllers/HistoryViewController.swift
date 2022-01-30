//
//  HistoryViewController.swift
//  myAutoBudget
//
//  Created by MacBook on 01.10.2021.
//

import UIKit
import RealmSwift

class HistoryViewController: UIViewController, AddExpenseViewControllerDelegate {

    let realm = try! Realm()
    let historyTableView = UITableView()
    let emptyStackView = UIStackView()
    let dateProvider = DateProvider()
    let imageManager = ImageManager()
    
    var expenses: List<Expense>!
    var seguefromStatisticsVC = false
    var expensesGroupedByDate = [[Expense]]()
    var startDate = Date()
    var endDate = Date()
    var segmentedControlButtons = [UIButton]()
    var dateRangeLabel = UILabel()
    var dateRangeScrollView = UIScrollView()

    @IBOutlet weak var carNameBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkCar()
        
        if seguefromStatisticsVC {
            configureViewIfSegueFromStatisticsVC()
        } else {
            configureDateRangeViews()
            setMonthAsDefaultDateRange()
        }
        
        groupExpensesByDate(from: startDate, to: endDate)
        configureTableView()
        configureEmptyDataView()
        setConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateTableView(from: startDate, to: endDate)
    }
    
    @IBAction func carNameBarButtonTapped(_ sender: UIBarButtonItem) {
        let carsVC = CarsViewController()
        carsVC.title = "Мой гараж"
        navigationController?.pushViewController(carsVC, animated: true)
    }

    private func checkCar() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        if let car = appDelegate.car {
            carNameBarButton.title = car.brand + " " + car.model
            expenses = car.expenses
        }
    }
    
    private func groupExpensesByDate(from startDate: Date, to endDate: Date) {
        expensesGroupedByDate.removeAll()
        
        var predicate = NSPredicate()
        
        if seguefromStatisticsVC {
            let expenseTitle = self.title!
            predicate = NSPredicate.init(format: "self.date >= %@ && self.date <= %@ && self.category == %@", startDate as CVarArg, endDate as CVarArg, expenseTitle as CVarArg)
        } else {
            predicate = NSPredicate.init(format: "self.date >= %@ && self.date <= %@", startDate as CVarArg, endDate as CVarArg)
        }

        let expensesFiltered = expenses.filter(predicate).list
        let expensesDict = Dictionary(grouping: expensesFiltered) { $0.date.dayMonthAndYear() }
        
        let sortedKeys = expensesDict.keys.sorted { $0 > $1 }
        sortedKeys.forEach {
            let values = expensesDict[$0]?.sorted { $0.date > $1.date }
            expensesGroupedByDate.append(values ?? [])
        }
    }
    
    private func configureViewIfSegueFromStatisticsVC() {
        let expenseTitle = self.title!
        configureDateRangeViews(constant: 15)
        dateRangeScrollView.isHidden = true
        
        let backButton = UIBarButtonItem.init(title: nil, style: .plain, target: self, action: #selector(goBack(_:)))
        backButton.image = UIImage(systemName: "chevron.backward.circle.fill")
        backButton.tintColor = UIColor(named: expenseTitle)

        self.navigationItem.leftBarButtonItem = backButton
        
        // update dateRangeLabelText
        let startDayText = "\(dateProvider.getStringFrom(date: startDate, format: .dMMMM))"
        let endDayText = "\(dateProvider.getStringFrom(date: endDate, format: .dMMMMyyyy))"
        dateRangeLabel.text = "с \(startDayText) по \(endDayText)"
    }
    
    private func configureDateRangeViews(constant: CGFloat = 55) {
        dateRangeScrollView = StyleSheet().createCustomSegmentedControl(on: view, buttons: &segmentedControlButtons, selector: #selector(segmentedControlButtonTapped(_:)))
        
        dateRangeLabel = StyleSheet().createDateRangeLabel(on: view, constant: constant)
        dateRangeLabel.isUserInteractionEnabled = true

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changePeriod))
        dateRangeLabel.addGestureRecognizer(gestureRecognizer)
    }

    @objc func changePeriod() {
        changeDateRange()
    }
    
    private func setMonthAsDefaultDateRange() {
        // set dateRange to current month
        startDate = Date().getCurrentMonthStart()
        endDate = Date().getCurrentMonthEnd()
        dateRangeLabel.text = dateProvider.getStringFrom(date: Date(), format: .MMMM)
        
        // set selected "Per month"- button
        segmentedControlButtons[1].backgroundColor = .systemGray4
        segmentedControlButtons[1].layer.borderWidth = 0.3
        segmentedControlButtons[1].layer.borderColor = UIColor.darkGray.cgColor
    }
    
    private func configureTableView() {
        historyTableView.delegate = self
        historyTableView.dataSource = self
        historyTableView.register(UINib(nibName: "HistoryTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: HistoryTableViewCell.id)
        historyTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(historyTableView)
    }
    
    private func configureEmptyDataView() {
        let emptyLabel = UILabel()
        emptyLabel.text = "Нет операций за выбранный период"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .darkGray
        emptyLabel.font = UIFont.systemFont(ofSize: 16)
        emptyLabel.numberOfLines = 0
        
        let emptyImage = UIImageView()
        emptyImage.image = UIImage(named: "emptyHistory")
        emptyImage.contentMode = .scaleAspectFit
        
        emptyStackView.addArrangedSubview(emptyImage)
        emptyStackView.addArrangedSubview(emptyLabel)
        emptyStackView.axis = .vertical
        emptyStackView.alignment = .center
        emptyStackView.distribution = .fillProportionally
        emptyStackView.spacing = 5
        emptyStackView.translatesAutoresizingMaskIntoConstraints = false
        historyTableView.addSubview(emptyStackView)
    }
    
    private func showChosenExpenseVC(selectedExpense: Expense, isEditingAllowed: Bool) {
        let storyBoard = UIStoryboard(name: "Main", bundle: .main)
        let chosenExpenseVC = storyBoard.instantiateViewController(withIdentifier: "chosenExpenseVC") as! AddExpenseViewController

        chosenExpenseVC.setupDependences(startDateFromHistoryVC: startDate,
                                         endDateFromHistoryVC: endDate,
                                         isEditingAllowed: isEditingAllowed,
                                         expenseToBeEdited: selectedExpense)
        
        chosenExpenseVC.delegate = self
        
        if let presentationVC = chosenExpenseVC.presentationController as? UISheetPresentationController {
            presentationVC.detents = [.large()]
            presentationVC.preferredCornerRadius = 25
            
            present(chosenExpenseVC, animated: true, completion: nil)
        }

    }
    
    @objc private func goBack(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func segmentedControlButtonTapped(_ sender: UIButton) {
        // setting pressed button visible as selected
        setButtonViewAsSelected(sender)
        
        // updating tableview according to pressed button
        switch sender.titleLabel?.text {
        case "За неделю":
            startDate = Date().getCurrentWeekStart()
            endDate = Date().getCurrentWeekEnd()

            let startDayText = "\(dateProvider.getStringFrom(date: startDate, format: .dMMMM))"
            let endDayText = "\(dateProvider.getStringFrom(date: endDate, format: .dMMMM))"
            dateRangeLabel.text = "с \(startDayText) по \(endDayText)"
            updateTableView(from: startDate, to: endDate)
        case "За месяц":
            startDate = Date().getCurrentMonthStart()
            endDate = Date().getCurrentMonthEnd()
            
            dateRangeLabel.text = dateProvider.getStringFrom(date: Date(), format: .MMMM)
            updateTableView(from: startDate, to: endDate)
        case "За год":
            startDate = Date().getCurrentYearStart()
            endDate = Date().getCurrentYearEnd()
            
            dateRangeLabel.text = dateProvider.getStringFrom(date: Date(), format: .yyyy)
            updateTableView(from: startDate, to: endDate)
        case "Всё время":
            setDateAsAllTime()
        default:
            changeDateRange()
        }
        
    }
    
    private func setButtonViewAsSelected(_ sender: UIButton) {
        for button in segmentedControlButtons {
            if button == sender {
                UIView.animate(withDuration: 0.1, delay: 0.05, options: .transitionFlipFromLeft) {
                    button.backgroundColor = .systemGray4
                    button.layer.borderWidth = 0.3
                    button.layer.borderColor = UIColor.darkGray.cgColor
                }
            } else {
                UIView.animate(withDuration: 0.1, delay: 0.05, options: .transitionFlipFromLeft) {
                    button.backgroundColor = .secondarySystemBackground
                    button.layer.borderWidth = 0.0
                }
            }
        }
    }
    
    private func setDateAsAllTime() {
        guard let firstRecordDate = expenses.sorted(byKeyPath: "date", ascending: true).first?.date,
              let lastRecordDate = expenses.sorted(byKeyPath: "date", ascending: true).last?.date
        else { return }
        startDate = firstRecordDate
        endDate = lastRecordDate
        updateTableView(from: startDate, to: endDate)
        setDateAsDMMMMyyyy()
    }
    
    private func setDateAsDMMMMyyyy() {
        let startDayText = self.dateProvider.getStringFrom(date: startDate, format: .dMMMMyyyy)
        let endDayText = self.dateProvider.getStringFrom(date: endDate, format: .dMMMMyyyy)
        
        UIView.animate(withDuration: 0.3) {
            self.dateRangeLabel.text =
            (startDayText == endDayText) ?
            startDayText : ("с \(startDayText) по \(endDayText)")
        }
    }
    
    private func changeDateRange() {
        let dateVC = storyboard?.instantiateViewController(withIdentifier: "dateVC") as! DateViewController
        
        dateVC.delegate = self
        dateVC.startDate = startDate
        dateVC.endDate = endDate
        
        if let presentationVC = dateVC.presentationController as? UISheetPresentationController {
            presentationVC.detents = [.medium()]
            presentationVC.preferredCornerRadius = 25
            
            present(dateVC, animated: true, completion: nil)
        }
    }
    
    func updateTableView(from startDate: Date, to endDate: Date) {
        groupExpensesByDate(from: startDate, to: endDate)
        UIView.animate(withDuration: 0.3) {
            self.historyTableView.reloadData()
        }
    }

    private func setConstraints() {
        NSLayoutConstraint.activate([
            historyTableView.topAnchor.constraint(equalTo: dateRangeLabel.bottomAnchor, constant: 10),
            historyTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            historyTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            historyTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            emptyStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStackView.topAnchor.constraint(equalTo: historyTableView.topAnchor, constant: 50),
            emptyStackView.widthAnchor.constraint(equalTo: view.widthAnchor),
            emptyStackView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }

}

// MARK: - Delegates

extension HistoryViewController: DateViewControllerDelegate {
    
    func updateDates(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
        setDateAsDMMMMyyyy()
        updateTableView(from: startDate, to: endDate)
    }
    
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (expensesGroupedByDate.count == 0 || expensesGroupedByDate.count == 1)  && expensesGroupedByDate[0].isEmpty {
           emptyStackView.isHidden = false
        } else {
            emptyStackView.isHidden = true
        }

        return expensesGroupedByDate[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if expensesGroupedByDate.count == 0 || (expensesGroupedByDate.count == 1  && expensesGroupedByDate[0].isEmpty) {
           emptyStackView.isHidden = false
        } else {
            emptyStackView.isHidden = true
        }

        return expensesGroupedByDate.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let firstExpenseInSection = expensesGroupedByDate[section].first {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMMM yyyy"
            let dateString = formatter.string(from: firstExpenseInSection.date)
            return dateString
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedExpense = expensesGroupedByDate[indexPath.section][indexPath.row]
        showChosenExpenseVC(selectedExpense: selectedExpense, isEditingAllowed: false)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = historyTableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.id, for: indexPath) as? HistoryTableViewCell else { return UITableViewCell() }
        
        let expense = expensesGroupedByDate[indexPath.section][indexPath.row]
        
        cell.historyCellImageView.image = UIImage(named: expense.category)
        cell.historyCellCategoryLabel.text = "\(expense.category)"
        cell.tempExpenseValue = expense.value
        cell.historyCellMileageLabel.text = "\(expense.mileage) км"
        cell.historyCellDateLabel.text = dateProvider.getStringFrom(date: expense.date, format: .ddMMyyyyHHmm)
        cell.historyReceiptImage.image = expense.image != nil ? UIImage(systemName: "doc") : UIImage()
        
        if let volume = expense.volume {
            cell.historyVolumeLabel.text = String().withTwoFractionDigits(from: volume) + " л"
        } else {
            cell.historyVolumeLabel.text = ""
        }
        
        if let locationString = expense.location {
            cell.locationLabel.text = locationString.components(separatedBy: "\n").first
        } else {
            cell.locationLabel.text = ""
        }
        
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
            
            let expenseToBeDeleted = self.expensesGroupedByDate[indexPath.section][indexPath.row]
            
            let deleteString = String.localizedStringWithFormat("%.2f руб", expenseToBeDeleted.value)
            let dateString = self.dateProvider.getStringFrom(date: expenseToBeDeleted.date, format: .ddMMyyyy)
            
            let alertMessage = "Вы действительно хотите удалить запись \"\(expenseToBeDeleted.category)\" от \(dateString) на сумму \(deleteString)?"
            
            let alertVC = UIAlertController(title: "Внимание!", message: alertMessage, preferredStyle: .actionSheet)
            
            alertVC.addAction(UIAlertAction(title: "Да", style: .destructive, handler: { _ in
                
                if let imageName = expenseToBeDeleted.image {
                    self.imageManager.deleteImage(imageName: imageName)
                }
                
                try! self.realm.write {
                    self.realm.delete(expenseToBeDeleted)
                }
                self.expensesGroupedByDate[indexPath.section].remove(at: indexPath.row)
                self.historyTableView.deleteRows(at: [indexPath], with: .automatic)

            }))
            
            alertVC.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: nil))
            
            self.present(alertVC, animated: true, completion: nil)
            complete(true)
        })
        return deleteAction
    }
    
    private func editAction(indexPath: IndexPath) -> UIContextualAction {
        let editAction = UIContextualAction(style: .normal,
                                            title: "Редактировать запись",
                                            handler: { [weak self] _, _, complete in
            guard let self = self else { return }
            let expenseToBeEdited = self.expensesGroupedByDate[indexPath.section][indexPath.row]
            self.showChosenExpenseVC(selectedExpense: expenseToBeEdited, isEditingAllowed: true)
            complete(true)
        })
        
        return editAction
    }
    
}
