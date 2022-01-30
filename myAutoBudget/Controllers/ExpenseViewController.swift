//
//  ExpenseViewController.swift
//  myAutoBudget
//
//  Created by MacBook on 26.09.2021.
//

import UIKit

class ExpenseViewController: UIViewController {
    
    static let expenseCellIdentifier = "expenseCell"
    let expenseTitles = Expense.Category.allCases
    var expenseCollectionView: UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        configureCollectionView()
    }
 
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        layout.scrollDirection = .vertical
        layout.collectionView?.backgroundColor = .systemBackground
        expenseCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        guard let expenseCollectionView = expenseCollectionView else { return }
        
        expenseCollectionView.register(UINib(nibName: "ExpenseCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: Self.expenseCellIdentifier)
        expenseCollectionView.delegate = self
        expenseCollectionView.dataSource = self
        expenseCollectionView.delaysContentTouches = false
        expenseCollectionView.backgroundColor = .systemBackground
        
        view.addSubview(expenseCollectionView)
        
        expenseCollectionView.frame = CGRect(x: 0, y: 50, width: view.frame.width, height: view.frame.height / 2 - 50)
    }
}

extension ExpenseViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return expenseTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = expenseCollectionView!.dequeueReusableCell(withReuseIdentifier: Self.expenseCellIdentifier, for: indexPath) as? ExpenseCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.expenseImageView.image = UIImage(named: expenseTitles[indexPath.item].rawValue)
        cell.expenseLabel.text = expenseTitles[indexPath.item].rawValue
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let chosenExpenseVC = storyboard?.instantiateViewController(withIdentifier: "chosenExpenseVC") as? AddExpenseViewController else { return }
        
        chosenExpenseVC.expenseTitle = expenseTitles[indexPath.item].rawValue
        
        if let presentationVC = chosenExpenseVC.presentationController as? UISheetPresentationController {
            presentationVC.detents = [.large()]
            presentationVC.preferredCornerRadius = 25
            
            present(chosenExpenseVC, animated: true, completion: nil)
        }
    }
}

extension ExpenseViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing = CGFloat(1.0)
        let cellWidth = expenseCollectionView!.frame.size.width / 3 - 4 * spacing
        let cellHeight = expenseCollectionView!.frame.size.height / 4 - 5 * spacing
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
}
