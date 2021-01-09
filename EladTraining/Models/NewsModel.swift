//
//  NewsModel.swift
//  EladTraining
//
//  Created by Rohit Daftari on 08/01/21.
//


import  UIKit
struct NewsModel {
    var body:String
    var imageUrl:String
    var timeStamp:Int
    var title:String
    
    init(body:String? ,imageUrl:String?,timeStamp:Int?, title:String?) {
            
        self.body = body ?? ""
        self.imageUrl = imageUrl ?? ""
        self.timeStamp = timeStamp ?? 0
        self.title = title ?? ""
    }

}
