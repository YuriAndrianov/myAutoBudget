//
//  MainTabBar.swift
//  myAutoBudget
//
//  Created by MacBook on 25.09.2021.
//

import UIKit

class MainTabBar: UITabBar {
    
    let centerButton = UIButton()
    private var shapeLayer: CALayer?
 
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCenterButton()
        
        if UIScreen.main.bounds.width < 375 {
            self.items!.forEach { $0.title = "" }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.addShape()
        centerButton.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 0)
        
        self.items![0].titlePositionAdjustment = UIOffset(horizontal: -5, vertical: 0)
        self.items![1].titlePositionAdjustment = UIOffset(horizontal: -25, vertical: 0)
        self.items![2].titlePositionAdjustment = UIOffset(horizontal: 25, vertical: 0)
        self.items![3].titlePositionAdjustment = UIOffset(horizontal: 5, vertical: 0)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
      let from = point
      let to = centerButton.center
      return sqrt((from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)) <= 25 ? centerButton : super.hitTest(point, with: event)
    }
    
    private func addShape() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createPath()
        shapeLayer.strokeColor = UIColor.systemGray3.cgColor
        shapeLayer.fillColor = UIColor.secondarySystemBackground.cgColor
        shapeLayer.lineWidth = 1.0
        
        shapeLayer.shadowOffset = CGSize(width:0, height:0)
        shapeLayer.shadowRadius = 10
        shapeLayer.shadowColor = UIColor.gray.cgColor
        shapeLayer.shadowOpacity = 0.3
        
        if let oldShapeLayer = self.shapeLayer {
            self.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            self.layer.insertSublayer(shapeLayer, at: 0)
        }
        self.shapeLayer = shapeLayer
    }

    private func createPath() -> CGPath {
        let height: CGFloat = 30.0
        let path = UIBezierPath()
        let centerWidth = self.frame.width / 2
        path.move(to: CGPoint(x: 0, y: 0)) // start top left
        path.addLine(to: CGPoint(x: (centerWidth - height * 2), y: 0))
        path.addCurve(to: CGPoint(x: centerWidth, y: height),
                      controlPoint1: CGPoint(x: (centerWidth - 25), y: 0), controlPoint2: CGPoint(x: centerWidth - 30, y: height))
        
        path.addCurve(to: CGPoint(x: (centerWidth + height * 2), y: 0),
                      controlPoint1: CGPoint(x: centerWidth + 30, y: height), controlPoint2: CGPoint(x: (centerWidth + 25), y: 0))
        
        path.addLine(to: CGPoint(x: self.frame.width, y: 0))
        path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
        path.addLine(to: CGPoint(x: 0, y: self.frame.height))
        path.close()
        
        return path.cgPath
    }
    
    private func setupCenterButton() {
        centerButton.frame.size = CGSize(width: 50, height: 50)
        centerButton.setImage(UIImage(named: "plus"), for: .normal)
        centerButton.layer.cornerRadius = 25
        centerButton.layer.masksToBounds = true
        centerButton.layer.shadowColor = UIColor(named: "shadowColor")?.cgColor
        centerButton.layer.shadowRadius = 3
        centerButton.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        centerButton.layer.shadowOpacity = 0.3
        centerButton.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 0)
        addSubview(centerButton)
    }
    
}
