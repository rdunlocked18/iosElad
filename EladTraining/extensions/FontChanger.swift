//
//  FontChanger.swift
//  EladTraining
//
//  Created by Rohit Daftari on 22/12/20.
//

import Foundation
import UIKit
extension UIFont {
    class func appRegularFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: "Poppins-Regular", size: size)!
    }
    class func appBoldFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: "Poppins-Bold", size: size)!
    }
    class func appBlackFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: "Poppins-Black", size: size)!
    }
    class func appLightFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: "Poppins-Light", size: size)!
    }
    class func appMediumFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: "Poppins-Medium", size: size)!
    }
}
