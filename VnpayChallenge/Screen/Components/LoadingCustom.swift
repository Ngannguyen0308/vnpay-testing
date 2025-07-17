//
//  LoadingCustom.swift
//  VnpayChallenge
//
//  Created by ADMIN on 17/7/25.
//

import UIKit
import Foundation

class LoadingCustom: UIView {
    
    private let circleLayer = CAShapeLayer()
    
    private lazy var loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading..."
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(hex: 0x1E1B1B)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupIndicatorLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupIndicatorLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circlePath()
    }
    
    private func setupIndicatorLayout() {
        addSubview(loadingLabel)
        
        NSLayoutConstraint.activate([
            loadingLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingLabel.topAnchor.constraint(equalTo: centerYAnchor, constant: 25)
        ])
        
        layer.addSublayer(circleLayer)
        circlePath()
        
        startAnimating()
    }
    
    private func circlePath() {
        let radius: CGFloat = 20
        let center = CGPoint(x: bounds.midX, y: bounds.midY - 10)
        let circularPath = UIBezierPath(arcCenter: center,
                                        radius: radius,
                                        startAngle: 0,
                                        endAngle: 2 * .pi,
                                        clockwise: true)
        
        circleLayer.path = circularPath.cgPath
        circleLayer.strokeColor = UIColor(red: 0.0, green: 122/255.0, blue: 1.0, alpha: 1.0).cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = 3
        circleLayer.lineCap = .round
    }
    
    func startAnimating() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = Float.infinity
        layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func stopAnimating() {
        layer.removeAnimation(forKey: "rotationAnimation")
    }
}
