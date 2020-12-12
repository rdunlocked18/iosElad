//
//  PaddingFields.swift
//  EladTraining
//
//  Created by Rohit Daftari on 12/12/20.
//

import Foundation
import UIKit
extension UITextField {

enum PaddingSpace {
    case left(CGFloat)
    case right(CGFloat)
    case equalSpacing(CGFloat)
}

func addPadding(padding: PaddingSpace) {

    self.leftViewMode = .always
    self.layer.masksToBounds = true

    switch padding {

    case .left(let spacing):
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
        self.leftView = leftPaddingView
        self.leftViewMode = .always

    case .right(let spacing):
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
        self.rightView = rightPaddingView
        self.rightViewMode = .always

    case .equalSpacing(let spacing):
        let equalPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
        // left
        self.leftView = equalPaddingView
        self.leftViewMode = .always
        // right
        self.rightView = equalPaddingView
        self.rightViewMode = .always
    }
}
}
