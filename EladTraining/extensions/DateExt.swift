//
//  DateExt.swift
//  EladTraining
//
//  Created by Rohit Daftari on 22/12/20.
//

import Foundation
import UIKit
extension Date {

 static func getCurrentDate() -> String {

        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"

        return dateFormatter.string(from: Date())

    }
}
