//
//  SampleController.swift
//  EladTraining
//
//  Created by Rohit Daftari on 19/02/21.
//

import Foundation
import UIKit

struct Configuration {
    
    
    var isLoading = false
    
    weak var controller: UITableViewController!
    
    
    
    var titleString: NSAttributedString? {
        var text: String?
        var font: UIFont?
        var textColor: UIColor?
        
        
            text = "No Messages"
            font = UIFont.appRegularFontWith(size: 20)
            textColor = UIColor(hexColor: "c9c9c9")
            
       
        
        if text == nil {
            return nil
        }
        var attributes: [NSAttributedString.Key: Any] = [:]
        if font != nil {
            attributes[NSAttributedString.Key.font] = font!
        }
        if textColor != nil {
            attributes[NSAttributedString.Key.foregroundColor] = textColor
        }
        return NSAttributedString.init(string: text!, attributes: attributes)
    }
    
    
    var detailString: NSAttributedString? {
        var text: String?
        var font: UIFont?
        var textColor: UIColor?
        
        
            text = "When you have messages, you’ll see them here."
            font = UIFont.systemFont(ofSize: 13.0)
            textColor = UIColor(hexColor: "cfcfcf")
            
       
        if text == nil {
            return nil
        }
        var attributes: [NSAttributedString.Key: Any] = [:]
        if font != nil {
            attributes[NSAttributedString.Key.font] = font!
        }
        if textColor != nil {
            attributes[NSAttributedString.Key.foregroundColor] = textColor
        }
        return NSAttributedString.init(string: text!, attributes: attributes)
    }
    
    var image: UIImage? {
     
            
            return UIImage.init(named: "relaxman")
        
    }
    
    var imageAnimation: CAAnimation? {
        let animation = CABasicAnimation.init(keyPath: "transform")
        animation.fromValue = NSValue.init(caTransform3D: CATransform3DIdentity)
        animation.toValue = NSValue.init(caTransform3D: CATransform3DMakeRotation(.pi/2, 0.0, 0.0, 1.0))
        animation.duration = 0.25
        animation.isCumulative = true
        animation.repeatCount = MAXFLOAT
        
        return animation;
    }
    
    
    func buttonTitle(_ state: UIControl.State) -> NSAttributedString? {
        var text: String?
        var font: UIFont?
        var textColor: UIColor?
        
       
            text = "Start Browsing";
            font = UIFont.boldSystemFont(ofSize: 16)
            textColor = UIColor(hexColor: state == .normal ? "05adff" : "6bceff" )
            
        
        if text == nil {
            return nil
        }
        var attributes: [NSAttributedString.Key: Any] = [:]
        if font != nil {
            attributes[NSAttributedString.Key.font] = font!
        }
        if textColor != nil {
            attributes[NSAttributedString.Key.foregroundColor] = textColor
        }
        return NSAttributedString.init(string: text!, attributes: attributes)
    }
    
    
    
   
    
    var verticalOffset: CGFloat {
      return 0
    }
    
    var spaceHeight: CGFloat {
        
                 return 25
    
    }
    
}

