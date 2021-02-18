//
//  ScheduleModel.swift
//  EladTraining
//
//  Created by Rohit Daftari on 16/12/20.
//

import UIKit
struct ScheduleClasses {
    var id:String
    var capacity:Int
    var coach:String
    var date:String
    var description:String
    var name:String
    var startTime:String
    var endTime:String
    var timestamp:Int
    var usersJoined:[String]
    
    init(id:String? ,capacity:Int?,coach:String?,date:String?,description:String?,name:String?,startTime:String?,endTime:String?,timestamp:Int?,userJoined:[String]!) {
        self.id = id ?? ""
        self.capacity = capacity ?? 0
        self.coach = coach ?? ""
        self.date = date ?? ""
        self.description = description ?? ""
        self.name = name ?? ""
        self.startTime = startTime ?? ""
        self.endTime = endTime ?? ""
        self.timestamp = timestamp ?? 0
        self.usersJoined = userJoined ?? []
    }
    
}
