//
//  DateExt.swift
//  EladTraining
//
//  Created by Rohit Daftari on 22/12/20.
//

import Foundation
import UIKit
extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
