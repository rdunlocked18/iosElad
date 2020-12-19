//
//  CardViewTabUi.swift
//  EladTraining
//
//  Created by Rohit Daftari on 17/12/20.
//

import UIKit

@IBDesignable class CardViewTabUi: UIView {

    @IBInspectable var cornerRadius : CGFloat = 0
    @IBInspectable var shadowColor : UIColor? = UIColor.black
    @IBInspectable var shadowOffsetWidth : Int = 0
    @IBInspectable var shadowOffseHeight : Int = 1
    @IBInspectable var shadowOpacity : Float = 0.2
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffseHeight)
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        layer.shadowPath = shadowPath.cgPath
        layer.shadowOpacity = shadowOpacity
        
        
    }
}
