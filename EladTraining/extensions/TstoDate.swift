//
//  TstoDate.swift
//  EladTraining
//
//  Created by Rohit Daftari on 25/01/21.
//

import Foundation
extension Double {
    func getDateStringFromUnixTime(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        return dateFormatter.string(from: Date(timeIntervalSince1970: self))
    }
}
