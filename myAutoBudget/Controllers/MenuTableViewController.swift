//
//  MenuTableViewController.swift
//  myAutoBudget
//
//  Created by MacBook on 25.09.2021.
//

import UIKit

class MenuTableViewController: UITableViewController {

    let menuColor = UIColor.secondarySystemBackground
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "menuCell")
        tableView.backgroundColor = menuColor
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()

    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath)
        
        var config = cell.defaultContentConfiguration()
        
        if indexPath.row == 0 {
            config.text = "Мой гараж"
            config.textProperties.color = .label
            config.image = UIImage(named: "garage")
        }
        
        cell.backgroundColor = .secondarySystemBackground
        cell.contentConfiguration = config
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            let carsVC = CarsViewController()
            carsVC.title = "Мой гараж"
            navigationController?.pushViewController(carsVC, animated: true)
        }
    }
    
}
