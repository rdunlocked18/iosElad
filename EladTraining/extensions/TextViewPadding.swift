//
//  TextViewPadding.swift
//  EladTraining
//
//  Created by Rohit Daftari on 08/12/20.
//

import UIKit

class TextViewPadding: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
