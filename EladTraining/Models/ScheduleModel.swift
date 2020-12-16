//
//  ScheduleModel.swift
//  EladTraining
//
//  Created by Rohit Daftari on 16/12/20.
//

import UIKit
struct ScheduleClasses {
    var capacity:Int
    var coach:String
    var date:String
    var description:String
    var name:String
    var timings:String
    //var usersJoined:[String]
    init(capacity:Int?,coach:String?,date:String?,description:String?,name:String?,timings:String?) {
        self.capacity = capacity ?? 0
        self.coach = coach ?? ""
        self.date = date ?? ""
        self.description = description ?? ""
        self.name = name ?? ""
        self.timings = timings ?? ""
        
    }
    
}
