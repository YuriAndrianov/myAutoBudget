//
//  EcoViewController.swift
//  myAutoBudget
//
//  Created by MacBook on 17.10.2021.
//

import UIKit
import RealmSwift
import Charts

class EcoViewController: UIViewController, ChartViewDelegate {

    let dateProvider = DateProvider()
    let ecoTableView = UITableView()
    let barChartView = BarChartView()
    let markerView = CustomMarkerView()
    let emptyStackView = UIStackView()
    
    var expenses: List<Expense>!
    var xValues = [String]()
    var yValues = [Double]()
    var startDate = Date()
    var endDate = Date()
    var dateRangeScrollView = UIScrollView()
    var dateRangeLabel = UILabel()
    var segmentedControlButtons = [UIButton]()
    
    @IBOutlet weak var carNameBarButton: UIBarButtonItem!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ecoTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        checkVehicle()
        configureDateRangeViews()
        setMonthAsDefaultDateRange()
        getChartDataAllExpenses(from: startDate, to: endDate, period: .dayMonthAndYear)
        configureBarChartView()
        configureEmptyDataView()
        configureEcoTableView()
        setConstraints()
    }

    private func checkVehicle() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        if let car = appDelegate.car {
            carNameBarButton.title = car.brand + " " + car.model
            expenses = car.expenses
        }
    }
    
    private func configureEmptyDataView() {
        let emptyLabel = UILabel()
        emptyLabel.text = "Нет данных за выбранный период"
        emptyLabel.textColor = .darkGray
        emptyLabel.textAlignment = .center
        emptyLabel.font = UIFont.systemFont(ofSize: 16)
        emptyLabel.numberOfLines = 0
        
        let emptyImage = UIImageView()
        emptyImage.image = UIImage(named: "emptyChart")
        emptyImage.contentMode = .scaleAspectFit
        
        emptyStackView.addArrangedSubview(emptyImage)
        emptyStackView.addArrangedSubview(emptyLabel)
        emptyStackView.axis = .vertical
        emptyStackView.alignment = .center
        emptyStackView.distribution = .fillProportionally
        emptyStackView.spacing = 5
        emptyStackView.translatesAutoresizingMaskIntoConstraints = false
        barChartView.addSubview(emptyStackView)
    }
    
    private func configureBarChartView() {
        barChartView.delegate = self
        barChartView.legend.enabled = true
        markerView.chartView = barChartView
        barChartView.marker = markerView
        barChartView.frame = CGRect(x: 0, y: 0, width: ecoTableView.bounds.width, height: view.frame.width * 0.45)
    }
    
    private func getChartDataAllExpenses(from startDate: Date, to endDate: Date, period: Date.Period) {
        xValues.removeAll()
        yValues.removeAll()
        
        let predicate = NSPredicate.init(format: "self.date >= %@ && self.date <= %@", startDate as CVarArg, endDate as CVarArg)
        
        let expensesFiltered = expenses.filter(predicate)

        // if there is no data emptyView will be shown
        if expensesFiltered.isEmpty {
            emptyStackView.isHidden = false
        } else {
            emptyStackView.isHidden = true
        }
        
        if period == .year {
            let expensesDict = Dictionary(grouping: expensesFiltered) { $0.date.year() }
            
            let sortedKeys = expensesDict.keys.sorted { $0 < $1 }
            sortedKeys.forEach {
                let dateString = dateProvider.getStringFrom(date: $0, format: .yyyy)
                xValues.append(dateString)
                
                let values = expensesDict[$0]?.sorted { $0.date < $1.date }
                
                var result: Double = 0.0
                
                values?.forEach({ expense in
                    result += expense.value
                })
                yValues.append(result)
            }
            
        } else if period == .dayMonthAndYear {
            let expensesDict = Dictionary(grouping: expensesFiltered) { $0.date.dayMonthAndYear() }
            
            let sortedKeys = expensesDict.keys.sorted { $0 < $1 }
            sortedKeys.forEach {
                let dateString = dateProvider.getStringFrom(date: $0, format: .dMMM)
                xValues.append(dateString)
                
                let values = expensesDict[$0]?.sorted { $0.date < $1.date }
                
                var result: Double = 0.0
                
                values?.forEach({ expense in
                    result += expense.value
                })
                yValues.append(result)
            }
        } else {
            let expensesDict = Dictionary(grouping: expensesFiltered) { $0.date.monthAndYear() }
            
            let sortedKeys = expensesDict.keys.sorted { $0 < $1 }
            sortedKeys.forEach {
                let dateString = dateProvider.getStringFrom(date: $0, format: .MMMM)
                xValues.append(dateString)
                
                let values = expensesDict[$0]?.sorted { $0.date < $1.date }
                
                var result: Double = 0.0
                
                values?.forEach({ expense in
                    result += expense.value
                })
                yValues.append(result)
            }
        }
        
        var entries = [BarChartDataEntry]()
        
        if !xValues.isEmpty {
            for i in 0...xValues.count - 1 {
                entries.append(BarChartDataEntry(x: Double(i), y: yValues[i]))
            }
        }
        
        let dataSet = BarChartDataSet(entries: entries)
        dataSet.colors = [NSUIColor(cgColor: UIColor(named:"aqua")!.cgColor)]
        dataSet.label = "Расходы за период, руб"
        
        let data = BarChartData(dataSet: dataSet)
        barChartView.data = data
        
        barChartView.xAxis.axisMinimum = -0.5
        barChartView.xAxis.granularity = 1
        barChartView.leftAxis.axisMinimum = 0
        barChartView.rightAxis.axisMinimum = 0
        
        barChartView.leftAxis.enabled = false
        barChartView.rightAxis.enabled = false
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xValues)
        barChartView.animate(yAxisDuration: 0.3, easingOption: .linear)

    }

    private func configureDateRangeViews() {
        dateRangeScrollView = StyleSheet().createCustomSegmentedControl(on: view, buttons: &segmentedControlButtons, selector: #selector(segmentedControlButtonTapped(_:)))
        dateRangeLabel = StyleSheet().createDateRangeLabel(on: view)
        dateRangeLabel.isUserInteractionEnabled = true

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changePeriod))
        dateRangeLabel.addGestureRecognizer(gestureRecognizer)
    }

    @objc func changePeriod() {
        changeDateRange()
    }

    @objc private func segmentedControlButtonTapped(_ sender: UIButton) {
        // setting pressed button visible as selected
        setButtonViewAsSelected(sender)

        // updating statistics according to pressed button
        switch sender.titleLabel?.text {
        case "За неделю":
            startDate = Date().getCurrentWeekStart()
            endDate = Date().getCurrentWeekEnd()

            let startDayText = "\(dateProvider.getStringFrom(date: startDate, format: .dMMMM))"
            let endDayText = "\(dateProvider.getStringFrom(date: endDate, format: .dMMMM))"

            dateRangeLabel.text = "с \(startDayText) по \(endDayText)"
            ecoTableView.reloadData()
            getChartDataAllExpenses(from: startDate, to: endDate, period: .dayMonthAndYear)
        case "За месяц":
            startDate = Date().getCurrentMonthStart()
            endDate = Date().getCurrentMonthEnd()
            dateRangeLabel.text = dateProvider.getStringFrom(date: Date(), format: .MMMM)
            ecoTableView.reloadData()
            getChartDataAllExpenses(from: startDate, to: endDate, period: .dayMonthAndYear)
        case "За год":
            startDate = Date().getCurrentYearStart()
            endDate = Date().getCurrentYearEnd()
            dateRangeLabel.text = dateProvider.getStringFrom(date: Date(), format: .yyyy)
            ecoTableView.reloadData()
            getChartDataAllExpenses(from: startDate, to: endDate, period: .monthAndYear)
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
        setDateAsDMMMMyyyy()
        ecoTableView.reloadData()
        getChartDataAllExpenses(from: startDate, to: endDate, period: .year)
    }
    
    private func setDateAsDMMMMyyyy() {
        let startDayText = self.dateProvider.getStringFrom(date: startDate, format: .dMMMMyyyy)
        let endDayText = self.dateProvider.getStringFrom(date: endDate, format: .dMMMMyyyy)
        
        UIView.transition(with: dateRangeLabel, duration: 0.3, options: .transitionCrossDissolve) {
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

    private func configureEcoTableView() {
        ecoTableView.delegate = self
        ecoTableView.dataSource = self
        ecoTableView.rowHeight = 100
        ecoTableView.register(UINib(nibName: "EcoTableViewCell", bundle: .main), forCellReuseIdentifier: EcoTableViewCell.id)
        ecoTableView.translatesAutoresizingMaskIntoConstraints = false
        ecoTableView.tableHeaderView = barChartView
        view.addSubview(ecoTableView)
    }
    
    private func calculateAmountOfFuel() -> Double {
        let amountOfFuel: Double = expenses.filter("self.date >= %@ && self.date <= %@ && self.category == %@", startDate, endDate, "Заправка").sum(ofProperty: "volume")
        return amountOfFuel
    }
    
    private func calculateDaysBetweenTwoDates() -> Double {
        let components = dateProvider.calendar.dateComponents([.day], from: startDate, to: endDate)
        var days = Double(components.day!)
        if days == 0.0 { days = 1.0 }
        return days
    }
    
    private func calculateMileage() -> Double {
        let sortedExpenses = expenses.filter("self.date >= %@ && self.date <= %@", startDate, endDate).sorted { $0.mileage > $1.mileage }
        
        if sortedExpenses.count >= 2 {
            guard let minMileage = sortedExpenses.last?.mileage,
                  let maxMileage = sortedExpenses.first?.mileage else { return 1 }
            if maxMileage - minMileage != 0 {
                return Double(maxMileage - minMileage)
            } else { return 1 }
        } else { return 1 }
    }

    @IBAction func carNameBarButtonTapped(_ sender: UIBarButtonItem) {
        let carsVC = CarsViewController()
        carsVC.title = "Мой гараж"
        navigationController?.pushViewController(carsVC, animated: true)
    }

    private func setConstraints() {
        NSLayoutConstraint.activate([
            emptyStackView.centerXAnchor.constraint(equalTo: barChartView.centerXAnchor),
            emptyStackView.centerYAnchor.constraint(equalTo: barChartView.centerYAnchor),
            emptyStackView.widthAnchor.constraint(equalTo: barChartView.widthAnchor),
            emptyStackView.heightAnchor.constraint(equalToConstant: barChartView.frame.height * 0.6)
        ])

        NSLayoutConstraint.activate([
            ecoTableView.topAnchor.constraint(equalTo: dateRangeLabel.bottomAnchor, constant: 10),
            ecoTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ecoTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ecoTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
}

// MARK: - Delegates

extension EcoViewController: DateViewControllerDelegate {
    
    func updateDates(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
        setDateAsDMMMMyyyy()
        ecoTableView.reloadData()
        
        let diff = startDate.distance(to: endDate) / 86400 // in days
      
        switch diff {
        case 0...31:
            getChartDataAllExpenses(from: startDate, to: endDate, period: .dayMonthAndYear)
        case 32...366:
            getChartDataAllExpenses(from: startDate, to: endDate, period: .monthAndYear)
        default:
            getChartDataAllExpenses(from: startDate, to: endDate, period: .year)
        }
    }
    
}

extension EcoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = ecoTableView.dequeueReusableCell(withIdentifier: EcoTableViewCell.id, for: indexPath) as? EcoTableViewCell else { return UITableViewCell() }
        
        let predicate = NSPredicate.init(format: "self.date >= %@ && self.date <= %@", startDate as CVarArg, endDate as CVarArg)
        let allExpenses: Double = expenses.filter(predicate).sum(ofProperty: "value")
        let allExpensesString = String.localizedStringWithFormat("%.2f руб", allExpenses)
        
        let expensePerDay = allExpenses / calculateDaysBetweenTwoDates()
        let expensePerDayString = String.localizedStringWithFormat("%.2f руб", expensePerDay)
        
        let allMileage = calculateMileage()
        var mileageString = "\(Int(allMileage)) км"
        
        let mileagePerDay = Double(allMileage) / calculateDaysBetweenTwoDates()
        var mileagePerDayString = String.localizedStringWithFormat("%.2f км", mileagePerDay)
        
        if calculateMileage() == 1 {
            mileageString = "0 км"
            mileagePerDayString = "0 км"
        }
        
        let volumeOfFuel = calculateAmountOfFuel()
        let volumeOfFuelString = String.localizedStringWithFormat("%.2f л", volumeOfFuel)
        
        var consumptionString = ""
        var costPerKilometerString = ""
        
        if calculateMileage() == 1 {
            consumptionString = "0.00 л/100 км"
            costPerKilometerString = "0.00 руб/км"
        } else {
            let consumption = volumeOfFuel / calculateMileage() * 100
            consumptionString = String.localizedStringWithFormat("%.2f л/100 км", consumption)
            
            let costPerKilometer = allExpenses / calculateMileage()
            costPerKilometerString = String.localizedStringWithFormat("%.2f руб/км", costPerKilometer)
        }
        
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = "Все расходы за период:"
            cell.valueLabel.text = allExpensesString
            cell.subtitleLabel.text = "В день:"
            cell.subValueLabel.text = expensePerDayString
        case 1:
            cell.titleLabel.text = "Общий пробег за период:"
            cell.valueLabel.text = mileageString
            cell.subtitleLabel.text = "В день:"
            cell.subValueLabel.text = mileagePerDayString
        case 2:
            cell.titleLabel.text = "Средний расход топлива за период:"
            cell.valueLabel.text = consumptionString
            cell.subtitleLabel.text = "Израсходовано топлива за период:"
            cell.subValueLabel.text = volumeOfFuelString
        case 3:
            cell.titleLabel.text = "Стоимость эксплуатации:"
            cell.valueLabel.text = costPerKilometerString
            cell.subtitleLabel.text = ""
            cell.subValueLabel.text = ""
        default: return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
}
