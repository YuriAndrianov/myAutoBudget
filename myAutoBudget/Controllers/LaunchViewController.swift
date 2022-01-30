//
//  LaunchViewController.swift
//  myAutoBudget
//
//  Created by MacBook on 30.12.2021.
//

import UIKit

class LaunchViewController: UIViewController {
    
    @IBOutlet weak var appLabel: UILabel!
    
    let imageView: UIImageView = {
        let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
        iv.image = UIImage(named: "1024")
        return iv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.center = view.center
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
            self?.animate()
        })
    }
    
    private func animate() {
        UIView.animate(withDuration: 1) {
            let size = self.view.frame.size.width * 3
            let diffX = size - self.view.frame.size.width
            let diffY = self.view.frame.size.height - size
            
            self.imageView.frame = CGRect(x: -(diffX / 2),
                                          y: diffY / 2,
                                          width: size,
                                          height: size)
            self.appLabel.alpha = 0
            self.imageView.alpha = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

            if appDelegate.car != nil {
                let vc = self?.storyboard?.instantiateViewController(withIdentifier: "mainTabBarVC") as! MainTabBarController
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .fullScreen
                self?.present(vc, animated: true)
            } else {
                self?.showNoChosenCarAlert()
            }
        }
    }
    
    private func showNoChosenCarAlert() {
        let alertVC = UIAlertController(title: "Внимание", message: "Необходимо выбрать или создать новое транспортное средство", preferredStyle: .alert)
        
        let goToCarsVC = UIAlertAction(title: "Перейти в \"Мой гараж\"", style: .default) { [weak self] _ in
            
            let carsVC = CarsViewController()
            carsVC.title = "Мой гараж"
            carsVC.isFirstStart = true
            
            let navVC = UINavigationController(rootViewController: carsVC)
            navVC.modalPresentationStyle = .fullScreen
            navVC.modalTransitionStyle = .crossDissolve
            navVC.navigationBar.prefersLargeTitles = true
            self?.present(navVC, animated: true)
        }
        
        alertVC.addAction(goToCarsVC)
        
        present(alertVC, animated: true)
    }
  
}
