//
//  StatisticsViewController.swift
//  myAutoBudget
//
//  Created by MacBook on 01.10.2021.
//

import UIKit
import RealmSwift
import Charts

class StatisticsViewController: UIViewController {

    let dateProvider = DateProvider()
    let headerView = UIView()
    let headerImageView = UIImageView()
    let headerTitleLabel = UILabel()
    let headerValueLabel = UILabel()
    let chartCenterImageView = UIImageView()
    let pieChartView = PieChartView()
    let statisticsTableView = UITableView()

    var statisticsTableViewData = [PieChartDataEntry]()
    var expenses: List<Expense>!
    var startDate = Date()
    var endDate = Date()
    var segmentedControlButtons = [UIButton]()
    var dateRangeLabel = UILabel()
    var dateRangeScrollView = UIScrollView()
    var expensesPerChosenPeriod = 0.0
    var chartValueSelected: Bool = false
    var previousScrollOffset: CGFloat = 0.0
    var chartHeightConstraint: NSLayoutConstraint!
    
    lazy var maxChartHeight = view.frame.width * 0.7
    lazy var minChartHeight = view.frame.width * 0.35
    
    @IBOutlet weak var carNameBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        configureDateRangeViews()
        setMonthAsDefaultDateRange()
        configureHeaderView()
        configurePieChartView()
        configurePieChartCenter()
        configureStatisticsTableView()
        setConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        if let car = appDelegate.car {
            carNameBarButton.title = car.brand + " " + car.model
            expenses = car.expenses
            updatePieChartData(from: startDate, to: endDate)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        chartValueNothingSelected(pieChartView)
        ReminderChecker.shared.checkForReminders(on: self)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            headerView.layer.borderColor = UIColor.systemGray6.cgColor
        }
    }
    
    @IBAction func carNameBarButtonTapped(_ sender: UIBarButtonItem) {
        let carsVC = CarsViewController()
        carsVC.title = "Мой гараж"
        navigationController?.pushViewController(carsVC, animated: true)
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
    
    private func configureStatisticsTableView() {
        statisticsTableView.delegate = self
        statisticsTableView.dataSource = self
        statisticsTableView.register(UINib(nibName: "StatisticsTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: StatisticsTableViewCell.id)
        statisticsTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statisticsTableView)
    }
    
    private func configurePieChartCenter() {
        chartCenterImageView.contentMode = .scaleToFill
        chartCenterImageView.image = UIImage(named: "sigma")
        chartCenterImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chartCenterImageView)
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
            
            updatePieChartData(from: startDate, to: endDate)
            pieChartView.animate(xAxisDuration: 0.5)
            chartValueNothingSelected(pieChartView)
        case "За месяц":
            startDate = Date().getCurrentMonthStart()
            endDate = Date().getCurrentMonthEnd()
            
            dateRangeLabel.text = dateProvider.getStringFrom(date: Date(), format: .MMMM)
            
            updatePieChartData(from: startDate, to: endDate)
            pieChartView.animate(xAxisDuration: 0.5)
            chartValueNothingSelected(pieChartView)
            
        case "За год":
            startDate = Date().getCurrentYearStart()
            endDate = Date().getCurrentYearEnd()
            
            dateRangeLabel.text = dateProvider.getStringFrom(date: Date(), format: .yyyy)
            
            updatePieChartData(from: startDate, to: endDate)
            pieChartView.animate(xAxisDuration: 0.5)
            chartValueNothingSelected(pieChartView)
        case "Всё время":
            setDateAsAllTime()
        default:
            changeDateRange()
        }
    }
    
    @objc private func accessoryButtonTapped(_ sender: UIButton) {
        guard let cell = statisticsTableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? StatisticsTableViewCell else { return }
        
        if cell.tempExpenseValue == 0 {
            let alertVC = UIAlertController(title: nil, message: "Нет записей за выбранный период", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Ок", style: .cancel, handler: { [weak self] _ in
                guard let self = self else { return }
                self.chartValueNothingSelected(self.pieChartView)
            }))
            present(alertVC, animated: true)
        } else {
            if let expenseTitle = cell.expenseTitle.text {
                let storyboard = UIStoryboard(name: "Main", bundle: .main)
                let historyVC = storyboard.instantiateViewController(withIdentifier: "historyVC") as! HistoryViewController
                historyVC.seguefromStatisticsVC = true
                historyVC.title = expenseTitle
                historyVC.startDate = startDate
                historyVC.endDate = endDate
                navigationController?.pushViewController(historyVC, animated: true)
            }
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
        guard let firstRecordDate: Date = expenses.sorted(byKeyPath: "date", ascending: true).first?.date,
              let lastRecordDate: Date = expenses.sorted(byKeyPath: "date", ascending: true).last?.date
        else { return }
        startDate = firstRecordDate
        endDate = lastRecordDate
        updatePieChartData(from: startDate, to: endDate)
        pieChartView.animate(xAxisDuration: 0.5)
        statisticsTableView.reloadData()
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
    
    private func updatePieChartData(from startDate: Date, to endDate: Date) {
        var entries = [PieChartDataEntry]()
        
        Expense.Category.allCases.forEach { entries.append(ChartsService().getFilteredExpenses(category: $0, from: startDate, to: endDate)) }
        
        statisticsTableViewData = entries.sorted { $0.value > $1.value }
        
        // calculating all expenses per chosen period and saving it to UD for ChartFormatter
        expensesPerChosenPeriod = 0.0
        
        statisticsTableViewData.forEach { [weak self] in
            self?.expensesPerChosenPeriod += $0.value }
        
        UserDefaults.standard.set(expensesPerChosenPeriod, forKey: "totalValue")
        
        updateHeaderView()
        
        let dataSet = PieChartDataSet(entries: statisticsTableViewData)
        
        // setting colors according to entry.label
        dataSet.resetColors()
        statisticsTableViewData.forEach { dataSet.colors.append(NSUIColor(cgColor: UIColor(named: $0.label!)!.cgColor)) }
        
        dataSet.valueFont = UIFont.boldSystemFont(ofSize: 11)
        dataSet.drawIconsEnabled = false
        dataSet.automaticallyDisableSliceSpacing = false
        dataSet.sliceSpace = 2
        
        let data = PieChartData(dataSet: dataSet)
        
        let formatter = ChartFormatter()
        data.setValueFormatter(formatter)
        pieChartView.data = data

        if expensesPerChosenPeriod == 0 {
            dataSet.valueTextColor = UIColor.systemBackground
            pieChartView.layer.shadowColor = UIColor.clear.cgColor
        } else {
            dataSet.valueTextColor = NSUIColor(cgColor: UIColor.white.cgColor)
            pieChartView.layer.shadowColor = UIColor(named: "shadowColor")?.cgColor
        }

        if chartHeightConstraint.constant != maxChartHeight {
            pieChartView.data?.dataSets.first?.drawValuesEnabled = false
        }
    }
    
    private func configurePieChartView() {
        pieChartView.delegate = self
        pieChartView.legend.enabled = false
        pieChartView.rotationEnabled = false
        pieChartView.drawEntryLabelsEnabled = false
        pieChartView.holeRadiusPercent = 0.55
        pieChartView.holeColor = .systemBackground
        pieChartView.transparentCircleRadiusPercent = 0.6
        pieChartView.transparentCircleColor = .systemGray3
        pieChartView.addBorder(.bottom, color: .systemGray3, thickness: 0.5)
        pieChartView.extraTopOffset = 10
        pieChartView.extraBottomOffset = 10
        pieChartView.layer.shadowRadius = 5
        pieChartView.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        pieChartView.layer.shadowOpacity = 0.5
        pieChartView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pieChartView)
        chartHeightConstraint = pieChartView.heightAnchor.constraint(equalToConstant: maxChartHeight)

    }
    
    private func configureHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        headerImageView.contentMode = .scaleToFill
        headerImageView.image = UIImage(named: "sigma")
        
        headerTitleLabel.textAlignment = .left
        headerTitleLabel.numberOfLines = 0
        headerTitleLabel.font = UIFont.systemFont(ofSize: 16)
        headerTitleLabel.text = "Все расходы:"
        
        headerValueLabel.textAlignment = .right
        headerValueLabel.numberOfLines = 0
        headerValueLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
        [headerImageView, headerTitleLabel, headerValueLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview($0)
        }
    }
    
    private func updateHeaderView() {
        let expensesPerPeriodString = String.localizedStringWithFormat("%.2f руб", expensesPerChosenPeriod)
        
        UIView.animate(withDuration: 0.3) {
            self.headerValueLabel.text = expensesPerPeriodString
        }
    }

    private func setConstraints() {
        NSLayoutConstraint.activate([
            statisticsTableView.topAnchor.constraint(equalTo: pieChartView.bottomAnchor),
            statisticsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statisticsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statisticsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            chartCenterImageView.centerXAnchor.constraint(equalTo: pieChartView.centerXAnchor),
            chartCenterImageView.widthAnchor.constraint(equalToConstant: 25),
            chartCenterImageView.heightAnchor.constraint(equalToConstant: 25),
            chartCenterImageView.centerYAnchor.constraint(equalTo: pieChartView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            pieChartView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 5),
            pieChartView.widthAnchor.constraint(equalToConstant: view.frame.size.width * 0.95),
            chartHeightConstraint,
            pieChartView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        NSLayoutConstraint.activate([
            headerImageView.heightAnchor.constraint(equalToConstant: 35),
            headerImageView.widthAnchor.constraint(equalToConstant: 35),
            headerImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            headerImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 2),

            headerTitleLabel.leadingAnchor.constraint(equalTo: headerImageView.trailingAnchor, constant: 20),
            headerTitleLabel.centerYAnchor.constraint(equalTo: headerImageView.centerYAnchor),

            headerValueLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10),
            headerValueLabel.centerYAnchor.constraint(equalTo: headerImageView.centerYAnchor),

            headerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 45),
            headerView.topAnchor.constraint(equalTo: dateRangeLabel.bottomAnchor, constant: 5),
            headerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
}

// MARK: - Delegates

extension StatisticsViewController: DateViewControllerDelegate {
    
    func updateDates(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
        setDateAsDMMMMyyyy()
        updatePieChartData(from: startDate, to: endDate)
        chartValueNothingSelected(pieChartView)
    }
    
}

extension StatisticsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statisticsTableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = statisticsTableView.dequeueReusableCell(withIdentifier: StatisticsTableViewCell.id, for: indexPath) as? StatisticsTableViewCell else { return UITableViewCell() }
        
        cell.selectionStyle = .none
        cell.accessoryType = .none
        cell.statisticsImageView.image = statisticsTableViewData[indexPath.row].icon
        cell.expenseTitle.text = statisticsTableViewData[indexPath.row].label
        cell.tempExpenseValue = statisticsTableViewData[indexPath.row].value
        
        if expensesPerChosenPeriod != 0 {
            let percent = cell.tempExpenseValue / expensesPerChosenPeriod * 100
            cell.percentLabel.text = String.localizedStringWithFormat("%.1f", percent) + " %"
        } else {
            cell.percentLabel.text = "0.0 %"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? StatisticsTableViewCell else { return }
        
        if chartValueSelected == false {
            let x = Double(indexPath.row)
            let y = cell.tempExpenseValue
            pieChartView.highlightValue(x: x, y: y, dataSetIndex: 0)
        } else {
            statisticsTableView.deselectRow(at: indexPath, animated: true)
            chartValueNothingSelected(pieChartView)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollDiff = scrollView.contentOffset.y - previousScrollOffset
        let absoluteTop: CGFloat = 0
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
        
        if canAnimateHeader(scrollView) {
            // Calculate new chart height
            var newHeight = chartHeightConstraint.constant
            if isScrollingDown {
                newHeight = max(minChartHeight, chartHeightConstraint.constant - abs(scrollDiff))
            } else if isScrollingUp {
                newHeight = min(maxChartHeight, chartHeightConstraint.constant + abs(scrollDiff))
            }
            
            if newHeight != chartHeightConstraint.constant {
                chartHeightConstraint.constant = newHeight
            }
            
            pieChartView.data?.dataSets.first?.drawValuesEnabled = newHeight != maxChartHeight ? false : true
        }
        
        previousScrollOffset = scrollView.contentOffset.y
    }
    
    func canAnimateHeader(_ scrollView: UIScrollView) -> Bool {
        // Calculate the size of the scrollView when header is collapsed
        let scrollViewMaxHeight = scrollView.frame.height + self.chartHeightConstraint.constant - minChartHeight
        
        // Make sure that when header is collapsed, there is still space to scroll
        return scrollView.contentSize.height > scrollViewMaxHeight
    }
    
}

extension StatisticsViewController: ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        chartValueSelected = true
        
        let pieEntry = entry as! PieChartDataEntry
        statisticsTableViewData = [pieEntry]
        statisticsTableView.reloadSections(IndexSet(integer: 0), with: .fade)
        
        let cell = statisticsTableView.cellForRow(at: IndexPath(item: 0, section: 0))
        
        // create custom accessory button
        let accessoryButton: UIButton = {
            let button = UIButton(type: .system)
            button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            button.setImage(UIImage(systemName: "chevron.right.circle.fill"), for: .normal)
            button.tintColor = UIColor(named: pieEntry.label ?? "aqua")
            button.addTarget(self, action: #selector(accessoryButtonTapped(_:)), for: .touchUpInside)
            return button
        }()
        
        cell?.accessoryView = accessoryButton
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut ) {
            self.chartHeightConstraint.constant = self.maxChartHeight
            self.chartCenterImageView.image = pieEntry.icon
            self.pieChartView.data?.dataSets.first?.drawValuesEnabled = true
            self.view.layoutIfNeeded()
        }
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        chartValueSelected = false
        updateHeaderView()
        
        var entries = [PieChartDataEntry]()
        
        Expense.Category.allCases.forEach { entries.append(ChartsService().getFilteredExpenses(category: $0, from: startDate, to: endDate)) }
        
        statisticsTableViewData = entries.sorted { $0.value > $1.value }
        statisticsTableView.reloadSections(IndexSet(integer: 0), with: .fade)
        
        chartView.highlightValues([])
        
        UIView.animate(withDuration: 0.3, animations: {
            self.chartCenterImageView.image = UIImage(named: "sigma")
        })
    }
    
}
