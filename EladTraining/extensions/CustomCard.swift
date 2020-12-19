//
//  CustomCard.swift
//  EladTraining
//
//  Created by Rohit Daftari on 17/12/20.
//

import UIKit
import MaterialComponents.MaterialButtons_ButtonThemer
import MaterialComponents.MaterialContainerScheme
import MaterialComponents.MaterialCards_Theming
import MaterialComponents.MaterialButtons_Theming

class CustomCard: MDCCard {
    static let cardWidth: CGFloat = 350;
       
    let cardButton1: MDCButton = MDCButton()
    
    
    
      
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//            if classTiming.superview == nil { addSubview(classTiming) }
            if cardButton1.superview == nil { addSubview(cardButton1) }
           
            cardButton1.sizeToFit()
            
            
        cardButton1.frame = CGRect(x: bounds.midX,
                                       y: bounds.maxY + 8,
                                       width: cardButton1.frame.width,
                                       height: cardButton1.frame.height)
            
        
      }
    override var intrinsicContentSize: CGSize {
        return CGSize(width: CustomCard.cardWidth, height: 280)
      }

}
