//
//  UserModel.swift
//  EladTraining
//
//  Created by Rohit Daftari on 23/12/20.
//

import UIKit
struct UserPackageModel {
    var  endDate:String
    var  isActive:Bool
    var  packageId:String
    var  sessions:Int
    var  startDate:String
    init(endDate:String? ,isActive : Bool? , packageId : String? , sessions : Int? ,startDate:String? ) {
        self.endDate = endDate ?? ""
        self.isActive = isActive ?? true
        self.packageId = packageId ?? ""
        self.sessions = sessions ?? 0
        self.startDate = startDate ?? ""
    }
    
    
}
