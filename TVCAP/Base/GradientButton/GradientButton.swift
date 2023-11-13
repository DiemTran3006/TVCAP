//
//  GradientButton.swift
//  TVCAP
//
//  Created by Bui Trung Quan on 06/11/2023.
//

import UIKit

class GradientButton: UIButton {
    
    /// update inside layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    private lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(hexString: "#5987FF").cgColor, UIColor(hexString: "#44BAFC").cgColor]
        gradientLayer.startPoint = CGPoint(x: 1, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0)
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = 16
        gradientLayer.masksToBounds = false
        
        self.layer.insertSublayer(gradientLayer, at: 0)
        return gradientLayer
    }()
}
